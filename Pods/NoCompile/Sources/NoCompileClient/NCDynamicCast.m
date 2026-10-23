//
//  NCDynamicCast.m
//  类型判定修复
//
//  被注入后，dylib 内 [Foo new] 得到的是"新 Foo"，App 其余代码持有的是"旧 Foo"，
//  两者不是同一个 Class 对象。这会让 isKindOfClass: / isMemberOfClass: 判定失败。
//  这里登记新旧类的等价关系，并改写判定逻辑使其按"原始类"比较。
//
//  覆盖范围：ObjC 的 -isKindOfClass: / -isMemberOfClass:，以及 Swift 对 ObjC 类（NSObject 子类）的 as?
//  （运行时经 swift_dynamicCastObjCClass 走 -isKindOfClass:）。纯 Swift 类的 as? 由 swift_dynamicCastClass
//  直接比较元数据的父类链，不经过这里；为此注入时不重绑 Swift 类的分配构造器（见 NCInjector），
//  旧代码创建的仍是旧类实例，避免出现"新类实例被旧代码 as? 判定"的情况。
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import <Foundation/Foundation.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <stdatomic.h>
#include <pthread.h>

@interface NCDynamicCastInstaller : NSObject
+ (void)install;
@end

/// 新类 → 原始（最初的）类 的映射。
/// isKindOfClass: 每帧被调用成千上万次，读取不能加锁：映射以不可变快照发布，读者原子地取当前快照；
/// 写入（只在注入时发生）加锁复制出新快照再替换。旧快照不释放（数量很少），读者无需担心被释放
static _Atomic(CFDictionaryRef) gAliasSnapshot = NULL;
static pthread_mutex_t gAliasWriteLock = PTHREAD_MUTEX_INITIALIZER;

/// 在给定快照里把类归一到它的原始类（别名登记时已直接指向最初的类，查一次即可）
static Class NCCanonicalClassIn(CFDictionaryRef snapshot, Class cls) {
    if (!snapshot || !cls) {
        return cls;
    }
    const void *mapped = CFDictionaryGetValue(snapshot, (__bridge const void *)cls);
    return mapped ? (__bridge Class)mapped : cls;
}

void NCRegisterClassAlias(Class newClass, Class oldClass) {
    if (!newClass || !oldClass || newClass == oldClass) {
        return;
    }
    pthread_mutex_lock(&gAliasWriteLock);
    CFDictionaryRef current = atomic_load_explicit(&gAliasSnapshot, memory_order_acquire);
    CFMutableDictionaryRef next = current
        ? CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, current)
        : CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
    // 记录到「旧类的原始类」，保证多次注入后仍指向最初的类
    CFDictionarySetValue(next, (__bridge const void *)newClass, (__bridge const void *)NCCanonicalClassIn(current, oldClass));
    CFDictionaryRef published = CFDictionaryCreateCopy(kCFAllocatorDefault, next);
    CFRelease(next);
    atomic_store_explicit(&gAliasSnapshot, published, memory_order_release);
    pthread_mutex_unlock(&gAliasWriteLock);
    [NCDynamicCastInstaller install];
}

@implementation NCDynamicCastInstaller

+ (void)install {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstance:@selector(isKindOfClass:) with:@selector(nc_isKindOfClass:)];
        [self swizzleInstance:@selector(isMemberOfClass:) with:@selector(nc_isMemberOfClass:)];
    });
}

+ (void)swizzleInstance:(SEL)original with:(SEL)replacement {
    Class cls = NSObject.class;
    Method originalMethod = class_getInstanceMethod(cls, original);
    Method replacementMethod = class_getInstanceMethod(self, replacement);
    if (!originalMethod || !replacementMethod) {
        return;
    }
    IMP replacementImp = method_getImplementation(replacementMethod);
    const char *types = method_getTypeEncoding(originalMethod);
    // 把替换实现加到 NSObject 上
    class_replaceMethod(cls, original, replacementImp, types);
}

// 下面两个方法会以 NSObject 实例方法的身份被调用，self 为被判定对象

- (BOOL)nc_isKindOfClass:(Class)aClass {
    CFDictionaryRef snapshot = atomic_load_explicit(&gAliasSnapshot, memory_order_acquire);
    Class targetCanonical = NCCanonicalClassIn(snapshot, aClass);
    // 沿继承链逐级归一：父类也可能是某次注入产生的新类
    for (Class current = object_getClass(self); current; current = class_getSuperclass(current)) {
        if (NCCanonicalClassIn(snapshot, current) == targetCanonical) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)nc_isMemberOfClass:(Class)aClass {
    CFDictionaryRef snapshot = atomic_load_explicit(&gAliasSnapshot, memory_order_acquire);
    return NCCanonicalClassIn(snapshot, object_getClass(self)) == NCCanonicalClassIn(snapshot, aClass);
}

@end

#endif
