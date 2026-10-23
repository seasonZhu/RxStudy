//
//  NCResources.m
//  资源热重载：storyboard / xib 编译产物与图片
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCResources.h"
#include <stdatomic.h>
#import "NCSweeper.h"
#import "NCLog.h"
#import "NoCompile.h"
#include <objc/runtime.h>
#include <objc/message.h>

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#define NC_UIKIT 1
typedef UIImage NCPlatformImage;
#elif __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#define NC_APPKIT 1
typedef NSImage NCPlatformImage;
#endif

@implementation NCResourceResult
@end

#pragma mark - 状态

/// 以下状态在主线程写入；hook 可能在任意线程读取，统一加锁
static NSObject *NCResourcesLock(void) {
    static NSObject *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [NSObject new];
    });
    return lock;
}

/// 资源按 bundle 管理。bundleKey：主 bundle 为 @""，其他 bundle 为其目录名（如 "ExKit.framework"）
/// 已更新的 bundle 条目：bundleKey → （相对 bundle 根目录的路径 → 新文件的绝对路径）
static NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *gBundleOverrides;
/// 已更新的图片：@"bundleKey|名字" → @{ images: 变体数组, template: 是否模板 }
static NSMutableDictionary<NSString *, NSDictionary *> *gImages;
/// 按名字缓存的新图，图片再次更新时清除
static NSMutableDictionary<NSString *, NCPlatformImage *> *gImageCache;
/// 已更新的颜色集：@"bundleKey|名字" → @{ red, green, blue, alpha, p3 }
static NSMutableDictionary<NSString *, NSDictionary *> *gColors;
/// 解析过的 .strings 文件：绝对路径 → 字典
static NSMutableDictionary<NSString *, NSDictionary *> *gStringsCache;
/// bundleKey → 真实 bundle 路径 / 当前镜像 bundle；历次镜像 bundle 路径 → bundleKey
static NSMutableDictionary<NSString *, NSString *> *gBundlePaths;
static NSMutableDictionary<NSString *, NSBundle *> *gMirrorBundles;
static NSMutableDictionary<NSString *, NSString *> *gMirrorPathKeys;
/// 快速判断，避免没有资源更新时 hook 里也加锁
static volatile BOOL gHasOverrides = NO;
static volatile BOOL gHasImages = NO;
static volatile BOOL gHasColors = NO;
static volatile BOOL gHasStrings = NO;
static NSUInteger gGeneration = 0;

/// 资源根目录在 bundle 内的相对路径：iOS 为空，macOS 为 Contents/Resources
static NSString *NCResourceSubpathOfBundle(NSBundle *bundle) {
    NSString *bundlePath = bundle.bundlePath;
    NSString *resourcePath = bundle.resourcePath;
    if (resourcePath.length > bundlePath.length && [resourcePath hasPrefix:bundlePath]) {
        return [resourcePath substringFromIndex:bundlePath.length + 1];
    }
    return @"";
}

#pragma mark - bundle 标识

/// 在已加载的 bundle 中按目录名（"ExKit.framework"）或可执行文件名查找
static NSBundle *NCFindLoadedBundle(NSString *directoryName, NSString *executableName) {
    NSMutableArray<NSBundle *> *all = [NSMutableArray arrayWithObject:NSBundle.mainBundle];
    [all addObjectsFromArray:NSBundle.allFrameworks];
    [all addObjectsFromArray:NSBundle.allBundles];
    for (NSBundle *bundle in all) {
        // 跳过 NoCompile 自己生成的镜像 bundle（它们与真实 bundle 同名，且会登记进 allBundles）
        if ([bundle.bundlePath containsString:@"/NoCompileResources/mirror_"]) {
            continue;
        }
        if (directoryName.length > 0 && [bundle.bundlePath.lastPathComponent isEqualToString:directoryName]) {
            return bundle;
        }
        if (executableName.length > 0 && [bundle.executablePath.lastPathComponent isEqualToString:executableName]) {
            return bundle;
        }
    }
    // framework 可能还没被 NSBundle 登记（动态库延迟加载），到 App 的 Frameworks 目录里找
    if (directoryName.length > 0) {
        NSString *candidate = [[NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"Frameworks"]
                               stringByAppendingPathComponent:directoryName];
        if ([NSFileManager.defaultManager fileExistsAtPath:candidate]) {
            return [NSBundle bundleWithPath:candidate];
        }
    }
    return nil;
}

/// 资源包里的 bundle 描述 → bundleKey（主 bundle 为 @""）。找不到返回 nil
static NSString *NCResolveBundleKey(NSString *hint) {
    if (hint.length == 0) {
        return @"";
    }
    NSBundle *main = NSBundle.mainBundle;
    NSString *directoryName = nil;
    NSString *executableName = nil;
    if ([hint hasPrefix:@"module:"]) {
        executableName = [hint substringFromIndex:7];
    } else {
        directoryName = hint;
    }
    if ([main.bundlePath.lastPathComponent isEqualToString:directoryName] ||
        [main.executablePath.lastPathComponent isEqualToString:executableName]) {
        return @"";
    }
    NSBundle *bundle = NCFindLoadedBundle(directoryName, executableName);
    if (!bundle) {
        return nil;
    }
    if (bundle == main) {
        return @"";
    }
    NSString *key = bundle.bundlePath.lastPathComponent;
    @synchronized (NCResourcesLock()) {
        gBundlePaths[key] = bundle.bundlePath;
    }
    return key;
}

