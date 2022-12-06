//
//  Provider.swift
//  RxStudy
//
//  Created by dy on 2021/8/24.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya
import SVProgressHUD

/// 自己写的插件瞬间不香了
let requestLoadingPlugin = RequestLoadingPlugin()

/// 官方的打印日志插件,感觉没有AlamofireNetworkActivityLogger好用
let loggerPlugin = NetworkLoggerPlugin()

/// 在黑名单的Api,不进行loading操作
let blackList = [Api.Home.banner, Api.Home.topArticle, Api.My.unreadCount]

/// loading开始与取消插件
let activityPlugin = NetworkActivityPlugin { (state, targetType) in
    
    /// 添加无网络拦截
    if AccountManager.shared.networkIsReachableRelay.value == false {
        SVProgressHUD.showText("似乎已断开与互联网的连接")
        return
    }
    
    if blackList.contains(targetType.path) {
        return
    }
    
    if let showLoading = targetType.headers?["showLoading"],
       showLoading == "false" {
        return
    }
    
    switch state {
    case .began:
        SVProgressHUD.beginLoading()
    case .ended:
        SVProgressHUD.stopLoading()
    }
}


let responseInterceptorPlugin = ResponseInterceptorPlugin()

/// 插件集合
let plugins: [PluginType] = [activityPlugin, responseInterceptorPlugin]

/// 集中管理provider
/// StubBehavior的默认值就是never,所以不用特地去写

/// 首页
let homeProvider = MoyaProvider<HomeService>(plugins: plugins)

/// 我的
let myProvider = MoyaProvider<MyService>(plugins: plugins)

/// 项目
let projectProvider = MoyaProvider<ProjectService>(plugins: plugins)

/// 公众号
let publicNumberProvider = MoyaProvider<PublicNumberService>(plugins: plugins)

/// 体系
let treeProvider = MoyaProvider<TreeService>(plugins: plugins)

/// 账号
let accountProvider = MoyaProvider<AccountService>(plugins: plugins)

/// 其他
let otherProvider = MoyaProvider<OtherService>(plugins: plugins)

/// 教程
//let courseProvider = MoyaProvider<CourseService>(plugins: plugins)

/// mock数据业务
let mockProvider = MoyaProvider(stubClosure: MoyaProvider<MockService>.immediatelyStub)

/// 每个provider使用相同的plugins/closures,需要额外的工作来管理它.
/// 然而,我们可以使用MutiTarget这个内置枚举,它可以很容易的使用,而且能帮我们解决上面的问题.
/// 有了这个,除了mockProvider,其他的都可以不要了 https://www.hangge.com/blog/cache/detail_1817.html
let provider = MoyaProvider<MultiTarget>(plugins: plugins)

/*
homeProvider.request(.banner) { result in
    
}

provider.request(MultiTarget(HomeService.banner)) { result in
    
}
*/
