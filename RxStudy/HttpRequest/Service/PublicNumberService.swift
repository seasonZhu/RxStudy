//
//  PublicNumberService.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

enum PublicNumberService {
    case tags
    case tagList(_ id: Int, _ page: Int)
}

extension PublicNumberService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .tags:
            return Api.PublicNumber.tags
        case .tagList(let id, let page):
            return Api.PublicNumber.tagList + id.toString + "/" + page.toString + "/json"
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
    
    var headers: [String : String]? {
        return nil
    }
}

