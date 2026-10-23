//
//  NCSweeper.m
//  注入后的零侵入刷新
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCSweeper.h"
#import "NCLog.h"
#import "NoCompile.h"
#include <objc/runtime.h>
#include <objc/message.h>

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#define NC_UIKIT 1
typedef UIViewController NCViewController;
typedef UIView NCView;
#elif __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#define NC_APPKIT 1
typedef NSViewController NCViewController;
typedef NSView NCView;
#endif

#if NC_APPKIT
/// 重新加载 AppKit storyboard 视图 nib 期间使用的外部对象表（仅在主线程的重载过程中非空）
static NSDictionary<NSString *, id> *gPendingExternalObjects;

/// AppKit 的 NSNib 没有传入外部对象的公开接口。nib 中的外部对象占位（NSNibExternalObjectPlaceholder）
/// 在 initWithCoder: 中按标识查找真实对象，重载期间改为从 gPendingExternalObjects 中取
@interface NCExternalPlaceholderHook : NSObject
- (id)kg_initWithCoder:(NSCoder *)coder __attribute__((objc_method_family(init)));
@end

@implementation NCExternalPlaceholderHook

- (id)kg_initWithCoder:(NSCoder *)coder {
    NSDictionary *table = gPendingExternalObjects;
    if (table && coder.allowsKeyedCoding) {
        id identifier = [coder decodeObjectForKey:@"NSExternalObjectPlaceholderIdentifier"];
        id object = [identifier isKindOfClass:NSString.class] ? table[identifier] : nil;
        if (object) {
            return object;
        }
    }
    // 交换后这里调用的是原始的 initWithCoder:
    return [self kg_initWithCoder:coder];
}

@end

static BOOL NCInstallExternalPlaceholderHook(void) {
    static BOOL installed = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"NSNibExternalObjectPlaceholder");
        Method original = cls ? class_getInstanceMethod(cls, @selector(initWithCoder:)) : NULL;
        Method replacement = class_getInstanceMethod(NCExternalPlaceholderHook.class, @selector(kg_initWithCoder:));
        if (!original || !replacement) {
            return;
        }
        class_addMethod(cls, @selector(initWithCoder:), method_getImplementation(original), method_getTypeEncoding(original));
        class_addMethod(cls, @selector(kg_initWithCoder:), method_getImplementation(replacement), method_getTypeEncoding(replacement));
        method_exchangeImplementations(class_getInstanceMethod(cls, @selector(initWithCoder:)),
                                       class_getInstanceMethod(cls, @selector(kg_initWithCoder:)));
        installed = YES;
    });
    return installed;
}
#endif

@implementation NCSweeper

+ (NSArray<NSString *> *)refreshAfterPatchingClasses:(NSArray<Class> *)patchedClasses
                                        addedClasses:(NSArray<Class> *)addedClasses
                                  layoutChangedClasses:(NSSet<NSString *> *)layoutChangedClasses
                                         sourceFiles:(NSArray<NSString *> *)sourceFiles
                                  pendingControllers:(NSArray<NSString *> **)outPending {
    // 以类名作为匹配依据：App 中的实例属于旧类，dylib 中的是新类，二者名字相同
    NSMutableSet<NSString *> *names = [NSMutableSet set];
    for (Class cls in patchedClasses) {
        [names addObject:@(class_getName(cls))];
    }

    NSMutableArray<NSString *> *refreshed = [NSMutableArray array];

    // 1. 兼容项：+injected。同名类可能有多份（主程序与历次注入的镜像各一份），每个类名只调用一次
    SEL injectedSel = NSSelectorFromString(@"injected");
    NSMutableSet<NSString *> *notified = [NSMutableSet set];
    for (Class cls in patchedClasses) {
        if (![notified containsObject:@(class_getName(cls))] && class_respondsToSelector(object_getClass(cls), injectedSel)) {
            [notified addObject:@(class_getName(cls))];
            ((void (*)(id, SEL))objc_msgSend)(cls, injectedSel);
        }
    }

    NSMutableArray<NSString *> *pending = [NSMutableArray array];
#if NC_UIKIT || NC_APPKIT
    // 2. 处理受影响的可见视图控制器：默认不重建已加载的控制器，只记下类名提示用户重进页面；
    //    开启 autoReloadViewControllers 后才原地重建
    [refreshed addObjectsFromArray:[self reloadAffectedControllersForClassNames:names
                                                             layoutChangedClasses:layoutChangedClasses
                                                                          pending:pending]];
#endif
    if (outPending) {
        *outPending = [pending copy];
    }

    // 3. 通知：供 SwiftUI 或其他需要自定义刷新的场景使用
    NSMutableArray *all = [patchedClasses mutableCopy];
    [all addObjectsFromArray:addedClasses];
    NSDictionary *userInfo = sourceFiles ? @{ NoCompileInjectedFilesKey: sourceFiles } : @{};
    [NSNotificationCenter.defaultCenter postNotificationName:NoCompileDidInjectNotification
                                                      object:all userInfo:userInfo];
    [NSNotificationCenter.defaultCenter postNotificationName:NoCompileInjectionBundleNotification
                                                      object:all userInfo:userInfo];
    return refreshed;
}

