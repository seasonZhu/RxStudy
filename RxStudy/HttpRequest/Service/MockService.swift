//
//  MockService.swift
//  RxStudy
//
//  Created by dy on 2022/12/5.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

import Moya

enum MockService {
    /// 悼念模式
    case mourn
}

extension MockService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .mourn:
            return Api.Mock.mourn
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        let jsonString = """
        {
            "data": false,
            "errorCode": 0,
            "errorMsg": ""
        }
        
        """
        let jsonData = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data()
        
        return jsonData
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? { nil }
}
