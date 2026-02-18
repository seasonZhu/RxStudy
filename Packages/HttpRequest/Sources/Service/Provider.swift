//
//  Provider.swift
//  RxStudy
//
//  Created by dy on 2021/8/24.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import HUD

import Moya
import SVProgressHUD

/// 官方的打印日志插件,感觉没有AlamofireNetworkActivityLogger好用
let loggerPlugin = NetworkLoggerPlugin()

/// 在黑名单的Api,不进行loading操作
let blackList = [Api.Home.banner, Api.Home.topArticle, Api.My.unreadCount]

/// loading开始与取消插件
let activityPlugin = NetworkActivityPlugin { state, targetType in

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

// let responseInterceptorPlugin = ResponseInterceptorPlugin()

/// 插件集合
let plugins: [PluginType] = [activityPlugin]

/// 集中管理provider
/// StubBehavior的默认值就是never,所以不用特地去写

/// 首页
public let homeProvider = MoyaProvider<HomeService>(plugins: plugins)

/// 我的
public let myProvider = MoyaProvider<MyService>(plugins: plugins)

/// 项目
public let projectProvider = MoyaProvider<ProjectService>(plugins: plugins)

/// 公众号
public let publicNumberProvider = MoyaProvider<PublicNumberService>(plugins: plugins)

/// 体系
public let treeProvider = MoyaProvider<TreeService>(plugins: plugins)

/// 账号
public let accountProvider = MoyaProvider<AccountService>(plugins: plugins)

/// 其他
public let otherProvider = MoyaProvider<OtherService>(plugins: plugins)

/// 教程
public let courseProvider = MoyaProvider<CourseService>(plugins: plugins)

/// 假数据业务
public let fakeProvider = MoyaProvider<HomeService>(stubClosure: MoyaProvider<HomeService>.immediatelyStub, plugins: plugins)
