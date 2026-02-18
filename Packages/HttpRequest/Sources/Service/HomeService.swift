//
//  HomeService.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

public enum HomeService {
    case banner

    case topArticle

    case normalArticle(_ page: Int)

    case hotKey

    case queryKeyword(_ keyword: String, _ page: Int)
}

extension HomeService: TargetType {
    public var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }

    public var path: String {
        switch self {
        case .banner:
            return Api.Home.banner
        case .topArticle:
            return Api.Home.topArticle
        case let .normalArticle(page):
            return Api.Home.normalArticle + page.toString + "/json"
        case .hotKey:
            return Api.Home.hotKey
        case let .queryKeyword(_, page):
            return Api.Home.queryKeyword + page.toString + "/json"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .queryKeyword:
            return .post
        default:
            return .get
        }
    }

    public var sampleData: Data {
        switch self {
        case .hotKey:
            return try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "HotKey", ofType: "json")!))
        default:
            return Data()
        }
    }

    public var task: Task {
        switch self {
        case .banner:
            return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
        case .topArticle:
            return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
        case .normalArticle:
            return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
        case .hotKey:
            return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
        case let .queryKeyword(keyword, _):
            return .requestParameters(parameters: ["k": keyword], encoding: URLEncoding.default)
        }
    }

    public var headers: [String: String]? { nil }
}
