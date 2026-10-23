//
//  NCInjector.m
//  进程内注入核心
//
//  三层替换：
//  1. ObjC：把新类的方法逐个 class_replaceMethod 回旧类
//  2. Swift 类：把新类元数据的 vtable 槽位复制进旧类元数据
//  3. 函数级：C / C++ / Swift 静态派发函数，改写 App 镜像中的符号指针（需 -interposable）
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCInjector.h"
#import "NCMachO.h"
#import "NCRebind.h"
#import "NCSwiftMetadata.h"
#import "NCSwizzleGuard.h"
#import "NCStaticState.h"
#import "NCSweeper.h"
#import "NCLog.h"
#import "NoCompile.h"
#include <dlfcn.h>
#include <objc/runtime.h>
#include <string.h>

@implementation NCInjectResult
@end

/// 历次注入中每个符号的最新实现：后注入的 dylib 引用到这些符号时，要指向最新实现而不是 App 里的原始版本
/// （dyld 按符号表解析，App 镜像导出的永远是第一次编译进去的旧代码）
static NSMutableDictionary<NSString *, NSValue *> *NCLatestSymbolImpls(void) {
    static NSMutableDictionary *table;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        table = [NSMutableDictionary dictionary];
    });
    return table;
}

extern void NCRegisterClassAlias(Class newClass, Class oldClass);

static BOOL NCHasSuffix(const char *name, size_t len, const char *suffix) {
    size_t suffixLen = strlen(suffix);
    return len >= suffixLen && strcmp(name + len - suffixLen, suffix) == 0;
}

/// 符号是否由 Swift 运行时 / 标准库镜像提供（这类符号不能被 App 的注入替换）
static BOOL NCIsStdlibSymbol(const char *name) {
    void *address = dlsym(RTLD_DEFAULT, name + 1);
    if (!address) {
        return NO;
    }
    Dl_info info;
    if (!dladdr(address, &info) || !info.dli_fname) {
        return NO;
    }
    return strstr(info.dli_fname, "libswift") != NULL;
}

/// 外部只读数据符号是否可整体替换：位于只读数据节（__DATA_CONST / __const）的 C 命名常量。
/// C++ vtable / typeinfo、ObjC 元数据、Swift 元数据不处理
static BOOL NCIsReplaceableConstantData(const char *name, const struct section_64 *section) {
    if (!name || name[0] != '_') {
        return NO;
    }
    const char *body = name + 1;
    if (strncmp(body, "_Z", 2) == 0 || strncmp(body, "OBJC_", 5) == 0 || strncmp(body, "$s", 2) == 0
        || strncmp(body, "_OBJC", 5) == 0 || strncmp(body, "swift", 5) == 0 || strncmp(body, "_swift", 6) == 0) {
        return NO;
    }
    BOOL readOnlySegment = strncmp(section->segname, "__DATA_CONST", 16) == 0;
    BOOL constSection = strncmp(section->sectname, "__const", 16) == 0;
    if (!readOnlySegment && !constSection) {
        return NO;
    }
    return YES;
}

/// 判断一个已定义在 __text 节中的符号是否可被函数级替换
static BOOL NCInjectableSymbol(const char *name, uint8_t type, BOOL preserveStatics) {
    if (!name || name[0] != '_') {
        return NO;
    }
    const char *body = name + 1; // 跳过前导下划线
    size_t len = strlen(body);

    // Swift 符号：按 mangled 名后缀识别函数类实体（参考 SwiftTrace.injectableSymbol）
    if (body[0] == '$' && (body[1] == 's' || body[1] == 'S')) {
        // 以 $sS / $ss 开头的符号可能是标准库自己的，也可能是 App 给标准库类型 / ObjC 类型（$sSo 开头，
        // 如 UIView、UIColor）写的扩展方法。后者很常见，不能一律排除：
        // 只有同名符号确实由 Swift 标准库镜像提供时才跳过
        if ((body[2] == 'S' || body[2] == 's') && NCIsStdlibSymbol(name)) {
            return NO;
        }
        // static 成员在 mangled 名末尾多一个 Z（如 static func → FZ，static var getter → vgZ），先去掉再判断
        size_t effectiveLen = len;
        if (effectiveLen > 1 && body[effectiveLen - 1] == 'Z') {
            effectiveLen--;
        }
        char tail[4] = {0};
        size_t tailLen = effectiveLen < 3 ? effectiveLen : 3;
        memcpy(tail, body + effectiveLen - tailLen, tailLen);
        size_t tl = strlen(tail);
        if (NCHasSuffix(tail, tl, "F") && !NCHasSuffix(tail, tl, "MF")) {
            return YES;                 // 函数 / 方法 / 静态方法
        }
        if (NCHasSuffix(tail, tl, "fD") || NCHasSuffix(tail, tl, "fC")) {
            return YES;                 // 析构 / 构造
        }
        if (NCHasSuffix(tail, tl, "vg") || NCHasSuffix(tail, tl, "vs") ||
            NCHasSuffix(tail, tl, "vM") || NCHasSuffix(tail, tl, "vr")) {
            return YES;                 // 属性访问器（含 static）
        }
        if (NCHasSuffix(tail, tl, "vau")) {
            return !preserveStatics;    // 全局 / 静态变量寻址器
        }
        return NO;
    }
    // C++（Itanium ABI）：排除全局构造等编译器生成的初始化函数
    if (strncmp(body, "_Z", 2) == 0) {
        return strstr(body, "GLOBAL__sub_I") == NULL;
    }
    // ObjC 运行时元数据不处理
    if (strncmp(body, "OBJC_", 5) == 0 || strncmp(body, "objc_", 5) == 0) {
        return NO;
    }
    // C 函数：只处理外部可见的符号；入口函数与编译器生成的符号不处理
    if (!(type & N_EXT)) {
        return NO;
    }
    if (strcmp(body, "main") == 0 || body[0] == '_' || body[0] == '.') {
        return NO;
    }
    return YES;
}

/// 全局 / 静态变量寻址器（保留静态状态时反向绑定回旧实现）
static BOOL NCIsStaticAddressor(const char *name) {
    size_t len = strlen(name);
    // 全局变量为 vau，static 存储属性为 vauZ
    return strncmp(name, "_$s", 3) == 0 && (NCHasSuffix(name, len, "vau") || NCHasSuffix(name, len, "vauZ"));
}

/// 进程内全部类的快照，每次注入只取一次（objc_copyClassList 会实现全部类，大工程上很慢）
@interface NCClassSnapshot : NSObject
@property (nonatomic, readonly) NSDictionary<NSString *, NSArray<NSValue *> *> *classesByName;
@property (nonatomic, readonly) NSArray<NSValue *> *allClasses;
@end

@implementation NCClassSnapshot

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableDictionary<NSString *, NSMutableArray<NSValue *> *> *byName = [NSMutableDictionary dictionary];
        NSMutableArray<NSValue *> *all = [NSMutableArray array];
        unsigned int count = 0;
        Class *classes = objc_copyClassList(&count);
        for (unsigned int i = 0; i < count; i++) {
            NSValue *value = [NSValue valueWithPointer:(__bridge const void *)classes[i]];
            [all addObject:value];
            NSString *name = @(class_getName(classes[i]));
            NSMutableArray<NSValue *> *list = byName[name];
            if (!list) {
                list = [NSMutableArray array];
                byName[name] = list;
            }
            [list addObject:value];
        }
        free(classes);
        _classesByName = byName;
        _allClasses = all;
    }
    return self;
}

