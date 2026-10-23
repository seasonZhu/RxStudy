//
//  NCBoot.m
//  自动启动：镜像加载后在 +load 中拉起客户端
//
//  SPM / CocoaPods / Carthage 链接，或 bundle / DYLD_INSERT_LIBRARIES 方式加载时，
//  都无需在 App 代码里写启动调用。
//  通过 XCODE_RUNNING_FOR_PREVIEWS、单元测试等环境变量判断是否应跳过。
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NoCompile.h"
#import <Foundation/Foundation.h>
#include <stdlib.h>

@interface NCBoot : NSObject
@end

@implementation NCBoot

+ (void)load {
    @autoreleasepool {
        NSDictionary<NSString *, NSString *> *env = NSProcessInfo.processInfo.environment;

        // SwiftUI Preview 环境下不启动
        if ([env[@"XCODE_RUNNING_FOR_PREVIEWS"] isEqualToString:@"1"]) {
            return;
        }
        // 单元测试环境下默认不启动（除非显式开启）
        if (env[@"XCTestConfigurationFilePath"] != nil && env[@"NOCOMPILE_ENABLE_IN_TESTS"] == nil) {
            return;
        }
        // 显式禁用
        if ([env[@"NOCOMPILE_DISABLE"] isEqualToString:@"1"]) {
            return;
        }
        // 同一进程里可能同时存在多份客户端（例如既链接了 SPM 库又加载了 bundle），只启动第一份
        if (getenv("NOCOMPILE_CLIENT_BOOTED") != NULL) {
            NSLog(@"[NoCompile] 检测到重复加载的客户端，已忽略：%@", [NSBundle bundleForClass:self].bundlePath);
            return;
        }
        setenv("NOCOMPILE_CLIENT_BOOTED", "1", 1);

        NSString *host = env[@"NOCOMPILE_HOST"];
        // 延后到启动完成，避免干扰 App 自身的初始化
        dispatch_async(dispatch_get_main_queue(), ^{
            if (host.length > 0) {
                [NoCompile startWithHost:host];
            } else {
                [NoCompile start];
            }
        });
    }
}

@end

#endif