/// 某个 NSBundle 对应的 bundleKey：主 bundle / 其镜像为 @""，有过更新的其他 bundle 为目录名，其余为 nil
static NSString *NCBundleKeyForBundle(NSBundle *bundle) {
    if (bundle == nil || bundle == NSBundle.mainBundle) {
        return @"";
    }
    if (!gHasOverrides && !gHasImages && !gHasColors && !gHasStrings) {
        return nil;
    }
    NSString *path = bundle.bundlePath;
    @synchronized (NCResourcesLock()) {
        NSString *mirrored = gMirrorPathKeys[path];
        if (mirrored) {
            return mirrored;
        }
        NSString *name = path.lastPathComponent;
        if ([gBundlePaths[name] isEqualToString:path]) {
            return name;
        }
    }
    return nil;
}

#pragma mark - 查询

/// 名字对应的已更新条目。name 为 storyboard / nib 名，ext 为 storyboardc / nib。
/// 同时匹配 xib 的设备变体（View~iphone.nib），任意 .lproj 下的条目都算
static NSString *NCOverrideItemNamed(NSString *bundleKey, NSString *name, NSString *ext) {
    if (!gHasOverrides || name.length == 0) {
        return nil;
    }
    @synchronized (NCResourcesLock()) {
        for (NSString *item in gBundleOverrides[bundleKey]) {
            NSString *file = item.lastPathComponent;
            if (![file.pathExtension isEqualToString:ext]) {
                continue;
            }
            NSString *stem = file.stringByDeletingPathExtension;
            if ([stem isEqualToString:name] || [stem hasPrefix:[name stringByAppendingString:@"~"]]) {
                return item;
            }
        }
    }
    return nil;
}

/// 文件名对应的已更新文件绝对路径（供 pathForResource: 系列使用）。
/// subdirectory 为空时匹配资源目录根部或 .lproj 下的条目，与 Xcode 拷贝资源的位置一致；
/// 指定了子目录时要求条目恰好位于该子目录
static NSString *NCOverridePathForFile(NSString *bundleKey, NSString *fileName, NSString *subdirectory) {
    if (!gHasOverrides || fileName.length == 0) {
        return nil;
    }
    @synchronized (NCResourcesLock()) {
        NSDictionary<NSString *, NSString *> *overrides = gBundleOverrides[bundleKey];
        for (NSString *item in overrides) {
            if (![item.lastPathComponent isEqualToString:fileName]) {
                continue;
            }
            NSString *directory = item.stringByDeletingLastPathComponent;
            if (subdirectory.length > 0) {
                if ([directory isEqualToString:subdirectory]) {
                    return overrides[item];
                }
                continue;
            }
            if (directory.length == 0 || [directory.pathExtension isEqualToString:@"lproj"]) {
                return overrides[item];
            }
        }
    }
    return nil;
}

/// 加载 name.ext 时应使用的 bundle：资源已更新则返回镜像 bundle，否则原样返回
static NSBundle *NCRedirectBundle(NSBundle *bundle, NSString *name, NSString *ext) {
    NSString *key = NCBundleKeyForBundle(bundle);
    if (!key || !NCOverrideItemNamed(key, name, ext)) {
        return bundle;
    }
    @synchronized (NCResourcesLock()) {
        return gMirrorBundles[key] ?: bundle;
    }
}

#pragma mark - 图片

/// 把 imageNamed: 的参数规范化为登记时的名字：去掉常见图片扩展名与倍率后缀
static NSString *NCNormalizedImageName(NSString *name) {
    static NSSet<NSString *> *extensions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        extensions = [NSSet setWithArray:@[@"png", @"jpg", @"jpeg", @"gif", @"heic", @"heif", @"webp"]];
    });
    NSString *result = name;
    if ([extensions containsObject:result.pathExtension.lowercaseString]) {
        result = result.stringByDeletingPathExtension;
    }
    NSRange at = [result rangeOfString:@"@" options:NSBackwardsSearch];
    if (at.location != NSNotFound && [result hasSuffix:@"x"]) {
        result = [result substringToIndex:at.location];
    }
    return result;
}

#if NC_UIKIT
static UIImage *NCBuildImage(NSDictionary *entry) {
    NSArray<NSDictionary *> *variants = entry[@"images"];
    NSString *idiom = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"ipad" : @"iphone";
    // 先选设备类型：精确匹配 > universal > 其余
    NSArray<NSDictionary *> *candidates = [variants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"idiom == %@", idiom]];
    if (candidates.count == 0) {
        candidates = [variants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"idiom == 'universal'"]];
    }
    if (candidates.count == 0) {
        candidates = variants;
    }
    // 再选倍率：与屏幕一致 > 最大倍率
    CGFloat screenScale = UIScreen.mainScreen.scale;
    NSDictionary *best = nil;
    for (NSDictionary *variant in candidates) {
        CGFloat scale = [variant[@"scale"] doubleValue];
        if (fabs(scale - screenScale) < 0.01) {
            best = variant;
            break;
        }
        if (!best || scale > [best[@"scale"] doubleValue]) {
            best = variant;
        }
    }
    NSData *data = best ? [NSData dataWithContentsOfFile:best[@"absolutePath"]] : nil;
    if (!data) {
        return nil;
    }
    UIImage *image = [UIImage imageWithData:data scale:MAX([best[@"scale"] doubleValue], 1)];
    if ([entry[@"template"] boolValue]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return image;
}
#else
static NSImage *NCBuildImage(NSDictionary *entry) {
    NSImage *image = nil;
    for (NSDictionary *variant in entry[@"images"]) {
        NSImageRep *rep = [NSImageRep imageRepWithContentsOfFile:variant[@"absolutePath"]];
        if (!rep) {
            continue;
        }
        CGFloat scale = MAX([variant[@"scale"] doubleValue], 1);
        NSSize size = NSMakeSize(rep.pixelsWide / scale, rep.pixelsHigh / scale);
        rep.size = size;
        if (!image) {
            image = [[NSImage alloc] initWithSize:size];
        }
        [image addRepresentation:rep];
    }
    image.template = [entry[@"template"] boolValue];
    return image;
}
#endif