/// 与新类同名的所有旧类（主程序及历史注入镜像中可能各有一份）
- (NSArray<Class> *)classesNamed:(const char *)className excluding:(Class)excluding {
    NSMutableArray<Class> *result = [NSMutableArray array];
    for (NSValue *value in self.classesByName[@(className)]) {
        Class cls = (__bridge Class)value.pointerValue;
        if (cls != excluding) {
            [result addObject:cls];
        }
    }
    return result;
}

/// cls 的所有子类（直接与间接）
- (NSArray<Class> *)subclassesOf:(Class)cls {
    NSMutableArray<Class> *result = [NSMutableArray array];
    for (NSValue *value in self.allClasses) {
        Class candidate = (__bridge Class)value.pointerValue;
        for (Class parent = class_getSuperclass(candidate); parent; parent = class_getSuperclass(parent)) {
            if (parent == cls) {
                [result addObject:candidate];
                break;
            }
        }
    }
    return result;
}

@end

/// 新旧类的实例布局是否不同：实例大小，或实例变量的个数、名字、偏移、类型编码任一不同。
/// Swift 类的存储属性同样登记在 ObjC 运行时的 ivar 表里（类型编码为空串），一并比较，
/// 能发现「实例大小不变、但调换了属性顺序」这类变化
static BOOL NCInstanceLayoutChanged(Class oldClass, Class newClass) {
    if (class_getInstanceSize(oldClass) != class_getInstanceSize(newClass)) {
        return YES;
    }
    unsigned int oldCount = 0, newCount = 0;
    Ivar *oldIvars = class_copyIvarList(oldClass, &oldCount);
    Ivar *newIvars = class_copyIvarList(newClass, &newCount);
    BOOL changed = oldCount != newCount;
    for (unsigned int i = 0; !changed && i < oldCount; i++) {
        const char *oldName = ivar_getName(oldIvars[i]);
        const char *newName = ivar_getName(newIvars[i]);
        const char *oldType = ivar_getTypeEncoding(oldIvars[i]);
        const char *newType = ivar_getTypeEncoding(newIvars[i]);
        // Swift 属性的类型编码为空串，只在两边都有类型编码时比较
        BOOL typesComparable = oldType && newType && oldType[0] != '\0' && newType[0] != '\0';
        if (!oldName || !newName || strcmp(oldName, newName) != 0 || ivar_getOffset(oldIvars[i]) != ivar_getOffset(newIvars[i])
            || (typesComparable && strcmp(oldType, newType) != 0)) {
            changed = YES;
        }
    }
    free(oldIvars);
    free(newIvars);
    return changed;
}

/// 方法实现所在函数的符号名（如 `-[Foo bar]`）。Debug 产物保留了局部符号，取不到时返回 nil
static NSString *NCFunctionNameForIMP(IMP imp) {
    Dl_info info;
    // dladdr 返回的是"地址之前最近的符号"：符号被剥离或 IMP 是 block 蹦床时，多个方法会被归到同一个错误的名字下，
    // 进而把新实现写到不相干的选择子上。只接受符号起始地址恰好等于 IMP 的结果
    if (imp && dladdr((const void *)imp, &info) && info.dli_sname && info.dli_sname[0] != '\0'
        && info.dli_saddr == (void *)imp) {
        return @(info.dli_sname);
    }
    return nil;
}

/// ObjC 方法替换：把 newClass 的方法逐个写回 oldClass。
///
/// 按"函数体"而不是按选择子配对：旧类的方法可能被 method_exchangeImplementations 换过（+load 里的 swizzle），
/// 此时选择子 `work` 指向的是 `-[Foo hookedWork]` 的函数体。直接按选择子替换会把交换还原，hook 链被破坏。
/// 所以先按函数符号名找到旧类里当前指向该函数体的选择子，把新函数体写到那个选择子上，交换关系得以保留。
/// 找不到对应函数体（新增方法、符号被剥离、block 实现）时退回按选择子替换。
static NSUInteger NCSwizzleObjCMethods(Class oldClass, Class newClass) {
    NSUInteger replaced = 0;

    unsigned int oldCount = 0;
    Method *oldMethods = class_copyMethodList(oldClass, &oldCount);
    NSMutableDictionary<NSString *, NSMutableArray<NSValue *> *> *selectorsByFunction = [NSMutableDictionary dictionary];
    for (unsigned int i = 0; i < oldCount; i++) {
        NSString *function = NCFunctionNameForIMP(method_getImplementation(oldMethods[i]));
        if (!function) {
            continue;
        }
        NSMutableArray<NSValue *> *selectors = selectorsByFunction[function];
        if (!selectors) {
            selectors = [NSMutableArray array];
            selectorsByFunction[function] = selectors;
        }
        [selectors addObject:[NSValue valueWithPointer:method_getName(oldMethods[i])]];
    }
    free(oldMethods);

    unsigned int count = 0;
    Method *methods = class_copyMethodList(newClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        SEL sel = method_getName(methods[i]);
        // +load / +initialize 不回写，避免改变旧类的初始化语义
        if (sel == @selector(load) || sel == @selector(initialize)) {
            continue;
        }
        IMP imp = method_getImplementation(methods[i]);
        const char *types = method_getTypeEncoding(methods[i]);
        NSString *function = NCFunctionNameForIMP(imp);
        NSArray<NSValue *> *targets = function ? selectorsByFunction[function] : nil;
        if (targets.count > 0) {
            for (NSValue *target in targets) {
                class_replaceMethod(oldClass, (SEL)target.pointerValue, imp, types);
                replaced++;
            }
            continue;
        }
        class_replaceMethod(oldClass, sel, imp, types);
        replaced++;
    }
    free(methods);
    return replaced;
}

/// 把旧类里新类没有的方法补到新类上。
///
/// dylib 内部的 `[Foo alloc]`、`[Foo new]` 引用的是新镜像自己的那份类对象，创建出来的实例属于"新类"。
/// 而 App 里其他文件定义的分类（如 `Foo+QA.m`）在启动时只挂在旧类上，新类并没有这些方法，
/// 新类的实例收到这类消息就会 unrecognized selector 崩溃。这里把旧类当前的方法补到新类（已有同名方法的不覆盖，
/// 新类自己的实现优先），实例方法和类方法都处理。
static NSUInteger NCInheritMissingMethods(Class oldClass, Class newClass) {
    NSUInteger added = 0;
    unsigned int count = 0;
    Method *methods = class_copyMethodList(oldClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        SEL sel = method_getName(methods[i]);
        if (sel == @selector(load) || sel == @selector(initialize)) {
            continue;
        }
        // class_addMethod 只在新类自身没有该方法时才添加，不会覆盖新类的实现
        if (class_addMethod(newClass, sel, method_getImplementation(methods[i]), method_getTypeEncoding(methods[i]))) {
            added++;
        }
    }
    free(methods);
    return added;
}

/// ObjC 分类在磁盘上的头部布局（与 objc4 的 category_t 前两个字段一致），这里只读取宿主类
typedef struct {
    const char *name;
    Class cls;
} NCCategoryHeader;

