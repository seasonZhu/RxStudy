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
    
    case friend
    
    case navi
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
        case .friend:
            return Api.Other.friend
        case .navi:
            return Api.Other.navi
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        return .requestPlain
        
    }
    
    var headers: [String : String]? { nil }
}

enum TestService: String {
    case square = "user_article/list/"
    
    /// 枚举的继承与枚举带参不能同时使用,如果可以同时使用,我就不同特地去写Api这个枚举了,当然如果后台的请求Api优化的足够,可能也不需要带参枚举
    //case square(_ page: Int) = "user_article/list/"
}

extension TestService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        self.rawValue + "1/json"
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}