/// 名字对应的新图；未更新过返回 nil。
/// bundle 为 nil 表示不关心所属 bundle（nib 解码时拿不到 bundle，按名字匹配任意 bundle 的更新）
static NCPlatformImage *NCOverrideImageNamed(NSString *name, NSString *bundleKey) {
    if (!gHasImages || name.length == 0) {
        return nil;
    }
    NSString *normalized = NCNormalizedImageName(name);
    @synchronized (NCResourcesLock()) {
        NSString *cacheKey = nil;
        NSDictionary *entry = nil;
        if (bundleKey) {
            cacheKey = [NSString stringWithFormat:@"%@|%@", bundleKey, normalized];
            entry = gImages[cacheKey];
        } else {
            // 任意 bundle：优先主 bundle，其次其他 bundle
            for (NSString *key in gImages) {
                NSArray<NSString *> *parts = [key componentsSeparatedByString:@"|"];
                if (parts.count == 2 && [parts[1] isEqualToString:normalized] && (!entry || [parts[0] isEqualToString:@""])) {
                    cacheKey = key;
                    entry = gImages[key];
                }
            }
        }
        if (!entry) {
            return nil;
        }
        NCPlatformImage *image = gImageCache[cacheKey];
        if (!image) {
            image = NCBuildImage(entry);
            if (image) {
                gImageCache[cacheKey] = image;
            }
        }
        return image;
    }
}

/// 图片查询用的 bundleKey：bundle 为主 bundle / nil 时是 @""，已更新过的其他 bundle 是其目录名，其余 NSNull（不会命中）
static NSString *NCImageBundleKey(NSBundle *bundle) {
    return NCBundleKeyForBundle(bundle) ?: @"\x01none";
}

#pragma mark - Hook

/// 替换方法实现，原实现写入 *outOriginal。
/// 必须先写好原实现、再替换：被 hook 的方法（如 pathForResource:ofType:）会在其他线程被高频调用，
/// 若先替换后赋值，替换实现在这段间隙里读到的原实现还是 NULL，调用即崩溃
static void NCHookMethod(Method method, IMP replacement, IMP *outOriginal) {
    if (!method) {
        return;
    }
    *outOriginal = method_getImplementation(method);
    atomic_thread_fence(memory_order_release);
    IMP previous = method_setImplementation(method, replacement);
    // 读取与替换之间若有别人改过实现，以替换前一刻的实现为准
    if (previous && previous != *outOriginal) {
        *outOriginal = previous;
    }
}

static void NCHookClassMethod(Class cls, SEL sel, IMP replacement, IMP *outOriginal) {
    NCHookMethod(class_getClassMethod(cls, sel), replacement, outOriginal);
}

static void NCHookInstanceMethod(Class cls, SEL sel, IMP replacement, IMP *outOriginal) {
    NCHookMethod(class_getInstanceMethod(cls, sel), replacement, outOriginal);
}

static IMP gOrigPathForResource;
static IMP gOrigURLForResource;
static IMP gOrigPathForResourceInDirectory;
static IMP gOrigURLForResourceSubdirectory;
static IMP gOrigLocalizedString;

static NSString *NCFileNameFor(NSString *name, NSString *ext) {
    return ext.length > 0 ? [name stringByAppendingPathExtension:ext] : name;
}

static NSString *NCPathForResource(NSBundle *self, SEL _cmd, NSString *name, NSString *ext) {
    NSString *key = name.length > 0 ? NCBundleKeyForBundle(self) : nil;
    NSString *path = key ? NCOverridePathForFile(key, NCFileNameFor(name, ext), nil) : nil;
    if (path) {
        return path;
    }
    return ((NSString *(*)(id, SEL, NSString *, NSString *))gOrigPathForResource)(self, _cmd, name, ext);
}

static NSURL *NCURLForResource(NSBundle *self, SEL _cmd, NSString *name, NSString *ext) {
    NSString *key = name.length > 0 ? NCBundleKeyForBundle(self) : nil;
    NSString *path = key ? NCOverridePathForFile(key, NCFileNameFor(name, ext), nil) : nil;
    if (path) {
        return [NSURL fileURLWithPath:path];
    }
    return ((NSURL *(*)(id, SEL, NSString *, NSString *))gOrigURLForResource)(self, _cmd, name, ext);
}

static NSString *NCPathForResourceInDirectory(NSBundle *self, SEL _cmd, NSString *name, NSString *ext, NSString *subpath) {
    NSString *key = name.length > 0 ? NCBundleKeyForBundle(self) : nil;
    NSString *path = key ? NCOverridePathForFile(key, NCFileNameFor(name, ext), subpath) : nil;
    if (path) {
        return path;
    }
    return ((NSString *(*)(id, SEL, NSString *, NSString *, NSString *))gOrigPathForResourceInDirectory)(self, _cmd, name, ext, subpath);
}