/// 统计新镜像里的分类，并收集它们的宿主类。
///
/// 只含分类的文件（如 UIViewController+Xxx.m）没有 _OBJC_CLASS_$_ 符号，也没有可改写的函数符号。
/// 但 dlopen 时 ObjC 运行时已把新分类的方法列表挂到宿主类方法列表的最前面，同名方法会先于旧分类命中，
/// 改动即时生效，因此这类注入应算成功，不能报"未替换任何实现"。
/// 宿主类定义在新镜像自身时（类与分类写在同一文件），由类方法替换流程处理，这里不收集。
static NSUInteger NCCollectCategories(NCImage *image, NSMutableArray<Class> *hostClasses) {
    size_t size = 0;
    void *data = NCSectionData(image, NULL, "__objc_catlist", &size);
    if (!data || size == 0) {
        return 0;
    }
    NSUInteger attached = 0;
    NCCategoryHeader **list = (NCCategoryHeader **)data;
    size_t count = size / sizeof(NCCategoryHeader *);
    for (size_t i = 0; i < count; i++) {
        NCCategoryHeader *category = list[i];
        // 宿主类为弱引用且缺失时为空
        if (!category || !category->cls) {
            continue;
        }
        attached++;
        const char *hostImage = class_getImageName(category->cls);
        BOOL definedInNewImage = hostImage && strcmp(hostImage, image.path.fileSystemRepresentation) == 0;
        if (!definedInNewImage && ![hostClasses containsObject:category->cls]) {
            [hostClasses addObject:category->cls];
        }
    }
    return attached;
}

/// vtable 槽位指向的函数符号名（不含前导下划线）。槽位不是某个符号的起点
/// （字段偏移、泛型参数等非函数槽位）或取不到符号时返回 NULL
static const char *NCVTableSlotSymbol(NCSwiftImpl impl) {
    Dl_info info;
    if (!impl || !dladdr((const void *)impl, &info) || !info.dli_sname || info.dli_saddr != (void *)impl) {
        return NULL;
    }
    return info.dli_sname;
}

/// Swift vtable 覆写。返回替换的槽位数（>=0）。
///
/// outLayoutChanged 置为 YES 表示 vtable 布局变了，这种情况下**不覆写**：
/// 1. 新旧 classSize 或 classAddressPoint 不一致（增删了方法）：旧实例仍指向旧元数据，
///    Debug（-Onone）下方法一律走 vtable 派发，覆写后的方法体调用新增方法会按新槽位下标越界；
/// 2. 槽位数相同，但同一下标上新旧实现不是同名函数（调换了方法声明顺序、改了方法名）：
///    按下标覆写会让调用方执行到另一个方法，参数与返回值对不上而崩溃。
/// 布局未变（仅改方法体）时逐槽覆写，立即在既有实例上生效。
static long NCPatchSwiftVTable(Class oldClass, Class newClass, BOOL *outLayoutChanged, NCClassSnapshot *snapshot) {
    if (outLayoutChanged) {
        *outLayoutChanged = NO;
    }
    if (!NCIsSwiftClass(oldClass) || !NCIsSwiftClass(newClass)) {
        return 0;
    }
    NCSwiftClassMetadata *oldMeta = (__bridge NCSwiftClassMetadata *)oldClass;
    NCSwiftClassMetadata *newMeta = (__bridge NCSwiftClassMetadata *)newClass;
    if (oldMeta->classSize != newMeta->classSize ||
        oldMeta->classAddressPoint != newMeta->classAddressPoint) {
        if (outLayoutChanged) {
            *outLayoutChanged = YES;
        }
        return 0;
    }
    long slots = NCSwiftVTableSlotCount(oldMeta);
    if (slots <= 0) {
        return 0;
    }
    NCSwiftImpl *oldVTable = NCSwiftVTable(oldMeta);
    NCSwiftImpl *newVTable = NCSwiftVTable(newMeta);
    // 先逐槽核对，全部通过后再写入，避免改到一半才发现顺序不一致
    NSMutableData *pendingData = [NSMutableData dataWithLength:(NSUInteger)slots * sizeof(NCSwiftImpl)];
    NCSwiftImpl *pending = (NCSwiftImpl *)pendingData.mutableBytes;
    for (long i = 0; i < slots; i++) {
        NCSwiftImpl oldValue = oldVTable[i];
        NCSwiftImpl newValue = newVTable[i];
        if (!newValue || oldValue == newValue) {
            continue;
        }
        const char *newName = NCVTableSlotSymbol(newValue);
        if (!newName) {
            // 不是函数槽位（字段偏移等），不动
            continue;
        }
        const char *oldName = NCVTableSlotSymbol(oldValue);
        if (oldName && strcmp(oldName, newName) != 0) {
            if (outLayoutChanged) {
                *outLayoutChanged = YES;
            }
            return 0;
        }
        pending[i] = newValue;
    }
    // 子类元数据里保存着继承来的槽位副本（与父类同一偏移），没有重写的子类实例仍会执行旧实现，
    // 一并改掉：只改仍指向父类旧实现的槽位，子类自己的重写不动
    NSMutableArray<Class> *swiftSubclasses = [NSMutableArray array];
    for (Class subclass in [snapshot subclassesOf:oldClass]) {
        if (NCIsSwiftClass(subclass)) {
            [swiftSubclasses addObject:subclass];
        }
    }
    long patched = 0;
    for (long i = 0; i < slots; i++) {
        NCSwiftImpl value = pending[i];
        if (!value) {
            continue;
        }
        NCSwiftImpl previous = oldVTable[i];
        NCSwiftImpl *slot = &oldVTable[i];
        if (NCWithWritableMemory(slot, sizeof(NCSwiftImpl), ^{
            *slot = value;
        })) {
            patched++;
        }
        uintptr_t offset = (uintptr_t)slot - (uintptr_t)oldMeta;
        for (Class subclass in swiftSubclasses) {
            NCSwiftClassMetadata *subMeta = (__bridge NCSwiftClassMetadata *)subclass;
            // 槽位必须落在子类元数据范围内
            uintptr_t subEnd = (uintptr_t)subMeta - subMeta->classAddressPoint + subMeta->classSize;
            NCSwiftImpl *subSlot = (NCSwiftImpl *)((uintptr_t)subMeta + offset);
            if ((uintptr_t)(subSlot + 1) > subEnd || *subSlot != previous) {
                continue;
            }
            if (NCWithWritableMemory(subSlot, sizeof(NCSwiftImpl), ^{
                *subSlot = value;
            })) {
                patched++;
            }
        }
    }
    return patched;
}

/// 函数名里的选择子部分：「-[Foo(Cat) bar:baz:]」→「bar:baz:」，不是 ObjC 方法名时返回 nil
static NSString *NCSelectorPartOfFunctionName(NSString *function) {
    NSRange space = [function rangeOfString:@" "];
    if (![function hasSuffix:@"]"] || space.location == NSNotFound) {
        return nil;
    }
    NSUInteger start = NSMaxRange(space);
    return [function substringWithRange:NSMakeRange(start, function.length - 1 - start)];
}

/// 地址是否位于 App 自身的镜像（主程序、App 内 framework、注入镜像），系统库返回 NO
static BOOL NCIsAppAddress(const void *address) {
    Dl_info info;
    return address && dladdr(address, &info) && NCPathIsAppImage(info.dli_fname);
}

