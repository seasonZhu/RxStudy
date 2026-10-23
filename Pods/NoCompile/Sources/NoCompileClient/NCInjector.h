//
//  NCInjector.h
//  进程内注入核心：dlopen 新 dylib，并把新实现嫁接回运行中的旧实现
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NCInjectStatus) {
    NCInjectStatusSuccess = 0,
    NCInjectStatusLoadFailed,       // dlopen 失败
    NCInjectStatusNothingInjected,  // 加载成功但未替换任何实现（通常缺少 -interposable）
};

@interface NCInjectResult : NSObject
@property (nonatomic) NCInjectStatus status;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic) NSUInteger objcMethodsReplaced;
@property (nonatomic) NSUInteger swiftSlotsPatched;
@property (nonatomic) NSUInteger symbolsRebound;
/// 新镜像中挂到既有类上的分类数。分类由 ObjC 运行时在 dlopen 时直接附加，同名方法随即覆盖旧实现
@property (nonatomic) NSUInteger categoriesAttached;
/// 发生内存布局变化（增删 / 重排方法或存储属性）的类名。为避免崩溃，这些类的实现不会被替换，需重新运行 App
@property (nonatomic, copy) NSArray<NSString *> *layoutChangedClasses;
/// 本次注入未能完全生效的原因（布局变化、视图结构变化等），已写入日志
@property (nonatomic, copy) NSArray<NSString *> *warnings;
/// 注入后被自动刷新的视图控制器类名
@property (nonatomic, copy) NSArray<NSString *> *refreshedControllers;
/// 受影响但未自动重建的已加载视图控制器类名，需提示用户退出页面后重新进入
@property (nonatomic, copy) NSArray<NSString *> *pendingControllers;
@end

@interface NCInjector : NSObject

/// 加载并注入一个 dylib。内部会串行执行，可在任意线程调用
+ (NCInjectResult *)injectDylibAtPath:(NSString *)dylibPath
                          sourceFiles:(nullable NSArray<NSString *> *)sourceFiles;

/// 同上。isNewFile 表示 dylib 来自 App 中原本没有的新增文件：
/// 以 RTLD_GLOBAL 加载，使之后注入的 dylib 能链接到其中的符号；没有可替换的实现也视为成功
+ (NCInjectResult *)injectDylibAtPath:(NSString *)dylibPath
                          sourceFiles:(nullable NSArray<NSString *> *)sourceFiles
                            isNewFile:(BOOL)isNewFile;

/// 同上。symbolShimPath 为 Mac 端生成的符号桥接 dylib：把 App 未导出（被隐藏）的符号按运行时地址导出，
/// 先以 RTLD_GLOBAL 加载它，注入 dylib 中对这些符号的引用才能由 dyld 解析
+ (NCInjectResult *)injectDylibAtPath:(NSString *)dylibPath
                          sourceFiles:(nullable NSArray<NSString *> *)sourceFiles
                            isNewFile:(BOOL)isNewFile
                       symbolShimPath:(nullable NSString *)symbolShimPath;

@end

NS_ASSUME_NONNULL_END
