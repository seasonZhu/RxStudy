//
//  CourseService.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

import Moya

public enum CourseService {
    case tags
    case tagList(_ id: Int, _ page: Int)
}

extension CourseService: TargetType {
    public var baseURL: URL {
        switch self {
        case .tags:
            return URL(string: Api.baseUrl)!
        case .tagList:
            return URL(string: Api.newBaseUrl)!
        }
    }

    public var path: String {
        switch self {
        case .tags:
            return Api.Course.tags
        case let .tagList(_, page):
            return Api.Course.tagList + page.toString + "/json"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        switch self {
        case .tags:
            return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
        case let .tagList(id, _):
            /// article/list/0/json?cid=549&order_type=1
            return .requestParameters(parameters: ["cid": id.toString, "order_type=1": 1.toString], encoding: URLEncoding.default)
        }
    }

    public var headers: [String: String]? { nil }
}