/// 重新加载分类后修正宿主类上的方法，避免分类 +load 中的 swizzle 被重新加载后无限递归。
///
/// 以 UIViewController+Track.m 为例：启动时 +load 交换了 viewWillAppear: 与 track_viewWillAppear:，
/// 于是 viewWillAppear: 条目指向旧的 track 函数体、旧分类的 track_ 条目指向 UIKit 原实现。
/// 注入新镜像后，新分类的 track_ 条目挂到方法列表最前（指向新函数体），+load 里的交换被拦截。
/// 此时 viewWillAppear: → 旧 track 体 → [self track_…] → 新 track 体 → [self track_…] → 新 track 体……无限递归。
/// 修正方式：
/// 1. 宿主类上所有「函数体与新条目同名、但实现还是旧镜像」的条目（如被交换过的 viewWillAppear:）改指向新函数体；
/// 2. 新条目的选择子在旧条目里若被交换过（旧条目的函数名对应的是别的选择子，如 UIKit 原实现），
///    新条目改为沿用旧条目当前的实现，从而保持交换关系。
/// 返回修正的条目数
static NSUInteger NCFixReloadedCategoryMethods(Class cls, NCImage *newImage) {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    if (!methods) {
        return 0;
    }
    // 新镜像里的分类条目：函数名 → 新实现，选择子 → 新条目
    NSMutableDictionary<NSString *, NSValue *> *newImpByFunction = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSValue *> *newMethodBySelector = [NSMutableDictionary dictionary];
    for (unsigned int i = 0; i < count; i++) {
        IMP imp = method_getImplementation(methods[i]);
        if (!NCImageContainsAddress(newImage, (const void *)imp)) {
            continue;
        }
        NSString *function = NCFunctionNameForIMP(imp);
        if (function) {
            newImpByFunction[function] = [NSValue valueWithPointer:(const void *)imp];
        }
        NSString *selector = NSStringFromSelector(method_getName(methods[i]));
        if (!newMethodBySelector[selector]) {
            newMethodBySelector[selector] = [NSValue valueWithPointer:methods[i]];
        }
    }
    if (newMethodBySelector.count == 0) {
        free(methods);
        return 0;
    }
    // 先算出全部修改再统一应用，避免改动影响后续判断
    NSMutableArray<NSArray<NSValue *> *> *changes = [NSMutableArray array];
    NSMutableSet<NSString *> *shadowHandled = [NSMutableSet set];
    for (unsigned int i = 0; i < count; i++) {
        Method method = methods[i];
        IMP imp = method_getImplementation(method);
        if (NCImageContainsAddress(newImage, (const void *)imp)) {
            continue;
        }
        NSString *selector = NSStringFromSelector(method_getName(method));
        // 规则 2：同选择子的第一个旧条目就是注入前生效的那个
        NSValue *newMethod = newMethodBySelector[selector];
        if (newMethod && ![shadowHandled containsObject:selector]) {
            [shadowHandled addObject:selector];
            NSString *function = NCFunctionNameForIMP(imp);
            NSString *functionSelector = function ? NCSelectorPartOfFunctionName(function) : nil;
            if (functionSelector && ![functionSelector isEqualToString:selector]) {
                [changes addObject:@[newMethod, [NSValue valueWithPointer:(const void *)imp]]];
            }
        }
        // 规则 1：旧镜像里与新条目同名的函数体（只看 App 镜像，系统实现不会是分类函数体）
        if (!NCIsAppAddress((const void *)imp)) {
            continue;
        }
        NSString *function = NCFunctionNameForIMP(imp);
        NSValue *replacement = function ? newImpByFunction[function] : nil;
        if (replacement) {
            [changes addObject:@[[NSValue valueWithPointer:method], replacement]];
        }
    }
    for (NSArray<NSValue *> *change in changes) {
        method_setImplementation((Method)change[0].pointerValue, (IMP)change[1].pointerValue);
    }
    free(methods);
    return changes.count;
}

#pragma mark - 不透明返回类型（some View）

/// 把 mangled 名里的符号引用（相对 / 绝对地址）换成目标符号名，得到与镜像地址无关的描述。无法解析时返回 nil
static NSString *NCCanonicalMangledName(const char *mangled) {
    NSMutableString *result = [NSMutableString string];
    const uint8_t *cursor = (const uint8_t *)mangled;
    for (int guard = 0; *cursor != 0; guard++) {
        if (guard > 4096) {
            return nil;
        }
        uint8_t byte = *cursor;
        const void *target = NULL;
        if (byte >= 0x01 && byte <= 0x17) {
            int32_t offset = 0;
            memcpy(&offset, cursor + 1, sizeof(offset));
            target = cursor + 1 + offset;
            // 0x02：间接引用，目标处存放的是指向描述符的指针
            if (byte == 0x02) {
                memcpy(&target, target, sizeof(target));
            }
            cursor += 5;
        } else if (byte >= 0x18 && byte <= 0x1F) {
            memcpy(&target, cursor + 1, sizeof(target));
            cursor += 1 + sizeof(target);
        } else {
            [result appendFormat:@"%c", byte];
            cursor++;
            continue;
        }
        Dl_info info;
        if (!target || !dladdr(target, &info) || !info.dli_sname || info.dli_saddr != target) {
            return nil;
        }
        [result appendFormat:@"<%s>", info.dli_sname];
    }
    return result;
}

/// 读取不透明类型描述符（OpaqueTypeDescriptor）里各个具体类型的描述。布局无法识别时返回 nil
static NSArray<NSString *> *NCOpaqueUnderlyingTypes(const void *descriptor) {
    const uint8_t *base = (const uint8_t *)descriptor;
    uint32_t flags = 0;
    memcpy(&flags, base, sizeof(flags));
    // ContextDescriptorKind：OpaqueType = 4
    if ((flags & 0x1F) != 4) {
        return nil;
    }
    BOOL isGeneric = (flags & 0x80) != 0;
    // 尾部条目数 = 具体类型数 + 协议一致性访问器数；一致性随具体类型确定，只比较前面的具体类型
    uint16_t trailingCount = (uint16_t)(flags >> 16);
    uint16_t underlyingCount = trailingCount > 0 ? 1 : 0;
    // Flags(4) + Parent(4)
    const uint8_t *cursor = base + 8;
    if (isGeneric) {
        // GenericContextDescriptorHeader：NumParams, NumRequirements, NumKeyArguments, Flags（各 2 字节）
        uint16_t header[4];
        memcpy(header, cursor, sizeof(header));
        // 类型包、条件可逆协议、值泛型等扩展布局不解析
        if (header[3] != 0) {
            return nil;
        }
        // 每个 some 占一个泛型参数，对应一个具体类型
        underlyingCount = MIN(header[0], trailingCount);
        cursor += sizeof(header);
        cursor += ((uint32_t)header[0] + 3) & ~3U;     // GenericParamDescriptor 每个 1 字节，按 4 对齐
        cursor += (uint32_t)header[1] * 12;            // GenericRequirementDescriptor 每个 12 字节
    }
    NSMutableArray<NSString *> *types = [NSMutableArray array];
    for (uint16_t i = 0; i < underlyingCount; i++) {
        const uint8_t *field = cursor + i * 4;
        int32_t offset = 0;
        memcpy(&offset, field, sizeof(offset));
        NSString *canonical = NCCanonicalMangledName((const char *)(field + offset));
        if (!canonical) {
            return nil;
        }
        [types addObject:canonical];
    }
    return types;
}