+ (NSArray<NSString *> *)refreshAfterResourceKind:(NSString *)kind
                                             name:(NSString *)name
                               pendingControllers:(NSArray<NSString *> **)outPending {
    NSMutableArray<NSString *> *refreshed = [NSMutableArray array];
    NSMutableArray<NSString *> *pending = [NSMutableArray array];
#if NC_UIKIT || NC_APPKIT
    {
        NSArray<NCViewController *> *visible = [self visibleControllers];
        NSMutableArray<NCViewController *> *targets = [NSMutableArray array];
        for (NCViewController *controller in visible) {
            if (![self isAppClass:controller.class] || !controller.isViewLoaded) {
                continue;
            }
            if ([kind isEqualToString:@"storyboard"] && controller.storyboard &&
                [[self nameOfStoryboard:controller.storyboard] isEqualToString:name]) {
                [targets addObject:controller];
            } else if ([kind isEqualToString:@"nib"] && !controller.storyboard &&
                       ([controller.nibName isEqualToString:name] ||
                        [controller.nibName hasPrefix:[name stringByAppendingString:@"~"]])) {
                [targets addObject:controller];
            }
        }
        // xib 用于 cell / 自定义视图、图片被代码引用：刷新最上层的可见业务控制器。
        // storyboard 没有可见的控制器时无需刷新，之后进入页面时会加载新版本
        if (targets.count == 0 && ![kind isEqualToString:@"storyboard"]) {
            NCViewController *top = [self topAppControllerIn:visible];
            if (top) {
                [targets addObject:top];
            }
        }
        [refreshed addObjectsFromArray:[self refreshControllers:[self outermostControllers:targets]
                                             layoutChangedClasses:nil
                                                          pending:pending]];
    }
#endif
    if (outPending) {
        *outPending = [pending copy];
    }
    // 通知：object 为空数组（没有类被替换），userInfo 中带上资源名
    NSDictionary *userInfo = @{ NoCompileInjectedFilesKey: @[name ?: @""] };
    [NSNotificationCenter.defaultCenter postNotificationName:NoCompileDidInjectNotification
                                                      object:@[] userInfo:userInfo];
    [NSNotificationCenter.defaultCenter postNotificationName:NoCompileInjectionBundleNotification
                                                      object:@[] userInfo:userInfo];
    return refreshed;
}

#pragma mark - 类名匹配

/// 判断类（含父类链）是否命中被替换的类名
+ (BOOL)classChain:(Class)cls hitsNames:(NSSet<NSString *> *)names {
    Class current = cls;
    while (current) {
        if ([names containsObject:@(class_getName(current))]) {
            return YES;
        }
        current = class_getSuperclass(current);
    }
    return NO;
}

/// 判断类是否属于 App 自身（排除系统框架中的容器控制器等）
+ (BOOL)isAppClass:(Class)cls {
    const char *image = class_getImageName(cls);
    if (!image) {
        return NO;
    }
    return strncmp(image, "/System/", 8) != 0
        && strncmp(image, "/usr/lib/", 9) != 0
        && strstr(image, "/Developer/Library/") == NULL
        && strstr(image, "/Library/Developer/CoreSimulator/Volumes/") == NULL
        && strstr(image, ".simruntime/") == NULL;
}

