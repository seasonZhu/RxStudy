//
//  NCSweeper.h
//  注入后的零侵入刷新
//
//  默认行为（无需在业务代码里写任何东西）：
//  找到当前可见、且受本次注入影响的视图控制器（自身类被替换，或其视图层级里有被替换的视图类）。
//  已加载的控制器不自动重建，只返回其类名，由调用方提示用户退出页面后重新进入（新建实例即用上新代码）。
//  开启 NoCompile.autoReloadViewControllers 后，才会清空其视图并重新走
//  viewDidLoad → viewWillAppear → viewDidAppear，原地按新代码重建。
//
//  兼容项（可选）：若类实现了 InjectionIII 风格的 -injected / +injected，则优先调用它们。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCSweeper : NSObject

/// 在主线程执行刷新，返回被刷新的视图控制器类名（用于提示）
/// @param patchedClasses 被替换实现的旧类（App 中正在使用的类对象）
/// @param addedClasses   本次新增的类
/// @param layoutChangedClasses 发生布局变化（增删方法或存储属性）的控制器类名集合。
///        这些控制器在屏幕上的旧实例，其 vtable 槽位数与实例大小都已固定，重跑 viewDidLoad
///        可能按新槽位越界或访问越界，刷新时会跳过它们并提示（重新运行 App 或返回后重新进入）。
///        仅改方法体、布局未变的类照常处理
/// @param outPending 受影响、但未自动重建的已加载控制器类名，需提示用户退出页面后重新进入
+ (NSArray<NSString *> *)refreshAfterPatchingClasses:(NSArray<Class> *)patchedClasses
                                        addedClasses:(NSArray<Class> *)addedClasses
                                layoutChangedClasses:(nullable NSSet<NSString *> *)layoutChangedClasses
                                         sourceFiles:(nullable NSArray<NSString *> *)sourceFiles
                                  pendingControllers:(NSArray<NSString *> * _Nullable * _Nullable)outPending;

/// 判断类是否属于 App 自身（排除系统框架中的类）
+ (BOOL)isAppClass:(Class)cls;

/// 资源更新后在主线程刷新界面，返回被刷新的视图控制器类名
/// @param kind storyboard / nib / image
/// @param name storyboard 名、nib 名或图片名。storyboard / nib 优先刷新由它加载的可见控制器，
///             找不到（如 xib 用于 cell、图片被代码引用）时刷新最上层的可见业务控制器
/// @param outPending 受影响、但未自动重建的已加载控制器类名，需提示用户退出页面后重新进入
+ (NSArray<NSString *> *)refreshAfterResourceKind:(NSString *)kind
                                             name:(NSString *)name
                               pendingControllers:(NSArray<NSString *> * _Nullable * _Nullable)outPending;

@end

NS_ASSUME_NONNULL_END
