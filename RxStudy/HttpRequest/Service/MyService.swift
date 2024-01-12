//
//  MyService.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

enum MyService {
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
    var baseURL: URL {
        return URL(string: Api.baseUrl)!        
    }
    
    var path: String {
        switch self {
        case .coinRank(let page):
            return Api.My.coinRank + page.toString + "/json"
        case .userCoinInfo:
            return Api.My.userCoinInfo
        case .myCoinList(let page):
            return Api.My.myCoinList + page.toString + "/json"
        case .collectArticleList(let page):
            return Api.My.collectArticleList + page.toString + "/json"
        case .collectArticle(let collectId):
            return Api.My.collectArticle + collectId.toString + "/json"
        case .unCollectArticle(let collectId):
            return Api.My.unCollectArticle + collectId.toString + "/json"
        case .unreadCount:
            return Api.My.unreadCount
        case .unreadList(let page):
            return Api.My.unreadList + page.toString + "/json"
        case .readList(let page):
            return Api.My.readList + page.toString + "/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .coinRank, .userCoinInfo, .myCoinList, .collectArticleList, .unreadCount, .unreadList, .readList:
            return .get
        case .collectArticle, .unCollectArticle:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? { loginHeader }
}