#if NC_UIKIT || NC_APPKIT

#pragma mark - 可见控制器收集

+ (NSArray<NCViewController *> *)rootControllers {
    NSMutableArray<NCViewController *> *roots = [NSMutableArray array];
#if NC_UIKIT
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class]) {
            continue;
        }
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (!window.hidden && window.rootViewController) {
                [roots addObject:window.rootViewController];
            }
        }
    }
#else
    for (NSWindow *window in NSApplication.sharedApplication.windows) {
        if (window.isVisible && window.contentViewController) {
            [roots addObject:window.contentViewController];
        }
    }
#endif
    return roots;
}

/// 从根控制器出发收集当前可见的控制器（含容器与其可见子控制器）
+ (void)collectVisibleFrom:(NCViewController *)controller into:(NSMutableArray<NCViewController *> *)result {
    if (!controller || [result containsObject:controller]) {
        return;
    }
    [result addObject:controller];
#if NC_UIKIT
    if ([controller isKindOfClass:UINavigationController.class]) {
        [self collectVisibleFrom:((UINavigationController *)controller).topViewController into:result];
    } else if ([controller isKindOfClass:UITabBarController.class]) {
        [self collectVisibleFrom:((UITabBarController *)controller).selectedViewController into:result];
    } else {
        for (UIViewController *child in controller.childViewControllers) {
            [self collectVisibleFrom:child into:result];
        }
    }
    [self collectVisibleFrom:controller.presentedViewController into:result];
#else
    for (NSViewController *child in controller.childViewControllers) {
        [self collectVisibleFrom:child into:result];
    }
    for (NSViewController *presented in controller.presentedViewControllers) {
        [self collectVisibleFrom:presented into:result];
    }
#endif
}

/// 控制器自身视图层级中（不含子控制器的视图）是否有被替换的视图类
+ (BOOL)controller:(NCViewController *)controller ownsViewHittingNames:(NSSet<NSString *> *)names {
    if (!controller.isViewLoaded) {
        return NO;
    }
    NSMutableSet<NCView *> *childRoots = [NSMutableSet set];
    for (NCViewController *child in controller.childViewControllers) {
        if (child.isViewLoaded) {
            [childRoots addObject:child.view];
        }
    }
    NSMutableArray<NCView *> *stack = [NSMutableArray arrayWithObject:controller.view];
    while (stack.count > 0) {
        NCView *view = stack.lastObject;
        [stack removeLastObject];
        if ([self classChain:view.class hitsNames:names]) {
            return YES;
        }
        for (NCView *sub in view.subviews) {
            if (![childRoots containsObject:sub]) {
                [stack addObject:sub];
            }
        }
    }
    return NO;
}

#pragma mark - 刷新

+ (NSArray<NCViewController *> *)visibleControllers {
    NSMutableArray<NCViewController *> *visible = [NSMutableArray array];
    for (NCViewController *root in [self rootControllers]) {
        [self collectVisibleFrom:root into:visible];
    }
    return visible;
}

/// 最上层的可见业务控制器
+ (nullable NCViewController *)topAppControllerIn:(NSArray<NCViewController *> *)visible {
    for (NCViewController *controller in visible.reverseObjectEnumerator) {
        if ([self isAppClass:controller.class] && controller.isViewLoaded) {
            return controller;
        }
    }
    return nil;
}

/// 父控制器重建时会重新创建子控制器，子控制器无需单独处理
+ (NSArray<NCViewController *> *)outermostControllers:(NSArray<NCViewController *> *)targets {
    NSMutableArray<NCViewController *> *result = [NSMutableArray array];
    for (NCViewController *controller in targets) {
        BOOL ancestorIncluded = NO;
        NCViewController *parent = controller.parentViewController;
        while (parent) {
            if ([targets containsObject:parent]) {
                ancestorIncluded = YES;
                break;
            }
            parent = parent.parentViewController;
        }
        if (!ancestorIncluded && ![result containsObject:controller]) {
            [result addObject:controller];
        }
    }
    return result;
}

