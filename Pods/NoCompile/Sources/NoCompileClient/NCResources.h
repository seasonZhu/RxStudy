//
//  NCResources.h
//  资源热重载：storyboard / xib 编译产物与图片
//
//  App bundle 在真机上只读，因此不直接改写 bundle，而是在 tmp 下生成一个"镜像 bundle"：
//  被更新的条目指向新文件，其余条目软链接回原 bundle（Assets.car、其他 nib 都还在，nib 里引用的图片照常解析）。
//  再 hook storyboard / nib 的加载入口，凡是加载已更新资源的请求都改用镜像 bundle；
//  图片则按名字登记，hook imageNamed: 系列方法直接返回新图。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCResourceResult : NSObject
@property (nonatomic) BOOL ok;
@property (nonatomic, copy) NSString *message;
/// 资源更新后被刷新的视图控制器类名
@property (nonatomic, copy) NSArray<NSString *> *refreshedControllers;
/// 受影响但未自动重建的已加载视图控制器类名，需提示用户退出页面后重新进入
@property (nonatomic, copy) NSArray<NSString *> *pendingControllers;
@end

@interface NCResources : NSObject

/// 应用 Mac 端下发的资源包（可在任意线程调用，替换与刷新在主线程执行）
/// @param json 资源描述：kind、name、items、images、template，以及 localRoot 或 files
/// @param data 真机传输时各文件内容的拼接，顺序与 json[@"files"] 一致
+ (NCResourceResult *)applyPackage:(NSDictionary *)json data:(nullable NSData *)data;

/// 是否为 NoCompile 生成的镜像 bundle
+ (BOOL)isMirrorBundle:(nullable NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