static NSURL *NCURLForResourceSubdirectory(NSBundle *self, SEL _cmd, NSString *name, NSString *ext, NSString *subpath) {
    NSString *key = name.length > 0 ? NCBundleKeyForBundle(self) : nil;
    NSString *path = key ? NCOverridePathForFile(key, NCFileNameFor(name, ext), subpath) : nil;
    if (path) {
        return [NSURL fileURLWithPath:path];
    }
    return ((NSURL *(*)(id, SEL, NSString *, NSString *, NSString *))gOrigURLForResourceSubdirectory)(self, _cmd, name, ext, subpath);
}

/// 本地化字符串：bundle 里某张 .strings 表被更新过时，先在新表里找
static NSString *NCOverrideLocalizedString(NSBundle *bundle, NSString *key, NSString *table) {
    if (!gHasStrings || key.length == 0) {
        return nil;
    }
    NSString *bundleKey = NCBundleKeyForBundle(bundle);
    if (!bundleKey) {
        return nil;
    }
    NSString *tableName = table.length > 0 ? table : @"Localizable";
    NSString *fileName = [tableName stringByAppendingPathExtension:@"strings"];
    NSString *chosen = nil;
    @synchronized (NCResourcesLock()) {
        NSDictionary<NSString *, NSString *> *overrides = gBundleOverrides[bundleKey];
        NSArray<NSString *> *preferred = bundle.preferredLocalizations ?: @[];
        NSString *fallback = nil;
        for (NSString *item in overrides) {
            if (![item.lastPathComponent isEqualToString:fileName]) {
                continue;
            }
            NSString *directory = item.stringByDeletingLastPathComponent;
            NSString *language = directory.stringByDeletingPathExtension;
            if (directory.length > 0 && [preferred containsObject:language]) {
                chosen = overrides[item];
                break;
            }
            if (!fallback || [language isEqualToString:@"Base"] || directory.length == 0) {
                fallback = overrides[item];
            }
        }
        chosen = chosen ?: fallback;
        if (chosen && !gStringsCache[chosen]) {
            // .strings 是 OpenStep 风格的属性列表，NSDictionary 可直接解析
            gStringsCache[chosen] = [NSDictionary dictionaryWithContentsOfFile:chosen] ?: @{};
        }
        return chosen ? gStringsCache[chosen][key] : nil;
    }
}

static NSString *NCLocalizedString(NSBundle *self, SEL _cmd, NSString *key, NSString *value, NSString *table) {
    NSString *override = NCOverrideLocalizedString(self, key, table);
    if (override) {
        return override;
    }
    return ((NSString *(*)(id, SEL, NSString *, NSString *, NSString *))gOrigLocalizedString)(self, _cmd, key, value, table);
}

/// 颜色集：@"bundleKey|名字" 命中时返回新颜色分量
static NSDictionary *NCOverrideColorEntry(NSString *name, NSBundle *bundle) {
    if (!gHasColors || name.length == 0) {
        return nil;
    }
    NSString *bundleKey = NCBundleKeyForBundle(bundle);
    if (!bundleKey) {
        return nil;
    }
    @synchronized (NCResourcesLock()) {
        return gColors[[NSString stringWithFormat:@"%@|%@", bundleKey, name]];
    }
}

#if NC_UIKIT

/// nib 中引用的图片在解码时由 UIImageNibPlaceholder（UIImage 子类）的 initWithCoder: 生成，
/// 不经过 imageNamed:。交换其 initWithCoder:，资源名已更新时返回新图
@interface UIImage (NCResources)
- (instancetype)kg_initWithCoder:(NSCoder *)coder __attribute__((objc_method_family(init)));
@end

@implementation UIImage (NCResources)

- (instancetype)kg_initWithCoder:(NSCoder *)coder {
    // 交换后这里调用的是原始的 initWithCoder:。它通常直接返回从 Asset Catalog / bundle 取到的真实图片，
    // 资源名只能从 coder 中读取（nib 中的键为 UIResourceName）
    UIImage *image = [self kg_initWithCoder:coder];
    if (!gHasImages) {
        return image;
    }
    NSString *name = nil;
    if (coder.allowsKeyedCoding && [coder containsValueForKey:@"UIResourceName"]) {
        id value = [coder decodeObjectForKey:@"UIResourceName"];
        name = [value isKindOfClass:NSString.class] ? value : nil;
    }
    UIImage *override = NCOverrideImageNamed(name, nil);
    if (!override) {
        return image;
    }
    if (image.renderingMode != UIImageRenderingModeAutomatic) {
        override = [override imageWithRenderingMode:image.renderingMode];
    }
    return override;
}

@end

static void NCHookNibImagePlaceholder(void) {
    Class cls = NSClassFromString(@"UIImageNibPlaceholder");
    Method original = cls ? class_getInstanceMethod(cls, @selector(initWithCoder:)) : NULL;
    Method replacement = class_getInstanceMethod(UIImage.class, @selector(kg_initWithCoder:));
    if (!original || !replacement) {
        return;
    }
    // 先把两个方法都加到子类上，交换时不影响 UIImage 本身
    class_addMethod(cls, @selector(initWithCoder:), method_getImplementation(original), method_getTypeEncoding(original));
    class_addMethod(cls, @selector(kg_initWithCoder:), method_getImplementation(replacement), method_getTypeEncoding(replacement));
    method_exchangeImplementations(class_getInstanceMethod(cls, @selector(initWithCoder:)),
                                   class_getInstanceMethod(cls, @selector(kg_initWithCoder:)));
}

