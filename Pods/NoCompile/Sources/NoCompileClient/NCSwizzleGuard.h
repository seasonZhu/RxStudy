//
//  NCSwizzleGuard.h
//  dlopen 期间拦截 +load 中的 method swizzling
//
//  被注入的 dylib 会重新执行类与分类的 +load。若其中做了 method_exchangeImplementations，
//  再次交换会让 hook 链自我指向，造成无限递归。加载期间把交换类函数改写为幂等行为。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 安装对 runtime swizzle 函数的重绑（进程生命周期内只需一次）
void NCSwizzleGuardInstall(void);

/// 进入 / 退出保护区间（配对调用，可重入）。path 是正在 dlopen 的注入镜像路径：
/// 交换的两个方法实现都在该镜像内时（类给自己的方法做 swizzle，只影响新镜像里的那份类对象）照常交换，
/// 否则（分类去 hook 旧类 / 系统类）说明 hook 链早已建立，跳过
void NCSwizzleGuardBegin(const char *path);
void NCSwizzleGuardEnd(void);

NS_ASSUME_NONNULL_END
