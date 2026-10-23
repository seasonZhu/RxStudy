//
//  NoCompile.h
//  NoCompile 客户端公开接口
//
//  只在 DEBUG 下生效。接入后无需写任何代码：客户端会在镜像加载时自动启动，
//  模拟器 / macOS 主动连接本机的 NoCompile.app，真机则同时监听 USB 通道。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 每次注入完成后在主线程发出，object 为本次被替换的类数组（NSArray<Class>）
FOUNDATION_EXPORT NSNotificationName const NoCompileDidInjectNotification;

/// 与 InjectionIII / Inject / HotSwiftUI 兼容的通知名，已有项目无需改动即可刷新
FOUNDATION_EXPORT NSNotificationName const NoCompileInjectionBundleNotification;

/// userInfo 中的键：本次注入涉及的源文件路径数组
FOUNDATION_EXPORT NSString * const NoCompileInjectedFilesKey;

/// 实现了该协议的类，在注入后会收到回调，用来刷新界面或状态
@protocol NoCompileInjectable <NSObject>
@optional
/// 对存活的实例调用（通过视图层级与对象图遍历找到）
- (void)injected;
/// 对被替换的类本身调用
+ (void)injected;
@end

@interface NoCompile : NSObject

/// 手动启动。通常不需要调用，客户端会在加载时自动启动
+ (void)start;

/// 指定 Mac 地址启动，适用于真机通过 Wi-Fi 连接的场景
+ (void)startWithHost:(NSString *)host;

/// 注入后是否自动重建当前可见、且未实现 -injected 的视图控制器，默认 NO。
/// 关闭时已加载的页面保持原样，NoCompile 会提示退出页面后重新进入（新建实例即用上新代码）
@property (class, nonatomic) BOOL autoReloadViewControllers;

/// 注入后是否把旧镜像中的静态 / 全局变量值迁移到新镜像，默认 YES（避免单例被重建）
@property (class, nonatomic) BOOL preserveStaticState;

/// 是否显示注入状态浮层（仅 iOS / tvOS），默认 YES
@property (class, nonatomic) BOOL showsHUD;

/// 加载新镜像期间，是否拦截 +load 中的 method swizzling，防止重复交换导致死循环，默认 YES
@property (class, nonatomic) BOOL suppressSwizzlingDuringLoad;

/// 已成功注入的次数
@property (class, nonatomic, readonly) NSUInteger injectionCount;

/// 是否已与 Mac 端建立连接
@property (class, nonatomic, readonly, getter=isConnected) BOOL connected;

@end

NS_ASSUME_NONNULL_END