static IMP gOrigStoryboardWithName;
static IMP gOrigNibWithName;
static IMP gOrigLoadNibNamed;
static IMP gOrigImageNamed;
static IMP gOrigImageNamedInBundleTraits;
static IMP gOrigImageNamedInBundleConfiguration;

static UIStoryboard *NCStoryboardWithName(id self, SEL _cmd, NSString *name, NSBundle *bundle) {
    return ((UIStoryboard *(*)(id, SEL, NSString *, NSBundle *))gOrigStoryboardWithName)(
        self, _cmd, name, NCRedirectBundle(bundle, name, @"storyboardc"));
}

static UINib *NCNibWithName(id self, SEL _cmd, NSString *name, NSBundle *bundle) {
    return ((UINib *(*)(id, SEL, NSString *, NSBundle *))gOrigNibWithName)(
        self, _cmd, name, NCRedirectBundle(bundle, name, @"nib"));
}

static NSArray *NCLoadNibNamed(NSBundle *self, SEL _cmd, NSString *name, id owner, NSDictionary *options) {
    NSBundle *target = NCRedirectBundle(self, name, @"nib");
    return ((NSArray *(*)(id, SEL, NSString *, id, NSDictionary *))gOrigLoadNibNamed)(target, _cmd, name, owner, options);
}

static UIImage *NCImageNamed(id self, SEL _cmd, NSString *name) {
    UIImage *image = NCOverrideImageNamed(name, @"");
    if (image) {
        return image;
    }
    return ((UIImage *(*)(id, SEL, NSString *))gOrigImageNamed)(self, _cmd, name);
}

static UIImage *NCImageNamedInBundleTraits(id self, SEL _cmd, NSString *name, NSBundle *bundle, UITraitCollection *traits) {
    UIImage *image = NCOverrideImageNamed(name, NCImageBundleKey(bundle));
    if (image) {
        return image;
    }
    return ((UIImage *(*)(id, SEL, NSString *, NSBundle *, UITraitCollection *))gOrigImageNamedInBundleTraits)(
        self, _cmd, name, bundle, traits);
}

static UIImage *NCImageNamedInBundleConfiguration(id self, SEL _cmd, NSString *name, NSBundle *bundle, id configuration) {
    UIImage *image = NCOverrideImageNamed(name, NCImageBundleKey(bundle));
    if (image) {
        return image;
    }
    return ((UIImage *(*)(id, SEL, NSString *, NSBundle *, id))gOrigImageNamedInBundleConfiguration)(
        self, _cmd, name, bundle, configuration);
}

static IMP gOrigColorNamed;
static IMP gOrigColorNamedInBundle;

