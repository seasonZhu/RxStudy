//
//  TreeService.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

let treeProvider: MoyaProvider<TreeService> = {
        let stubClosure = { (target: TreeService) -> StubBehavior in
            return .never
        }
        return MoyaProvider<TreeService>(stubClosure: stubClosure)
}()

enum TreeService {
    case tags
    case tagList(_ id: Int, _ page: Int)
}

extension TreeService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .tags:
            return Api.Tree.tags
        case .tagList(let id, let page):
            return Api.Tree.tagList + page.toString + "/json" + "?cid=" + id.toString
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
        
    }
    
    var headers: [String : String]? {
        return nil
    }
}
