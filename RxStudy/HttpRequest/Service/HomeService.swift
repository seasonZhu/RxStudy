//
//  HomeService.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

let homeProvider: MoyaProvider<HomeService> = {
        let stubClosure = { (target: HomeService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<HomeService>(stubClosure: stubClosure)
}()

enum HomeService {
    case banner

    case topArticle

    case normalArticle(_ page: Int)
    
    case hotKey

    case queryKeyword(_ keyword: String, _ page: Int)
}


extension HomeService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .banner:
            return Api.Home.banner
        case .topArticle:
            return Api.Home.topArticle
        case .normalArticle(let page):
            return Api.Home.normalArticle + page.toString + "/json"
        case .hotKey:
            return Api.Home.hotKey
        case .queryKeyword(let keyword, let page):
            return Api.Home.queryKeyword + page.toString + "/json" + "?k=" + keyword
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .banner:
            return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        case .topArticle:
            return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        case .normalArticle(_):
            return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        case .hotKey:
            return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        case .queryKeyword(_, _):
            return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