/// 返回不透明返回类型函数（如 `var body: some View` 的 getter）对应的描述符符号名，不是这类函数时返回 nil
static NSString *NCOpaqueDescriptorNameForSymbol(NSString *name) {
    if (![name hasPrefix:@"_$s"] || ![name containsString:@"Qr"]) {
        return nil;
    }
    if ([name hasSuffix:@"vg"]) {
        // 属性 getter：…4bodyQrvg → …4bodyQrvpQOMQ
        return [[name substringToIndex:name.length - 2] stringByAppendingString:@"vpQOMQ"];
    }
    if ([name hasSuffix:@"F"] || [name hasSuffix:@"FZ"]) {
        return [name stringByAppendingString:@"QOMQ"];
    }
    return nil;
}

/// 在 App 原有镜像（不含注入镜像）中查找符号地址，结果缓存
static const void *NCOriginalSymbolAddress(NSString *name, NCImage *newImage) {
    static NSMutableDictionary<NSString *, NSValue *> *cache;
    if (!cache) {
        cache = [NSMutableDictionary dictionary];
    }
    NSValue *cached = cache[name];
    if (cached) {
        return cached.pointerValue;
    }
    const void *found = NULL;
    void *address = dlsym(RTLD_DEFAULT, name.UTF8String + 1);
    Dl_info info;
    if (address && !NCImageContainsAddress(newImage, address) && dladdr(address, &info) && info.dli_fname
        && !NCIsInjectedImagePath(@(info.dli_fname))) {
        found = address;
    } else {
        // 未导出的符号：逐个扫描 App 原有镜像的符号表
        const char *target = name.UTF8String;
        for (NCImage *image in NCAppImages()) {
            if (image.header == newImage.header || NCIsInjectedImagePath(image.path)) {
                continue;
            }
            __block const void *hit = NULL;
            NCEnumerateSymbols(image, ^(const char *symbol, uintptr_t symbolAddress, uint8_t type,
                                        const struct section_64 *section, BOOL *stop) {
                if (symbolAddress != 0 && strcmp(symbol, target) == 0) {
                    hit = (const void *)symbolAddress;
                    *stop = YES;
                }
            });
            if (hit) {
                found = hit;
                break;
            }
        }
    }
    cache[name] = [NSValue valueWithPointer:found];
    return found;
}

/// 不透明返回类型的具体类型是否与 App 原有版本一致。
/// 旧代码（SwiftUI 经协议见证调用 body）按原描述符解释返回值的类型；新 getter 返回的具体类型若不同
/// （如 VStack 里增删了子视图），大小与布局都对不上，替换后直接破坏内存。
/// 不能确定时视为不一致（宁可不替换）
static BOOL NCOpaqueResultTypeUnchanged(NSString *descriptorName, const void *newDescriptor, NCImage *newImage) {
    const void *oldDescriptor = NCOriginalSymbolAddress(descriptorName, newImage);
    if (!oldDescriptor) {
        return NO;
    }
    NSArray<NSString *> *oldTypes = NCOpaqueUnderlyingTypes(oldDescriptor);
    NSArray<NSString *> *newTypes = NCOpaqueUnderlyingTypes(newDescriptor);
    return oldTypes && newTypes && [oldTypes isEqualToArray:newTypes];
}

@implementation NCInjector

+ (dispatch_queue_t)injectionQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.nocompile.injection", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (NCInjectResult *)injectDylibAtPath:(NSString *)dylibPath sourceFiles:(NSArray<NSString *> *)sourceFiles {
    return [self injectDylibAtPath:dylibPath sourceFiles:sourceFiles isNewFile:NO];
}

+ (NCInjectResult *)injectDylibAtPath:(NSString *)dylibPath
                          sourceFiles:(NSArray<NSString *> *)sourceFiles
                            isNewFile:(BOOL)isNewFile {
    return [self injectDylibAtPath:dylibPath sourceFiles:sourceFiles isNewFile:isNewFile symbolShimPath:nil];
}

+ (NCInjectResult *)injectDylibAtPath:(NSString *)dylibPath
                          sourceFiles:(NSArray<NSString *> *)sourceFiles
                            isNewFile:(BOOL)isNewFile
                       symbolShimPath:(NSString *)symbolShimPath {
    // 实际替换都在主线程执行，避免与 UI 代码并发；主线程本身就是串行的，直接执行即可。
    // 不能在主线程上先 dispatch_sync 到 injectionQueue：若后台线程正持有该队列并等待主线程，两者会互相等待而死锁
    if (NSThread.isMainThread) {
        return [self performInject:dylibPath sourceFiles:sourceFiles isNewFile:isNewFile symbolShimPath:symbolShimPath];
    }
    __block NCInjectResult *result = nil;
    // 后台线程发起的多次注入先在 injectionQueue 上排队，再逐个切到主线程执行
    dispatch_sync([self injectionQueue], ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self performInject:dylibPath sourceFiles:sourceFiles isNewFile:isNewFile symbolShimPath:symbolShimPath];
        });
    });
    return result;
}