/// 逐个处理受影响的控制器，返回已刷新的类名：
/// - 实现了 -injected 的交给业务自己处理；
/// - 控制器自身发生布局变化（增删方法或存储属性）时，不在旧实例上重跑 viewDidLoad——
///   旧实例的 vtable 槽位数与大小都已固定，新代码按新布局访问会越界。这类控制器跳过并提示；
/// - 其余控制器默认不重建（已加载的页面保持原样），类名放入 pending，由调用方提示用户退出页面后重新进入；
///   开启 autoReloadViewControllers 后才原地重建界面
+ (NSArray<NSString *> *)refreshControllers:(NSArray<NCViewController *> *)controllers
                       layoutChangedClasses:(nullable NSSet<NSString *> *)layoutChangedClasses
                                    pending:(NSMutableArray<NSString *> *)pending {
    NSMutableArray<NSString *> *refreshed = [NSMutableArray array];
    SEL injectedSel = NSSelectorFromString(@"injected");
    for (NCViewController *controller in controllers) {
        NSString *name = NSStringFromClass(controller.class);
        if ([layoutChangedClasses containsObject:name]) {
            // 控制器自身的内存布局变了：新代码没有替换进来（注入时已提示重新运行 App），不在旧实例上刷新
            NCLogLocal(NCLogLevelWarning, @"%@ 的内存布局变了，未在屏幕上的旧实例上刷新，重新运行 App 后生效", name);
            continue;
        }
        NSString *shortName = [name componentsSeparatedByString:@"."].lastObject;
        if ([controller respondsToSelector:injectedSel]) {
            // 兼容项：业务方自定义了刷新逻辑
            ((void (*)(id, SEL))objc_msgSend)(controller, injectedSel);
        } else if (NoCompile.autoReloadViewControllers && ![self isContainerController:controller]) {
            [self reloadController:controller];
        } else {
            // 默认不自动重建已加载的控制器：新代码已生效，重新进入页面（新建实例）即可看到改动
            if (![pending containsObject:shortName]) {
                [pending addObject:shortName];
            }
            continue;
        }
        [refreshed addObject:shortName];
    }
    return refreshed;
}

+ (NSArray<NSString *> *)reloadAffectedControllersForClassNames:(NSSet<NSString *> *)names
                                             layoutChangedClasses:(nullable NSSet<NSString *> *)layoutChangedClasses
                                                          pending:(NSMutableArray<NSString *> *)pending {
    NSArray<NCViewController *> *visible = [self visibleControllers];

    // 只处理 App 自己的控制器，系统容器（导航、标签栏等）不重建
    NSMutableArray<NCViewController *> *targets = [NSMutableArray array];
    for (NCViewController *controller in visible) {
        if (![self isAppClass:controller.class]) {
            continue;
        }
        if ([self classChain:controller.class hitsNames:names] ||
            [self controller:controller ownsViewHittingNames:names]) {
            [targets addObject:controller];
        }
    }

    // 被替换的是模型、工具类、C/C++ 函数等非界面代码：刷新最上层的可见业务控制器，让新逻辑立即体现
    if (targets.count == 0) {
        NCViewController *top = [self topAppControllerIn:visible];
        if (top) {
            [targets addObject:top];
        }
    }
    return [self refreshControllers:[self outermostControllers:targets]
                 layoutChangedClasses:layoutChangedClasses
                              pending:pending];
}

/// 容器控制器（导航、标签栏、分栏、翻页的子类）不原地重建：重建会移除全部子控制器，等于清空导航栈
+ (BOOL)isContainerController:(NCViewController *)controller {
#if NC_UIKIT
    return [controller isKindOfClass:UINavigationController.class] || [controller isKindOfClass:UITabBarController.class]
        || [controller isKindOfClass:UISplitViewController.class] || [controller isKindOfClass:UIPageViewController.class];
#elif NC_APPKIT
    return [controller isKindOfClass:NSTabViewController.class] || [controller isKindOfClass:NSSplitViewController.class]
        || [controller isKindOfClass:NSPageController.class];
#else
    return NO;
#endif
}

/// 判断类是否重写了 -loadView（自定义根视图的控制器需要重新 loadView）
+ (BOOL)overridesLoadView:(Class)cls {
    SEL sel = @selector(loadView);
    IMP own = class_getMethodImplementation(cls, sel);
    IMP base = class_getMethodImplementation([NCViewController class], sel);
    return own != base;
}

