//
//  PublicNumberService.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

public enum PublicNumberService {
    case tags
    case tagList(_ id: Int, _ page: Int)
}

extension PublicNumberService: TargetType {
    public var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }

    public var path: String {
        switch self {
        case .tags:
            return Api.PublicNumber.tags
        case let .tagList(id, page):
            return Api.PublicNumber.tagList + id.toString + "/" + page.toString + "/json"
        }
    }

    public var method: Moya.Method {
        return .get
    }

    public var sampleData: Data {
        return Data()
    }

    public var task: Task {
        return .requestParameters(parameters: .empty, encoding: URLEncoding.default)
    }

    public var headers: [String: String]? { nil }
}
