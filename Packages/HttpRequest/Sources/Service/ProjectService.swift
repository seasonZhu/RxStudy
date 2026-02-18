//
//  ProjectService.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

public enum ProjectService {
    case tags
    case tagList(_ id: Int, _ page: Int)
}

extension ProjectService: TargetType {
    public var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }

    public var path: String {
        switch self {
        case .tags:
            return Api.Project.tags
        case let .tagList(_, page):
            return Api.Project.tagList + page.toString + "/json"
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
            return .requestParameters(parameters: ["cid": id.toString], encoding: URLEncoding.default)
        }
    }

    public var headers: [String: String]? { nil }
}