static UIColor *NCColorFromEntry(NSDictionary *entry) {
    CGFloat red = [entry[@"red"] doubleValue];
    CGFloat green = [entry[@"green"] doubleValue];
    CGFloat blue = [entry[@"blue"] doubleValue];
    CGFloat alpha = [entry[@"alpha"] doubleValue];
    if ([entry[@"p3"] boolValue]) {
        return [UIColor colorWithDisplayP3Red:red green:green blue:blue alpha:alpha];
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

static UIColor *NCColorNamed(id self, SEL _cmd, NSString *name) {
    NSDictionary *entry = NCOverrideColorEntry(name, nil);
    if (entry) {
        return NCColorFromEntry(entry);
    }
    return ((UIColor *(*)(id, SEL, NSString *))gOrigColorNamed)(self, _cmd, name);
}

static UIColor *NCColorNamedInBundle(id self, SEL _cmd, NSString *name, NSBundle *bundle, UITraitCollection *traits) {
    NSDictionary *entry = NCOverrideColorEntry(name, bundle);
    if (entry) {
        return NCColorFromEntry(entry);
    }
    return ((UIColor *(*)(id, SEL, NSString *, NSBundle *, UITraitCollection *))gOrigColorNamedInBundle)(self, _cmd, name, bundle, traits);
}

static void NCInstallPlatformHooks(void) {
    NCHookClassMethod(UIColor.class, @selector(colorNamed:), (IMP)NCColorNamed, &gOrigColorNamed);
    NCHookClassMethod(UIColor.class, @selector(colorNamed:inBundle:compatibleWithTraitCollection:),
                      (IMP)NCColorNamedInBundle, &gOrigColorNamedInBundle);
    NCHookClassMethod(UIStoryboard.class, @selector(storyboardWithName:bundle:), (IMP)NCStoryboardWithName, &gOrigStoryboardWithName);
    NCHookClassMethod(UINib.class, @selector(nibWithNibName:bundle:), (IMP)NCNibWithName, &gOrigNibWithName);
    NCHookInstanceMethod(NSBundle.class, @selector(loadNibNamed:owner:options:), (IMP)NCLoadNibNamed, &gOrigLoadNibNamed);
    NCHookClassMethod(UIImage.class, @selector(imageNamed:), (IMP)NCImageNamed, &gOrigImageNamed);
    NCHookClassMethod(UIImage.class, @selector(imageNamed:inBundle:compatibleWithTraitCollection:),
                      (IMP)NCImageNamedInBundleTraits, &gOrigImageNamedInBundleTraits);
    SEL configurationSel = NSSelectorFromString(@"imageNamed:inBundle:withConfiguration:");
    NCHookClassMethod(UIImage.class, configurationSel, (IMP)NCImageNamedInBundleConfiguration, &gOrigImageNamedInBundleConfiguration);
    NCHookNibImagePlaceholder();
}

#else

static IMP gOrigStoryboardWithName;
static IMP gOrigNibInitWithName;
static IMP gOrigLoadNibNamed;
static IMP gOrigImageNamed;
static IMP gOrigImageForResource;

static NSStoryboard *NCStoryboardWithName(id self, SEL _cmd, NSString *name, NSBundle *bundle) {
    return ((NSStoryboard *(*)(id, SEL, NSString *, NSBundle *))gOrigStoryboardWithName)(
        self, _cmd, name, NCRedirectBundle(bundle, name, @"storyboardc"));
}

static id NCNibInitWithName(NSNib *self, SEL _cmd, NSString *name, NSBundle *bundle) {
    return ((id (*)(id, SEL, NSString *, NSBundle *))gOrigNibInitWithName)(
        self, _cmd, name, NCRedirectBundle(bundle, name, @"nib"));
}

static BOOL NCLoadNibNamed(NSBundle *self, SEL _cmd, NSString *name, id owner, NSArray **topLevelObjects) {
    NSBundle *target = NCRedirectBundle(self, name, @"nib");
    return ((BOOL (*)(id, SEL, NSString *, id, NSArray **))gOrigLoadNibNamed)(target, _cmd, name, owner, topLevelObjects);
}

static NSImage *NCImageNamed(id self, SEL _cmd, NSString *name) {
    NSImage *image = NCOverrideImageNamed(name, @"");
    if (image) {
        return image;
    }
    return ((NSImage *(*)(id, SEL, NSString *))gOrigImageNamed)(self, _cmd, name);
}

static NSImage *NCImageForResource(NSBundle *self, SEL _cmd, NSString *name) {
    NSImage *image = NCOverrideImageNamed(name, NCImageBundleKey(self));
    if (image) {
        return image;
    }
    return ((NSImage *(*)(id, SEL, NSString *))gOrigImageForResource)(self, _cmd, name);
}

static IMP gOrigColorNamed;
static IMP gOrigColorNamedInBundle;

static NSColor *NCColorFromEntry(NSDictionary *entry) {
    CGFloat red = [entry[@"red"] doubleValue];
    CGFloat green = [entry[@"green"] doubleValue];
    CGFloat blue = [entry[@"blue"] doubleValue];
    CGFloat alpha = [entry[@"alpha"] doubleValue];
    if ([entry[@"p3"] boolValue]) {
        return [NSColor colorWithDisplayP3Red:red green:green blue:blue alpha:alpha];
    }
    return [NSColor colorWithSRGBRed:red green:green blue:blue alpha:alpha];
}

static NSColor *NCColorNamed(id self, SEL _cmd, NSString *name) {
    NSDictionary *entry = NCOverrideColorEntry(name, nil);
    if (entry) {
        return NCColorFromEntry(entry);
    }
    return ((NSColor *(*)(id, SEL, NSString *))gOrigColorNamed)(self, _cmd, name);
}

static NSColor *NCColorNamedInBundle(id self, SEL _cmd, NSString *name, NSBundle *bundle) {
    NSDictionary *entry = NCOverrideColorEntry(name, bundle);
    if (entry) {
        return NCColorFromEntry(entry);
    }
    return ((NSColor *(*)(id, SEL, NSString *, NSBundle *))gOrigColorNamedInBundle)(self, _cmd, name, bundle);
}

static void NCInstallPlatformHooks(void) {
    NCHookClassMethod(NSColor.class, @selector(colorNamed:), (IMP)NCColorNamed, &gOrigColorNamed);
    NCHookClassMethod(NSColor.class, @selector(colorNamed:bundle:), (IMP)NCColorNamedInBundle, &gOrigColorNamedInBundle);
    NCHookClassMethod(NSStoryboard.class, @selector(storyboardWithName:bundle:), (IMP)NCStoryboardWithName, &gOrigStoryboardWithName);
    NCHookInstanceMethod(NSNib.class, @selector(initWithNibNamed:bundle:), (IMP)NCNibInitWithName, &gOrigNibInitWithName);
    NCHookInstanceMethod(NSBundle.class, @selector(loadNibNamed:owner:topLevelObjects:), (IMP)NCLoadNibNamed, &gOrigLoadNibNamed);
    NCHookClassMethod(NSImage.class, @selector(imageNamed:), (IMP)NCImageNamed, &gOrigImageNamed);
    NCHookInstanceMethod(NSBundle.class, @selector(imageForResource:), (IMP)NCImageForResource, &gOrigImageForResource);
}

#endif

/// 首次更新资源时安装 hook，进程内只做一次
static void NCInstallHooks(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gBundleOverrides = [NSMutableDictionary dictionary];
        gImages = [NSMutableDictionary dictionary];
        gImageCache = [NSMutableDictionary dictionary];
        gColors = [NSMutableDictionary dictionary];
        gStringsCache = [NSMutableDictionary dictionary];
        gBundlePaths = [NSMutableDictionary dictionary];
        gMirrorBundles = [NSMutableDictionary dictionary];
        gMirrorPathKeys = [NSMutableDictionary dictionary];
        NCHookInstanceMethod(NSBundle.class, @selector(pathForResource:ofType:), (IMP)NCPathForResource, &gOrigPathForResource);
        NCHookInstanceMethod(NSBundle.class, @selector(URLForResource:withExtension:), (IMP)NCURLForResource, &gOrigURLForResource);
        NCHookInstanceMethod(NSBundle.class, @selector(pathForResource:ofType:inDirectory:),
                             (IMP)NCPathForResourceInDirectory, &gOrigPathForResourceInDirectory);
        NCHookInstanceMethod(NSBundle.class, @selector(URLForResource:withExtension:subdirectory:),
                             (IMP)NCURLForResourceSubdirectory, &gOrigURLForResourceSubdirectory);
        NCHookInstanceMethod(NSBundle.class, @selector(localizedStringForKey:value:table:), (IMP)NCLocalizedString, &gOrigLocalizedString);
        NCInstallPlatformHooks();
    });
}

