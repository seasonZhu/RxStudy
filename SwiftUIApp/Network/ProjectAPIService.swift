//
//  ProjectAPIService.swift
//  RxStudy - SwiftUIApp
//
//  项目 API 服务
//  使用 async/await 封装
//

import Foundation
import Moya

// MARK: - 项目 API 定义

enum ProjectAPI {
    case tags                          // 获取项目分类
    case tagList(id: Int, page: Int)   // 获取项目列表
}

extension ProjectAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }

    var path: String {
        switch self {
        case .tags:
            return "/project/tree/json"
        case .tagList(_, let page):
            return "/project/list/\(page)/json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .tags:
            return .requestPlain
        case .tagList(let id, _):
            return .requestParameters(parameters: ["cid": id], encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}

// MARK: - 项目 API 服务

@Observable
final class ProjectAPIService {
    static let shared = ProjectAPIService()

    private let provider = MoyaProvider<ProjectAPI>()

    private init() {}

    // MARK: - 请求方法

    /// 获取项目分类
    func fetchTags() async throws -> [ProjectTagModel] {
        return try await provider.requestDecoded(.tags, responseType: StandardResponse<[ProjectTagModel]>.self)
    }

    /// 获取项目列表
    func fetchProjectList(tagId: Int, page: Int) async throws -> Page<InfoModel> {
        return try await provider.requestDecoded(.tagList(id: tagId, page: page), responseType: StandardResponse<Page<InfoModel>>.self)
    }
}
