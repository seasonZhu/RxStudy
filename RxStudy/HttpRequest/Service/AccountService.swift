//
//  AccountService.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

let accountProvider: MoyaProvider<AccountService> = {
        let stubClosure = { (target: AccountService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<AccountService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()

enum AccountService {
    case login(_ username: String, _ password: String)
    case register(_ username: String, _ password: String, _ repassword: String)
    case logout
}

extension AccountService: TargetType {
    
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .login:
            return Api.Account.login
        case .register:
            return Api.Account.register
        case .logout:
            return Api.Account.logout
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .logout:
            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login(let username, let password):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: URLEncoding.default)
        case .register(let username, let password, let repassword):
            return .requestParameters(parameters: ["username": username, "password": password, "repassword": repassword], encoding: URLEncoding.default)
        case .logout:
            return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        
        }
        
    }
    
    var headers: [String : String]? {
        return nil
    }
}
