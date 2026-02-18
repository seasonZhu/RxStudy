//
//  MyService.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

public enum MyService {
    case coinRank(_ page: Int)
    case userCoinInfo
    case myCoinList(_ page: Int)
    case collectArticleList(_ page: Int)
    case collectArticle(_ collectId: Int)
    case unCollectArticle(_ collectId: Int)
    case unreadCount
    case unreadList(_ page: Int)
    case readList(_ page: Int)
}

extension MyService: TargetType {
    public var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }

    public var path: String {
        switch self {
        case let .coinRank(page):
            return Api.My.coinRank + page.toString + "/json"
        case .userCoinInfo:
            return Api.My.userCoinInfo
        case let .myCoinList(page):
            return Api.My.myCoinList + page.toString + "/json"
        case let .collectArticleList(page):
            return Api.My.collectArticleList + page.toString + "/json"
        case let .collectArticle(collectId):
            return Api.My.collectArticle + collectId.toString + "/json"
        case let .unCollectArticle(collectId):
            return Api.My.unCollectArticle + collectId.toString + "/json"
        case .unreadCount:
            return Api.My.unreadCount
        case let .unreadList(page):
            return Api.My.unreadList + page.toString + "/json"
        case let .readList(page):
            return Api.My.readList + page.toString + "/json"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .coinRank, .userCoinInfo, .myCoinList, .collectArticleList, .unreadCount, .unreadList, .readList:
            return .get
        case .collectArticle, .unCollectArticle:
            return .post
        }
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
    }

    public var headers: [String: String]? { loginHeader }
}