#pragma mark - 镜像 bundle

/// 在 mirrorDir 下镜像 realDir：overrides 中的条目（相对 realDir）指向新文件，其余条目软链接回原文件。
/// 只有被覆盖条目的上级目录才会真正创建，其余都是软链接，生成开销与 bundle 大小无关
static BOOL NCBuildMirror(NSString *realDir, NSString *mirrorDir, NSDictionary<NSString *, NSString *> *overrides) {
    NSFileManager *fm = NSFileManager.defaultManager;
    if (![fm createDirectoryAtPath:mirrorDir withIntermediateDirectories:YES attributes:nil error:nil]) {
        return NO;
    }
    // 按第一级路径分组：直接覆盖的叶子条目，与需要继续向下展开的目录
    NSMutableDictionary<NSString *, NSString *> *leaves = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSMutableDictionary *> *nested = [NSMutableDictionary dictionary];
    [overrides enumerateKeysAndObjectsUsingBlock:^(NSString *relative, NSString *absolute, BOOL *stop) {
        NSArray<NSString *> *components = relative.pathComponents;
        if (components.count == 1) {
            leaves[components[0]] = absolute;
        } else if (components.count > 1) {
            NSString *rest = [NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(1, components.count - 1)]];
            NSMutableDictionary *child = nested[components[0]];
            if (!child) {
                child = [NSMutableDictionary dictionary];
                nested[components[0]] = child;
            }
            child[rest] = absolute;
        }
    }];

    NSMutableOrderedSet<NSString *> *names = [NSMutableOrderedSet orderedSetWithArray:[fm contentsOfDirectoryAtPath:realDir error:nil] ?: @[]];
    [names addObjectsFromArray:leaves.allKeys];
    [names addObjectsFromArray:nested.allKeys];
    for (NSString *name in names) {
        NSString *target = [mirrorDir stringByAppendingPathComponent:name];
        NSString *real = [realDir stringByAppendingPathComponent:name];
        if (leaves[name]) {
            [fm createSymbolicLinkAtPath:target withDestinationPath:leaves[name] error:nil];
        } else if (nested[name]) {
            if (!NCBuildMirror(real, target, nested[name])) {
                return NO;
            }
        } else {
            [fm createSymbolicLinkAtPath:target withDestinationPath:real error:nil];
        }
    }
    return YES;
}

/// 按某个 bundle 当前全部已更新条目重新生成镜像 bundle。每次换新路径，避免 NSBundle 按路径缓存旧实例
static BOOL NCRebuildMirrorBundle(NSString *bundleKey) {
    NSString *bundlePath = nil;
    NSBundle *realBundle = nil;
    if (bundleKey.length == 0) {
        realBundle = NSBundle.mainBundle;
        bundlePath = realBundle.bundlePath;
    } else {
        @synchronized (NCResourcesLock()) {
            bundlePath = gBundlePaths[bundleKey];
        }
        realBundle = bundlePath ? [NSBundle bundleWithPath:bundlePath] : nil;
    }
    if (!bundlePath || !realBundle) {
        return NO;
    }
    NSString *subpath = NCResourceSubpathOfBundle(realBundle);
    NSMutableDictionary<NSString *, NSString *> *relativeToBundle = [NSMutableDictionary dictionary];
    @synchronized (NCResourcesLock()) {
        [gBundleOverrides[bundleKey] enumerateKeysAndObjectsUsingBlock:^(NSString *item, NSString *absolute, BOOL *stop) {
            relativeToBundle[subpath.length > 0 ? [subpath stringByAppendingPathComponent:item] : item] = absolute;
        }];
    }
    gGeneration++;
    NSString *root = [NSTemporaryDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"NoCompileResources/mirror_%lu", (unsigned long)gGeneration]];
    [NSFileManager.defaultManager removeItemAtPath:root error:nil];
    NSString *mirrorPath = [root stringByAppendingPathComponent:bundlePath.lastPathComponent];
    if (!NCBuildMirror(bundlePath, mirrorPath, relativeToBundle)) {
        return NO;
    }
    NSBundle *mirror = [NSBundle bundleWithPath:mirrorPath];
    if (!mirror) {
        return NO;
    }
    @synchronized (NCResourcesLock()) {
        gMirrorBundles[bundleKey] = mirror;
        gMirrorPathKeys[mirrorPath] = bundleKey;
    }
    return YES;
}

#pragma mark - NCResources

@implementation NCResources

+ (BOOL)isMirrorBundle:(NSBundle *)bundle {
    if (!bundle || !gHasOverrides) {
        return NO;
    }
    @synchronized (NCResourcesLock()) {
        return gMirrorPathKeys[bundle.bundlePath] != nil;
    }
}

