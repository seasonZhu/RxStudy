//
//  ProjectService.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

enum ProjectService {
    case tags
    case tagList(_ id: Int, _ page: Int)
}

extension ProjectService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .tags:
            return Api.Project.tags
        case .tagList(_, let page):
            return Api.Project.tagList + page.toString + "/json"
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
        case .tags:
            return .requestPlain
        case .tagList(let id, _):
            return .requestParameters(parameters: ["cid": id.toString], encoding: URLEncoding.default)
        }
        
    }
    
    var headers: [String : String]? { nil }
}
