//
//  Provider.swift
//  RxStudy
//
//  Created by dy on 2021/8/24.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya
#if canImport(RxMoya)
import RxMoya
#endif
#if canImport(CombineMoya)
import CombineMoya
#endif

/// 将AlamofireNetworkActivityLogger改造成Moya插件进行使用
@MainActor let networkRequestLoggerPlugin = NetworkRequestLoggerPlugin(level: .debug)

/// 官方的打印日志插件,没有AlamofireNetworkActivityLogger好用,AlamofireNetworkActivityLogger打印的更为清晰
@MainActor let loggerPlugin = NetworkLoggerPlugin.verbose

/// 从RxNetworks改造过来的打印插件
@MainActor let debuggingPlugin = NetworkDebuggingPlugin()

/// 响应拦截器插件
@MainActor let responseInterceptorPlugin = ResponseInterceptorPlugin()

/// 响应缓存插件
@MainActor let responseCachePlugin = ResponseCachePlugin()

/// 插件集合
@MainActor let plugins: [PluginType] = [responseInterceptorPlugin, responseCachePlugin]

/// 集中管理provider
/// StubBehavior的默认值就是never,所以不用特地去写

/// 首页
@MainActor let homeProvider = LoadingProvider<HomeService>(plugins: plugins)

/// 我的
@MainActor let myEndpointClosure = { (target: MyService) -> Endpoint in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
    return defaultEndpoint.adding(newHTTPHeaderFields: AccountManager.requestHeaders ?? .empty)
}

@MainActor let myProvider = LoadingProvider<MyService>(endpointClosure: myEndpointClosure, plugins: plugins)

/// 项目
@MainActor let projectProvider = LoadingProvider<ProjectService>(plugins: plugins)

/// 公众号
@MainActor let publicNumberProvider = LoadingProvider<PublicNumberService>(plugins: plugins)

/// 体系
@MainActor let treeProvider = LoadingProvider<TreeService>(plugins: plugins)

/// 账号
@MainActor let accountProvider = LoadingProvider<AccountService>(plugins: plugins)

/// 其他
@MainActor let otherProvider = LoadingProvider<OtherService>(plugins: plugins)

/// 教程
// let courseProvider = MoyaProvider<CourseService>(plugins: plugins)

/// mock数据业务
@MainActor let mockProvider = MoyaProvider(stubClosure: MoyaProvider<MockService>.immediatelyStub)

/// 每个provider使用相同的plugins/closures,需要额外的工作来管理它.
/// 然而,我们可以使用MutiTarget这个内置枚举,它可以很容易的使用,而且能帮我们解决上面的问题.
/// 有了这个,除了mockProvider,其他的都可以不要了 https://www.hangge.com/blog/cache/detail_1817.html
@MainActor let provider = LoadingProvider<MultiTarget>(plugins: plugins)

/*
homeProvider.request(.banner) { result in
    
}

provider.request(MultiTarget(HomeService.banner)) { result in
    
}
*/