/// 重建一个控制器的界面
+ (void)reloadController:(NCViewController *)controller {
    if (!controller.isViewLoaded) {
        return;
    }
    // 界面来自 storyboard / xib：重新加载 nib（资源更新后会加载新 nib）。
    // 重新加载失败时保持原样：清空子视图再走 viewDidLoad 会丢掉 nib 中的全部内容
    if (controller.nibName.length > 0) {
        if (![self reloadControllerFromNib:controller]) {
            NCLogWarn(@"%@ 的界面来自 nib，未能自动重建，返回后重新进入该页面即可看到改动",
                      NSStringFromClass(controller.class));
        }
        return;
    }
    NCView *oldView = controller.view;

#if NC_UIKIT
    // 列表类控制器：根视图本身是 table / collection，重载数据即可
    if ([oldView isKindOfClass:UITableView.class]) {
        [(UITableView *)oldView reloadData];
        return;
    }
    if ([oldView isKindOfClass:UICollectionView.class]) {
        [(UICollectionView *)oldView reloadData];
        return;
    }
#endif

    [self removeChildControllersOf:controller];

    if ([self overridesLoadView:controller.class]) {
        // 自定义根视图：重新 loadView，并把新视图放回原位置
        [self replaceRootViewOf:controller oldView:oldView];
    } else {
        for (NCView *sub in oldView.subviews.copy) {
            [sub removeFromSuperview];
        }
    }

    // 重新走一遍生命周期
#if NC_UIKIT
    [controller viewDidLoad];
    [controller viewWillAppear:NO];
    [controller.view setNeedsLayout];
    [controller.view layoutIfNeeded];
    [controller viewDidAppear:NO];
#else
    [controller viewDidLoad];
    [controller viewWillAppear];
    controller.view.needsLayout = YES;
    [controller.view layoutSubtreeIfNeeded];
    [controller viewDidAppear];
#endif
}

#pragma mark - 从 nib 重建

/// storyboard 的文件名（私有属性，取不到时返回 nil）
+ (nullable NSString *)nameOfStoryboard:(id)storyboard {
    for (NSString *key in @[@"name", @"storyboardFileName"]) {
        @try {
            id value = [storyboard valueForKey:key];
            if ([value isKindOfClass:NSString.class]) {
                return value;
            }
        } @catch (NSException *exception) {
            continue;
        }
    }
    return nil;
}

/// storyboard 所在 bundle（私有属性，取不到时按主 bundle 处理）。
/// AppKit 的 NSStoryboard 记录的是 .storyboardc 目录本身，需要换算回包含它的 bundle
+ (NSBundle *)bundleOfStoryboard:(id)storyboard {
    NSBundle *bundle = nil;
    @try {
        id value = [storyboard valueForKey:@"bundle"];
        if ([value isKindOfClass:NSBundle.class]) {
            bundle = value;
        }
    } @catch (NSException *exception) {
        bundle = nil;
    }
    NSString *path = bundle.bundlePath;
    if (!bundle || ![path.pathExtension isEqualToString:@"storyboardc"]) {
        return bundle ?: NSBundle.mainBundle;
    }
    // 位于主 bundle 或其镜像 bundle 中：按主 bundle 处理，由 NCResources 决定是否改用镜像
    if ([path hasPrefix:[NSBundle.mainBundle.bundlePath stringByAppendingString:@"/"]] ||
        [path containsString:@"/NoCompileResources/mirror_"]) {
        return NSBundle.mainBundle;
    }
    NSSet<NSString *> *bundleExtensions = [NSSet setWithArray:@[@"app", @"framework", @"bundle", @"appex"]];
    while (path.length > 1) {
        path = path.stringByDeletingLastPathComponent;
        if ([bundleExtensions containsObject:path.pathExtension]) {
            return [NSBundle bundleWithPath:path] ?: NSBundle.mainBundle;
        }
    }
    return NSBundle.mainBundle;
}

/// 移除子控制器（viewDidLoad 会重新添加）
+ (void)removeChildControllersOf:(NCViewController *)controller {
    for (NCViewController *child in controller.childViewControllers.copy) {
#if NC_UIKIT
        [child willMoveToParentViewController:nil];
#endif
        [child.view removeFromSuperview];
        [child removeFromParentViewController];
    }
}

