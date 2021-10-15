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

/// loading开始与取消插件
let activityPlugin = NetworkActivityPlugin { (state, targetType) in
    switch state {
    case .began:
        SVProgressHUD.beginLoading()
    case .ended:
        SVProgressHUD.stopLoading()
    }
}

/// 插件集合
let plugins: [PluginType] = [activityPlugin, loggerPlugin]

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
