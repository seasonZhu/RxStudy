//
//  NCStaticState.h
//  迁移 C / ObjC 文件作用域的 static 变量状态
//

#import "NCMachO.h"

NS_ASSUME_NONNULL_BEGIN

/// 新镜像里的零初始化 static 变量（`static NSInteger gCount;`、`static dispatch_once_t onceToken;`、
/// 方法里的 `static Foo *instance;` 等）在旧镜像中有对应变量且已被运行时改写过时，把旧值搬进新镜像。
///
/// 为什么需要：dlopen 的新镜像带着自己的一份 static 存储。不迁移的话，修改带 `+sharedInstance` 的
/// 文件后，新代码里的 dispatch_once 会再跑一次，单例被重建、计数清零。
///
/// 只迁移"新值全为 0、旧值非 0"的变量：
/// - 零初始化的初值就是 0，旧值非 0 说明运行时写过，必须保留；
/// - 带非零初值的变量（`static NSString *name = @"x"`）不迁移，源码里改了初值应当生效；
/// - 有 C++ 动态初始化的对象（std::map 等）新值非 0，自然被跳过，避免拷贝自引用结构。
///
/// 变量按"同一源文件（编译单元）内的同名符号"配对：旧镜像里靠调试符号（STAB）的 N_SO/N_STSYM 定位编译单元，
/// 因为方法内 static 变量的符号名只有 `方法名.变量名`（如 `sharedInstance.instance`），不同文件之间大量重名。
///
/// 返回迁移的变量个数。
NSUInteger NCTransferStaticState(NCImage *newImage, NSArray<NCImage *> *oldImages, NSArray<NSString *> *sourceFiles);

NS_ASSUME_NONNULL_END
