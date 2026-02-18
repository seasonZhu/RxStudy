//
//  AccountService.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

public enum AccountService {
    case login(_ username: String, _ password: String, _ showLoading: Bool)
    case register(_ username: String, _ password: String, _ repassword: String)
    case logout
}

extension AccountService: TargetType {
    public var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }

    public var path: String {
        switch self {
        case .login:
            return Api.Account.login
        case .register:
            return Api.Account.register
        case .logout:
            return Api.Account.logout
        }
    }

    public var method: Moya.Method {
        switch self {
        case .logout:
            return .get
        default:
            return .post
        }
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        switch self {
        case let .login(username, password, _):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: URLEncoding.default)
        case let .register(username, password, repassword):
            return .requestParameters(parameters: ["username": username, "password": password, "repassword": repassword], encoding: URLEncoding.default)
        case .logout:
            return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
        }
    }

    public var headers: [String: String]? {
        switch self {
        case let .login(_, _, showLoading):
            return ["showLoading": "\(showLoading)"]
        default:
            return nil
        }
    }
}