+ (NCInjectResult *)performInject:(NSString *)dylibPath
                      sourceFiles:(NSArray<NSString *> *)sourceFiles
                        isNewFile:(BOOL)isNewFile
                   symbolShimPath:(NSString *)symbolShimPath {
    NCInjectResult *result = [NCInjectResult new];

    // 0. 符号桥接：工程只导出少数符号时（EXPORTED_SYMBOLS_FILE、-fvisibility=hidden），App 里的类、函数、常量都不在导出表中，
    //    注入 dylib 按扁平命名空间查找会失败。桥接 dylib 把它们按运行时地址导出为绝对符号，必须全局可见（RTLD_GLOBAL）
    //    才会参与扁平查找。加载后不再卸载：它只含指向 App 原对象的导出，之后的 dlsym 查到的也是 App 里的原对象
    if (symbolShimPath.length > 0) {
        void *shim = dlopen(symbolShimPath.fileSystemRepresentation, RTLD_NOW | RTLD_GLOBAL);
        if (!shim) {
            const char *err = dlerror();
            result.status = NCInjectStatusLoadFailed;
            result.message = [NSString stringWithFormat:@"加载符号桥接 dylib 失败：%@", err ? @(err) : @"dlopen 失败"];
            return result;
        }
    }

    // dlopen 会执行新镜像的 +load；加载期间拦截其中的 swizzling，避免 hook 链自我指向
    BOOL guard = NoCompile.suppressSwizzlingDuringLoad;
    if (guard) {
        NCSwizzleGuardBegin(dylibPath.fileSystemRepresentation);
    }
    // 新增文件的符号在 App 中不存在，之后的注入（如引用了新类型的旧文件）要靠全局查找链接到它
    void *handle = dlopen(dylibPath.fileSystemRepresentation, RTLD_NOW | (isNewFile ? RTLD_GLOBAL : RTLD_LOCAL));
    if (guard) {
        NCSwizzleGuardEnd();
    }
    if (!handle) {
        const char *err = dlerror();
        result.status = NCInjectStatusLoadFailed;
        result.message = [self explainLoadError:err ? @(err) : @"dlopen 失败"];
        return result;
    }

    NCImage *newImage = NCImageForPath(dylibPath);
    if (!newImage) {
        result.status = NCInjectStatusLoadFailed;
        result.message = @"dylib 已加载但无法在镜像列表中定位";
        return result;
    }
    NCRegisterInjectedImagePath(newImage.path);

    BOOL preserveStatics = NoCompile.preserveStaticState;

    // 1. 收集新镜像中的类符号与可替换的函数符号
    NSMutableArray<NSString *> *classSymbols = [NSMutableArray array];
    NSMutableArray<NSString *> *interposeNames = [NSMutableArray array];
    NSMutableArray<NSValue *> *interposeImpls = [NSMutableArray array];
    NSMutableArray<NSString *> *staticAddressors = [NSMutableArray array];
    NSMutableSet<NSString *> *weakDefinedNames = [NSMutableSet set];
    NSMutableArray<NSString *> *undefinedNames = [NSMutableArray array];
    // 新镜像里的不透明类型描述符（some View 等）：符号名 → 地址
    NSMutableDictionary<NSString *, NSValue *> *opaqueDescriptors = [NSMutableDictionary dictionary];
    // 新镜像里类符号与 Swift 元数据访问器的地址（含局部符号）：符号名 → 地址
    NSMutableDictionary<NSString *, NSValue *> *localSymbolAddresses = [NSMutableDictionary dictionary];

    NCEnumerateSymbolsWithDesc(newImage, ^(const char *name, uintptr_t address, uint8_t type, uint16_t desc,
                                           const struct section_64 *section, BOOL *stop) {
        if (address == 0 && (type & N_TYPE) == N_UNDF) {
            [undefinedNames addObject:@(name)];
            return;
        }
        if (address == 0 || !section) {
            return;
        }
        size_t len = strlen(name);
        if (strncmp(name, "_$s", 3) == 0 && NCHasSuffix(name, len, "QOMQ")) {
            opaqueDescriptors[@(name)] = [NSValue valueWithPointer:(const void *)address];
            return;
        }
        // 类符号同时记下地址：private / fileprivate 的 Swift 类、-fvisibility=hidden 或 EXPORTED_SYMBOLS_FILE 下的 ObjC 类
        // 都是局部符号，dlsym 查不到，只能用符号表里的地址
        if (strncmp(name, "_OBJC_CLASS_$_", 14) == 0) {
            [classSymbols addObject:@(name)];
            localSymbolAddresses[@(name)] = [NSValue valueWithPointer:(const void *)address];
            return;
        }
        // Swift 类元数据（ObjC 兼容类在 __objc_classlist 中也会出现，这里用 CN 统一取）
        if (strncmp(name, "_$s", 3) == 0 && NCHasSuffix(name, len, "CN")) {
            [classSymbols addObject:@(name)];
            localSymbolAddresses[@(name)] = [NSValue valueWithPointer:(const void *)address];
            return;
        }
        // Swift 类的元数据访问器（...CMa），取类对象时调用它完成运行时初始化
        if (strncmp(name, "_$s", 3) == 0 && NCHasSuffix(name, len, "CMa")) {
            localSymbolAddresses[@(name)] = [NSValue valueWithPointer:(const void *)address];
        }
        // 外部只读数据（`NSString *const kTitle`、`const int kLimit`、const 数组 / 结构体）：
        // 其他镜像里的引用要指向新值，否则旧文件读到的仍是旧常量
        if ((type & N_EXT) && NCIsReplaceableConstantData(name, section)) {
            [interposeNames addObject:@(name)];
            [interposeImpls addObject:[NSValue valueWithPointer:(void *)address]];
            return;
        }
        BOOL isText = strncmp(section->sectname, "__text", 16) == 0;
        if (!isText) {
            return;
        }
        if (NCInjectableSymbol(name, type, preserveStatics)) {
            [interposeNames addObject:@(name)];
            [interposeImpls addObject:[NSValue valueWithPointer:(void *)address]];
            // 弱定义（C++ 模板 / inline 函数等）：dyld 的弱符号合并会让新镜像自己的引用也绑到旧镜像的那份，
            // 新镜像内部同样需要改写，否则新代码调用到的 inline / 模板函数仍是旧实现
            if (desc & N_WEAK_DEF) {
                [weakDefinedNames addObject:@(name)];
            }
        }
        if (preserveStatics && NCIsStaticAddressor(name)) {
            [staticAddressors addObject:@(name)];
        }
    });

    // 2. ObjC 方法替换与 Swift vtable 覆写
    NSMutableArray<Class> *patchedClasses = [NSMutableArray array];
    NSMutableArray<Class> *addedClasses = [NSMutableArray array];
    NSUInteger objcReplaced = 0;
    long swiftPatched = 0;
    // 发生布局变化（增删 / 重排方法或存储属性）的类名：这些类的方法一律不替换，改动在重新运行 App 后生效
    NSMutableArray<NSString *> *layoutChanged = [NSMutableArray array];
    // 布局变化的 Swift 类的成员符号前缀（类元数据符号去掉末尾的 N），这些成员不做函数级重绑
    NSMutableSet<NSString *> *unsafeMemberPrefixes = [NSMutableSet set];

    NCClassSnapshot *classSnapshot = classSymbols.count > 0 ? [NCClassSnapshot new] : nil;
    // 继承 NSObject 的 Swift 类同时有 _OBJC_CLASS_$_ 与 $s...CN 两个符号，指向同一个类，只处理一次
    NSMutableSet<NSValue *> *handledClasses = [NSMutableSet set];
    for (NSString *symbol in classSymbols) {
        void *ptr = [self classPointerForSymbol:symbol handle:handle localAddresses:localSymbolAddresses];
        if (!ptr || [handledClasses containsObject:[NSValue valueWithPointer:ptr]]) {
            continue;
        }
        [handledClasses addObject:[NSValue valueWithPointer:ptr]];
        Class newClass = (__bridge Class)ptr;
        const char *className = class_getName(newClass);
        NSArray<Class> *oldClasses = [classSnapshot classesNamed:className excluding:newClass];
        if (oldClasses.count == 0) {
            [addedClasses addObject:newClass];
            continue;
        }
        for (Class oldClass in oldClasses) {
            // 布局变了（增删 / 重排存储属性或 ivar，增删 / 重排方法）：旧实例按旧布局分配、旧元数据的 vtable 已固定。
            // 新方法体按新偏移读写成员、按新槽位派发，放到旧实例上会越界或调用到别的方法而崩溃——
            // 即便是 @objc / ObjC 方法（如 viewWillAppear: 的 override、outlet 的 getter、dealloc）也一样。
            // 因此这个类的方法一律不替换（ObjC 方法、vtable、函数级重绑都不做），改动在重新运行 App 后生效。
            // 仍登记别名并补齐方法，让新镜像内部创建的新实例能通过类型判定、响应其他文件分类中的方法
            BOOL vtableLayoutChanged = NO;
            long patched = 0;
            BOOL instanceLayoutChanged = NCInstanceLayoutChanged(oldClass, newClass);
            if (!instanceLayoutChanged) {
                patched = NCPatchSwiftVTable(oldClass, newClass, &vtableLayoutChanged, classSnapshot);
            }
            if (instanceLayoutChanged || vtableLayoutChanged) {
                if (![layoutChanged containsObject:@(className)]) {
                    [layoutChanged addObject:@(className)];
                }
                if ([symbol hasPrefix:@"_$s"]) {
                    [unsafeMemberPrefixes addObject:[symbol substringToIndex:symbol.length - 1]];
                }
                NCInheritMissingMethods(oldClass, newClass);
                NCInheritMissingMethods(object_getClass(oldClass), object_getClass(newClass));
                NCRegisterClassAlias(newClass, oldClass);
                continue;
            }
            swiftPatched += patched;
            // ObjC / @objc 方法：布局一致时动态派发替换即可安全生效
            objcReplaced += NCSwizzleObjCMethods(oldClass, newClass);
            objcReplaced += NCSwizzleObjCMethods(object_getClass(oldClass), object_getClass(newClass));
            // 新类的实例（dylib 内 alloc 出来的）也要能响应旧类上由其他文件的分类等提供的方法
            NCInheritMissingMethods(oldClass, newClass);
            NCInheritMissingMethods(object_getClass(oldClass), object_getClass(newClass));
            NCRegisterClassAlias(newClass, oldClass);
            if (![patchedClasses containsObject:oldClass]) {
                [patchedClasses addObject:oldClass];
            }
        }
    }

    // 2.5 分类：运行时在 dlopen 时已把它们附加到宿主类。App 自有类的宿主纳入受影响类，用于提示重进页面；
    //     系统类（如 UIViewController）不纳入，否则几乎所有控制器都会被判定为受影响
    NSMutableArray<Class> *categoryHosts = [NSMutableArray array];
    NSUInteger categoriesAttached = NCCollectCategories(newImage, categoryHosts);
    for (Class host in categoryHosts) {
        // 重新加载的分类若在 +load 中 swizzle 过宿主类，修正方法实现，避免新旧函数体互相调用陷入无限递归
        NCFixReloadedCategoryMethods(host, newImage);
        NCFixReloadedCategoryMethods(object_getClass(host), newImage);
        if ([NCSweeper isAppClass:host] && ![patchedClasses containsObject:host]) {
            [patchedClasses addObject:host];
        }
    }

    // 2.7 过滤不能做函数级重绑的符号
    NSMutableArray<NSString *> *opaqueChanged = [NSMutableArray array];
    {
        NSSet<NSString *> *allNames = [NSSet setWithArray:interposeNames];
        NSMutableArray<NSString *> *keptNames = [NSMutableArray array];
        NSMutableArray<NSValue *> *keptImpls = [NSMutableArray array];
        for (NSUInteger i = 0; i < interposeNames.count; i++) {
            NSString *name = interposeNames[i];
            // 布局变化的类的成员：新实现按新布局访问旧实例，不能替换
            BOOL unsafe = NO;
            for (NSString *prefix in unsafeMemberPrefixes) {
                if ([name hasPrefix:prefix]) {
                    unsafe = YES;
                    break;
                }
            }
            if (unsafe) {
                continue;
            }
            // 类的分配构造器（fC，内部 alloc 新类元数据）：重绑后旧代码 Foo() 得到的是「新类」实例，
            // 旧代码里的 as? / as! Foo 按元数据指针比较会失败甚至崩溃。只重绑初始化构造器（fc）即可让构造逻辑生效，
            // 实例仍属于旧类。结构体 / 枚举只有 fC，照常重绑
            if ([name hasSuffix:@"fC"]) {
                NSString *initializer = [[name substringToIndex:name.length - 1] stringByAppendingString:@"c"];
                if ([allNames containsObject:initializer]) {
                    continue;
                }
            }
            // 不透明返回类型（some View）的具体类型变了：替换会破坏内存
            NSString *descriptorName = NCOpaqueDescriptorNameForSymbol(name);
            NSValue *descriptor = descriptorName ? opaqueDescriptors[descriptorName] : nil;
            if (descriptor && !NCOpaqueResultTypeUnchanged(descriptorName, descriptor.pointerValue, newImage)) {
                [opaqueChanged addObject:name];
                continue;
            }
            [keptNames addObject:name];
            [keptImpls addObject:interposeImpls[i]];
        }
        [interposeNames setArray:keptNames];
        [interposeImpls setArray:keptImpls];
    }

    // 2.8 新增的符号（App 里没有同名定义，如新增 / 改了签名的函数）：提升为全局，
    //     之后注入的 dylib 才能引用到它们（否则 dlopen 报未解析符号）
    if (!isNewFile) {
        NSUInteger newSymbols = 0;
        for (NSString *name in interposeNames) {
            if (!dlsym(RTLD_DEFAULT, name.UTF8String + 1)) {
                newSymbols++;
            }
        }
        if (newSymbols > 0) {
            dlopen(dylibPath.fileSystemRepresentation, RTLD_NOLOAD | RTLD_GLOBAL);
        }
    }

    // 2.9 新镜像引用了此前注入过的符号：指向它们的最新实现
    NSMutableDictionary<NSString *, NSValue *> *latest = NCLatestSymbolImpls();
    NSMutableSet<NSString *> *definedHere = [NSMutableSet setWithArray:interposeNames];
    if (latest.count > 0 && undefinedNames.count > 0) {
        NSMutableArray<NSString *> *wanted = [NSMutableArray array];
        for (NSString *name in undefinedNames) {
            if (latest[name] && ![definedHere containsObject:name]) {
                [wanted addObject:name];
            }
        }
        if (wanted.count > 0) {
            NCRebinding *refs = calloc(wanted.count, sizeof(NCRebinding));
            for (NSUInteger i = 0; i < wanted.count; i++) {
                refs[i].name = wanted[i].UTF8String;
                refs[i].replacement = latest[wanted[i]].pointerValue;
            }
            NCRebindImage(newImage, refs, wanted.count);
            free(refs);
        }
    }
    for (NSUInteger i = 0; i < interposeNames.count; i++) {
        latest[interposeNames[i]] = interposeImpls[i];
    }

    // 3. 函数级替换：改写所有 App 镜像（含历史注入镜像）里对这些符号的引用
    NSUInteger rebound = 0;
    NSUInteger count = interposeNames.count;
    if (count > 0) {
        NCRebinding *rebindings = calloc(count, sizeof(NCRebinding));
        for (NSUInteger i = 0; i < count; i++) {
            rebindings[i].name = interposeNames[i].UTF8String;
            rebindings[i].replacement = interposeImpls[i].pointerValue;
        }
        for (NCImage *image in NCAppImages()) {
            // 新镜像内部对自身（强）函数的调用无需改写
            if (image.header == newImage.header) {
                continue;
            }
            rebound += NCRebindImage(image, rebindings, count);
        }
        // 新镜像内部：只改写弱定义符号的引用，让它们指向新镜像自己的那份
        if (weakDefinedNames.count > 0) {
            NCRebinding *weakRebindings = calloc(weakDefinedNames.count, sizeof(NCRebinding));
            NSUInteger weakCount = 0;
            for (NSUInteger i = 0; i < count; i++) {
                if ([weakDefinedNames containsObject:interposeNames[i]]) {
                    weakRebindings[weakCount].name = rebindings[i].name;
                    weakRebindings[weakCount].replacement = rebindings[i].replacement;
                    weakCount++;
                }
            }
            NCRebindImage(newImage, weakRebindings, weakCount);
            free(weakRebindings);
        }
        free(rebindings);
    }

    // 4. 保留静态状态：新镜像里的全局 / 静态变量寻址器指回旧实现，单例不会被重建
    if (preserveStatics && staticAddressors.count > 0) {
        [self rebindStaticAddressors:staticAddressors inImage:newImage];
    }
    // 4.5 C / ObjC 的 static 变量（`static dispatch_once_t`、`static Foo *instance`、文件内计数器等）：
    //     新镜像自带一份存储，不迁移的话单例会被重建、计数清零
    if (preserveStatics) {
        NSUInteger moved = NCTransferStaticState(newImage, NCAppImages(), sourceFiles);
        if (moved > 0) {
            NCLogLocal(NCLogLevelInfo, @"已迁移 %lu 个 static 变量的状态", (unsigned long)moved);
        }
    }

    // dylib 只定义了 App 里没有的新符号（新增函数、改了签名的函数）时同样算成功：它们靠后续注入引用
    BOOL definesOnlyNewSymbols = NO;
    if (interposeNames.count > 0 && rebound == 0) {
        definesOnlyNewSymbols = YES;
        for (NSString *name in interposeNames) {
            void *existing = dlsym(RTLD_DEFAULT, name.UTF8String + 1);
            // 全局提升后 dlsym 能找到新镜像自己的符号：用地址区分是否是新镜像的
            if (existing && !NCImageContainsAddress(newImage, existing)) {
                definesOnlyNewSymbols = NO;
                break;
            }
        }
    }
    if (objcReplaced == 0 && swiftPatched == 0 && rebound == 0 && categoriesAttached == 0 && addedClasses.count == 0 && !isNewFile
        && layoutChanged.count == 0 && opaqueChanged.count == 0 && !definesOnlyNewSymbols) {
        result.status = NCInjectStatusNothingInjected;
        result.message = @"未替换任何实现。请确认 Debug 配置的 Other Linker Flags 含 -Xlinker -interposable";
        return result;
    }
    NSMutableArray<NSString *> *warnings = [NSMutableArray array];
    if (layoutChanged.count > 0) {
        [warnings addObject:[NSString stringWithFormat:@"%@ 增删或调整了属性 / 方法（内存布局变了），为避免崩溃未替换这些类的实现，请重新运行 App",
                             [layoutChanged componentsJoinedByString:@"、"]]];
    }
    if (opaqueChanged.count > 0) {
        [warnings addObject:[NSString stringWithFormat:@"%lu 个 some View 的视图结构变了（返回的具体类型不同），直接替换会破坏内存，已跳过；"
                             "在 body 末尾加 .enableInjection()（或用 AnyView 包裹）后即可热重载结构改动，否则请重新运行 App",
                             (unsigned long)opaqueChanged.count]];
    }
    for (NSString *warning in warnings) {
        NCLogWarn(@"%@", warning);
    }

    result.status = NCInjectStatusSuccess;
    result.objcMethodsReplaced = objcReplaced;
    result.swiftSlotsPatched = (NSUInteger)swiftPatched;
    result.symbolsRebound = rebound;
    result.categoriesAttached = categoriesAttached;
    result.layoutChangedClasses = [layoutChanged copy];
    result.warnings = [warnings copy];

    // 5. 处理受影响的可见界面，并发出通知（当前已在主线程）
    NSArray<NSString *> *pending = nil;
    result.refreshedControllers = [NCSweeper refreshAfterPatchingClasses:patchedClasses
                                                            addedClasses:addedClasses
                                                     layoutChangedClasses:[NSSet setWithArray:layoutChanged]
                                                             sourceFiles:sourceFiles
                                                      pendingControllers:&pending];
    result.pendingControllers = pending ?: @[];
    return result;
}

