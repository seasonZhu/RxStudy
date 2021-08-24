//
//  Provider.swift
//  RxStudy
//
//  Created by dy on 2021/8/24.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

/// 集中管理provider

let homeProvider: MoyaProvider<HomeService> = {
        let stubClosure = { (target: HomeService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<HomeService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()


let myProvider: MoyaProvider<MyService> = {
        let stubClosure = { (target: MyService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<MyService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()

let projectProvider: MoyaProvider<ProjectService> = {
        let stubClosure = { (target: ProjectService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<ProjectService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()

let publicNumberProvider: MoyaProvider<PublicNumberService> = {
        let stubClosure = { (target: PublicNumberService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<PublicNumberService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()

let treeProvider: MoyaProvider<TreeService> = {
        let stubClosure = { (target: TreeService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<TreeService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()

let accountProvider: MoyaProvider<AccountService> = {
        let stubClosure = { (target: AccountService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<AccountService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()
