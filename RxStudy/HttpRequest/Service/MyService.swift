//
//  MyService.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

let myProvider: MoyaProvider<MyService> = {
        let stubClosure = { (target: MyService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<MyService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
}()


enum MyService {
    case coinRank(_ page: Int)
    case userCoinInfo
    case myCoinList(_ page: Int)
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .coinRank, .userCoinInfo, .myCoinList:
            return .get
                            
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .coinRank, .userCoinInfo, .myCoinList:
            return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return loginHeader
    }
}