/// 取类对象。Swift 类优先调用元数据访问器（...CMa），确保需要运行时初始化的元数据已初始化。
/// 先按导出符号 dlsym，查不到（局部符号）再用符号表里记下的地址
+ (void *)classPointerForSymbol:(NSString *)symbol handle:(void *)handle
                 localAddresses:(NSDictionary<NSString *, NSValue *> *)localAddresses {
    // dlsym 需要去掉前导下划线
    NSString *name = [symbol substringFromIndex:1];
    if ([name hasPrefix:@"$s"] && [name hasSuffix:@"CN"]) {
        NSString *accessorName = [[name substringToIndex:name.length - 2] stringByAppendingString:@"CMa"];
        void *accessor = dlsym(handle, accessorName.UTF8String);
        if (!accessor) {
            accessor = [localAddresses[[@"_" stringByAppendingString:accessorName]] pointerValue];
        }
        if (accessor) {
            // MetadataResponse accessor(MetadataRequest)：请求 0 表示完整元数据，返回值首字段即元数据指针
            typedef void *(*NCMetadataAccessor)(size_t request);
            void *metadata = ((NCMetadataAccessor)accessor)(0);
            if (metadata) {
                return metadata;
            }
        }
    }
    void *exported = dlsym(handle, name.UTF8String);
    if (exported) {
        return exported;
    }
    return [localAddresses[symbol] pointerValue];
}

