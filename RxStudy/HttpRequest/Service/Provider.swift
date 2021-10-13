//
//  Provider.swift
//  RxStudy
//
//  Created by dy on 2021/8/24.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

/// 插件
let requestLoadingPlugin = RequestLoadingPlugin()

/// 集中管理provider
/// StubBehavior的默认值就是never,所以不用特地去写

/// 首页
let homeProvider = MoyaProvider<HomeService>(plugins: [requestLoadingPlugin])

/// 我的
let myProvider = MoyaProvider<MyService>(plugins: [requestLoadingPlugin])

/// 项目
let projectProvider = MoyaProvider<ProjectService>(plugins: [requestLoadingPlugin])

/// 公众号
let publicNumberProvider = MoyaProvider<PublicNumberService>(plugins: [requestLoadingPlugin])

/// 体系
let treeProvider = MoyaProvider<TreeService>(plugins: [requestLoadingPlugin])

/// 账号
let accountProvider = MoyaProvider<AccountService>(plugins: [requestLoadingPlugin])