/// 把资源包落到本地目录：模拟器 / macOS 已由 Mac 端拷好，真机按文件列表从 data 中切出
+ (NSString *)materialize:(NSDictionary *)json data:(NSData *)data error:(NSString **)error {
    NSString *localRoot = json[@"localRoot"];
    if ([localRoot isKindOfClass:NSString.class] && localRoot.length > 0
        && [NSFileManager.defaultManager fileExistsAtPath:localRoot]) {
        return localRoot;
    }
    NSArray<NSDictionary *> *files = json[@"files"];
    // 颜色集的数据全在 json 的 color 字段里，没有任何文件，空列表是合法的
    BOOL allowsNoFiles = [json[@"kind"] isEqual:@"colorset"];
    if (![files isKindOfClass:NSArray.class] || (files.count == 0 && !allowsNoFiles)) {
        *error = @"资源包缺少文件";
        return nil;
    }
    NSString *root = [NSTemporaryDirectory() stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"NoCompileIncoming/%@", NSUUID.UUID.UUIDString]];
    if (files.count == 0) {
        [NSFileManager.defaultManager createDirectoryAtPath:root withIntermediateDirectories:YES attributes:nil error:nil];
        return root;
    }
    NSUInteger offset = 0;
    for (NSDictionary *file in files) {
        if (![file isKindOfClass:NSDictionary.class]) {
            *error = @"资源包格式错误";
            return nil;
        }
        NSString *relative = file[@"path"];
        id lengthValue = file[@"length"];
        if (![lengthValue isKindOfClass:NSNumber.class]) {
            *error = @"资源包格式错误";
            return nil;
        }
        NSUInteger length = [lengthValue unsignedIntegerValue];
        // 先比较 length 与剩余长度，避免 offset + length 溢出后绕过检查
        if (![relative isKindOfClass:NSString.class] || relative.length == 0 || [relative containsString:@".."]
            || offset > data.length || length > data.length - offset) {
            *error = @"资源包数据不完整";
            return nil;
        }
        NSString *destination = [root stringByAppendingPathComponent:relative];
        [NSFileManager.defaultManager createDirectoryAtPath:destination.stringByDeletingLastPathComponent
                                withIntermediateDirectories:YES attributes:nil error:nil];
        if (![[data subdataWithRange:NSMakeRange(offset, length)] writeToFile:destination atomically:NO]) {
            *error = [NSString stringWithFormat:@"无法写入 %@", relative];
            return nil;
        }
        offset += length;
    }
    return root;
}

+ (NCResourceResult *)applyPackage:(NSDictionary *)json data:(NSData *)data {
    NCResourceResult *result = [NCResourceResult new];
    result.refreshedControllers = @[];
    NSString *error = nil;
    NSString *root = [self materialize:json data:data error:&error];
    if (!root) {
        result.message = error ?: @"资源包无效";
        return result;
    }
    if (NSThread.isMainThread) {
        [self applyPackage:json root:root result:result];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self applyPackage:json root:root result:result];
        });
    }
    return result;
}

+ (void)applyPackage:(NSDictionary *)json root:(NSString *)root result:(NCResourceResult *)result {
    NCInstallHooks();
    NSString *kind = json[@"kind"];
    NSString *name = json[@"name"];
    NSArray<NSString *> *items = json[@"items"];
    NSArray<NSDictionary *> *images = json[@"images"];

    // 0. 确定资源所属 bundle（主 bundle 为 @""）
    NSString *bundleKey = NCResolveBundleKey(json[@"bundle"]);
    if (!bundleKey) {
        result.message = [NSString stringWithFormat:@"找不到资源所属的 bundle：%@", json[@"bundle"]];
        return;
    }

    // 1. 登记 bundle 条目并重建镜像 bundle（storyboard / nib / 原样拷贝的文件）
    if (items.count > 0) {
        @synchronized (NCResourcesLock()) {
            NSMutableDictionary<NSString *, NSString *> *overrides = gBundleOverrides[bundleKey];
            if (!overrides) {
                overrides = [NSMutableDictionary dictionary];
                gBundleOverrides[bundleKey] = overrides;
            }
            for (NSString *item in items) {
                overrides[item] = [root stringByAppendingPathComponent:item];
                if ([item.pathExtension isEqualToString:@"strings"]) {
                    gHasStrings = YES;
                }
            }
        }
        gHasOverrides = YES;
        if (!NCRebuildMirrorBundle(bundleKey)) {
            result.message = @"无法生成镜像 bundle";
            return;
        }
    }

    // 2. 登记图片
    if ([kind isEqualToString:@"image"]) {
        NSMutableArray<NSDictionary *> *variants = [NSMutableArray array];
        for (NSDictionary *image in images) {
            NSMutableDictionary *variant = [image mutableCopy];
            variant[@"absolutePath"] = [root stringByAppendingPathComponent:image[@"path"]];
            [variants addObject:variant];
        }
        NSString *key = [NSString stringWithFormat:@"%@|%@", bundleKey, NCNormalizedImageName(name)];
        @synchronized (NCResourcesLock()) {
            gImages[key] = @{ @"images": variants, @"template": json[@"template"] ?: @NO };
            [gImageCache removeObjectForKey:key];
        }
        gHasImages = YES;
    }

    // 3. 登记颜色集
    if ([kind isEqualToString:@"colorset"] && [json[@"color"] isKindOfClass:NSDictionary.class]) {
        @synchronized (NCResourcesLock()) {
            gColors[[NSString stringWithFormat:@"%@|%@", bundleKey, name]] = json[@"color"];
        }
        gHasColors = YES;
    }

    // 4. 刷新可见界面
    NSArray<NSString *> *pending = nil;
    result.refreshedControllers = [NCSweeper refreshAfterResourceKind:kind name:name pendingControllers:&pending];
    result.pendingControllers = pending ?: @[];
    result.ok = YES;
}

@end

#endif