/// 把新镜像中的静态变量寻址器重绑回旧实现，保留原有状态
+ (void)rebindStaticAddressors:(NSArray<NSString *> *)names inImage:(NCImage *)image {
    NSUInteger count = names.count;
    NCRebinding *rebindings = calloc(count, sizeof(NCRebinding));
    NSUInteger valid = 0;
    for (NSUInteger i = 0; i < count; i++) {
        const char *name = names[i].UTF8String;
        // RTLD_DEFAULT 按加载顺序查找：普通文件找到 App 中的旧实现；
        // 新增文件在 App 中没有该符号，会找到它第一次注入时（RTLD_GLOBAL）的镜像，同样保留了状态
        void *oldImpl = dlsym(RTLD_DEFAULT, name + 1);
        if (oldImpl) {
            rebindings[valid].name = name;
            rebindings[valid].replacement = oldImpl;
            valid++;
        }
    }
    if (valid > 0) {
        NCRebindImage(image, rebindings, valid);
    }
    free(rebindings);
}

/// 把 dlopen 的底层错误翻译成可读的中文提示
+ (NSString *)explainLoadError:(NSString *)raw {
    if ([raw containsString:@"symbol not found"] || [raw containsString:@"Symbol not found"]) {
        return [NSString stringWithFormat:@"加载失败：存在未解析符号（常见于 private/fileprivate 符号、默认参数，"
                @"或工程设置了 EXPORTED_SYMBOLS_FILE / -fvisibility=hidden 而 Mac 端未能桥接这些符号）。\n%@", raw];
    }
    if ([raw containsString:@"code signature"] || [raw containsString:@"not valid for use in process"]) {
        return [NSString stringWithFormat:@"加载失败：签名无效。真机需与 App 使用同一开发团队的身份签名。\n%@", raw];
    }
    if ([raw containsString:@"__llvm_profile"]) {
        return [NSString stringWithFormat:@"加载失败：代码覆盖率符号缺失。\n%@", raw];
    }
    return raw;
}

@end

#endif