/// 重新实例化控制器的 nib，把新视图换到旧视图的位置并重走生命周期。
/// 加载入口已被 NCResources hook，资源更新过时会自动改用镜像 bundle 中的新 nib。
/// 涉及系统私有行为，任何异常都只记录日志并回退到普通刷新，不能让 App 崩溃
+ (BOOL)reloadControllerFromNib:(NCViewController *)controller {
    @try {
        return [self unsafeReloadControllerFromNib:controller];
    } @catch (NSException *exception) {
        NCLogWarn(@"重新加载 %@ 的 nib 失败：%@", NSStringFromClass(controller.class), exception.reason);
        return NO;
    }
}

+ (BOOL)unsafeReloadControllerFromNib:(NCViewController *)controller {
    NSString *nibName = controller.nibName;
    id storyboard = controller.storyboard;
    NCView *oldView = controller.view;
#if NC_UIKIT
    UINib *nib = nil;
    NSDictionary *options = nil;
    UIStoryboard *freshStoryboard = nil;
    if (storyboard) {
        NSString *storyboardName = [self nameOfStoryboard:storyboard];
        if (!storyboardName) {
            return NO;
        }
        UIStoryboard *fresh = [UIStoryboard storyboardWithName:storyboardName bundle:[self bundleOfStoryboard:storyboard]];
        SEL nibSel = NSSelectorFromString(@"nibForStoryboardNibNamed:");
        if (![fresh respondsToSelector:nibSel]) {
            return NO;
        }
        nib = ((UINib *(*)(id, SEL, NSString *))objc_msgSend)(fresh, nibSel, nibName);
        // storyboard 中视图 nib 不以 File's Owner 引用控制器，而是引用场景里的"上游占位对象"
        // （UpstreamPlaceholder-N → 控制器等）。UIKit 实例化场景时把这张表存在控制器上，加载视图时作为外部对象传入
        NSMutableDictionary *external = [NSMutableDictionary dictionary];
        Ivar tableIvar = class_getInstanceVariable(UIViewController.class, "_externalObjectsTableForViewLoading");
        id table = tableIvar ? object_getIvar(controller, tableIvar) : nil;
        if ([table isKindOfClass:NSDictionary.class]) {
            [external addEntriesFromDictionary:table];
        }
        external[@"UIStoryboardPlaceholder"] = fresh;
        options = @{ UINibExternalObjects: external };
        freshStoryboard = fresh;
    } else {
        nib = [UINib nibWithNibName:nibName bundle:controller.nibBundle];
    }
    if (!nib) {
        return NO;
    }
    UIView *superview = oldView.superview;
    CGRect frame = oldView.frame;
    UIViewAutoresizing mask = oldView.autoresizingMask;
    @try {
        [nib instantiateWithOwner:controller options:options];
    } @catch (NSException *exception) {
        NCLogWarn(@"重新加载 %@ 的 nib 失败：%@", NSStringFromClass(controller.class), exception.reason);
        return NO;
    }
    UIView *newView = controller.view;
    if (newView == oldView) {
        return NO;
    }
    // 之后由该控制器发起的 segue、instantiateViewController 也使用新 storyboard
    SEL setStoryboardSel = NSSelectorFromString(@"_setStoryboard:");
    if (freshStoryboard && [controller respondsToSelector:setStoryboardSel]) {
        ((void (*)(id, SEL, id))objc_msgSend)(controller, setStoryboardSel, freshStoryboard);
    }
    [self removeChildControllersOf:controller];
    newView.frame = frame;
    newView.autoresizingMask = mask;
    if (superview) {
        [superview insertSubview:newView aboveSubview:oldView];
        [oldView removeFromSuperview];
    }
    [controller viewDidLoad];
    [controller viewWillAppear:NO];
    [newView setNeedsLayout];
    [newView layoutIfNeeded];
    [controller viewDidAppear:NO];
    return YES;
#else
    NSNib *nib = nil;
    NSDictionary *external = nil;
    NSStoryboard *freshStoryboard = nil;
    if (storyboard) {
        NSString *storyboardName = [self nameOfStoryboard:storyboard];
        if (!storyboardName) {
            return NO;
        }
        NSStoryboard *fresh = [NSStoryboard storyboardWithName:storyboardName bundle:[self bundleOfStoryboard:storyboard]];
        SEL nibSel = NSSelectorFromString(@"nibForStoryboardNibNamed:");
        if (![fresh respondsToSelector:nibSel]) {
            return NO;
        }
        nib = ((NSNib *(*)(id, SEL, NSString *))objc_msgSend)(fresh, nibSel, nibName);
        // storyboard 的视图 nib 以"上游占位对象"引用场景中的控制器（UpstreamPlaceholder-1），outlet 都从它连出。
        // AppKit 不像 UIKit 那样在控制器上保存这张表，这里按约定映射；场景中还有其他对象时会解码失败并回退
        if (!NCInstallExternalPlaceholderHook()) {
            return NO;
        }
        external = @{ @"UpstreamPlaceholder-1": controller };
        freshStoryboard = fresh;
    } else {
        nib = [[NSNib alloc] initWithNibNamed:nibName bundle:controller.nibBundle];
    }
    if (!nib) {
        return NO;
    }
    NSWindow *window = oldView.window;
    BOOL isContentView = window && window.contentView == oldView;
    NSView *superview = oldView.superview;
    NSRect frame = oldView.frame;
    NSAutoresizingMaskOptions mask = oldView.autoresizingMask;
    NSArray *topLevelObjects = nil;
    BOOL loaded = NO;
    gPendingExternalObjects = external;
    @try {
        loaded = [nib instantiateWithOwner:controller topLevelObjects:&topLevelObjects];
    } @catch (NSException *exception) {
        NCLogWarn(@"重新加载 %@ 的 nib 失败：%@", NSStringFromClass(controller.class), exception.reason);
        loaded = NO;
    } @finally {
        gPendingExternalObjects = nil;
    }
    if (!loaded) {
        return NO;
    }
    NSView *newView = controller.view;
    if (newView == oldView) {
        return NO;
    }
    // 之后由该控制器发起的 segue 也使用新 storyboard
    SEL setStoryboardSel = NSSelectorFromString(@"setStoryboard:");
    if (freshStoryboard && [controller respondsToSelector:setStoryboardSel]) {
        ((void (*)(id, SEL, id))objc_msgSend)(controller, setStoryboardSel, freshStoryboard);
    }
    [self removeChildControllersOf:controller];
    if (isContentView) {
        window.contentView = newView;
    } else if (superview) {
        newView.frame = frame;
        newView.autoresizingMask = mask;
        [superview addSubview:newView positioned:NSWindowAbove relativeTo:oldView];
        [oldView removeFromSuperview];
    }
    [controller viewDidLoad];
    [controller viewWillAppear];
    newView.needsLayout = YES;
    [newView layoutSubtreeIfNeeded];
    [controller viewDidAppear];
    return YES;
#endif
}

+ (void)replaceRootViewOf:(NCViewController *)controller oldView:(NCView *)oldView {
#if NC_UIKIT
    UIView *superview = oldView.superview;
    CGRect frame = oldView.frame;
    UIViewAutoresizing mask = oldView.autoresizingMask;
    [controller loadView];
    UIView *newView = controller.view;
    if (newView == oldView) {
        return;
    }
    newView.frame = frame;
    newView.autoresizingMask = mask;
    if (superview) {
        [superview insertSubview:newView aboveSubview:oldView];
        [oldView removeFromSuperview];
    }
#else
    NSWindow *window = oldView.window;
    BOOL isContentView = window && window.contentView == oldView;
    NSView *superview = oldView.superview;
    NSRect frame = oldView.frame;
    NSAutoresizingMaskOptions mask = oldView.autoresizingMask;
    [controller loadView];
    NSView *newView = controller.view;
    if (newView == oldView) {
        return;
    }
    if (isContentView) {
        window.contentView = newView;
    } else if (superview) {
        newView.frame = frame;
        newView.autoresizingMask = mask;
        [superview addSubview:newView positioned:NSWindowAbove relativeTo:oldView];
        [oldView removeFromSuperview];
    }
#endif
}

#endif

@end

#endif
