//
//  TestModule.m
//  HelloUniMPDemo
//
//  Created by XHY on 2020/2/14.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "TestModule.h"

@implementation TestModule
@synthesize weexInstance;

// 通过宏 WX_EXPORT_METHOD 将异步方法暴露给 js 端
WX_EXPORT_METHOD(@selector(testAsyncFunc:callback:))

// 通过宏 WX_EXPORT_METHOD_SYNC 将同步方法暴露给 js 端
WX_EXPORT_METHOD_SYNC(@selector(testSyncFunc:))

/// 异步方法（注：异步方法会在主线程（UI线程）执行）
/// @param options js 端调用方法时传递的参数
/// @param callback 回调方法，回传参数给 js 端
- (void)testAsyncFunc:(NSDictionary *)options callback:(WXModuleKeepAliveCallback)callback {
    // options 为 js 端调用此方法时传递的参数
    NSLog(@"%@",options);
    
    // 可以在该方法中实现原生能力，然后通过 callback 回调到 js
    
    // 回调方法，传递参数给 js 端 注：只支持返回 String 或 NSDictionary (map) 类型
    if (callback) {
        // 第一个参数为回传给js端的数据，第二个参数为标识，表示该回调方法是否支持多次调用，如果原生端需要多次回调js端则第二个参数传 YES;
        callback(@"success",NO);
    }
}


/// 同步方法（注：同步方法会在 js 线程执行）
/// @param options js 端调用方法时传递的参数
- (NSString *)testSyncFunc:(NSDictionary *)options {
    // options 为 js 端调用此方法时传递的参数
    NSLog(@"%@",options);
    
    /*
     可以在该方法中实现原生功能，然后直接通过 return 返回参数给 js
     */
    
    // 同步返回参数给 js 端 注：只支持返回 String 或 NSDictionary (map) 类型
    return @"success";
}

@end
