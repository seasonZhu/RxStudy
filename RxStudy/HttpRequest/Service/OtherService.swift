//
//  OtherService.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

import Moya

enum OtherService {
    case tools
    
    case questionAndAnswer(_ page: Int)
}

extension OtherService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .tools:
            return Api.Other.tools
        case .questionAndAnswer(let page):
            return Api.Other.questionAndAnswer + page.toString + "/json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
        
    }
    
    var headers: [String : String]? { nil }
}
