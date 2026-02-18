//
//  TreeService.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

public enum TreeService {
    case tags
    case tagList(_ id: Int, _ page: Int)
}

extension TreeService: TargetType {
    public var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }

    public var path: String {
        switch self {
        case .tags:
            return Api.Tree.tags
        case let .tagList(_, page):
            return Api.Tree.tagList + page.toString + "/json"
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
