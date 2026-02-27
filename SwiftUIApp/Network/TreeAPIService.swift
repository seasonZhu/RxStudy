//
//  TreeAPIService.swift
//  RxStudy - SwiftUIApp
//
//  体系/树 API 服务
//  使用 async/await 封装
//

import Foundation
import Moya

// MARK: - 体系 API 定义

enum TreeAPI {
    case tags                          // 获取体系分类
    case tagList(id: Int, page: Int)   // 获取体系文章列表
}

extension TreeAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }

    var path: String {
        switch self {
        case .tags:
            return "/tree/json"
        case .tagList(_, let page):
            return "/article/list/\(page)/json"
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
            return .requestParameters(parameters: ["cid": "\(id)"], encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return nil
    }
}

// MARK: - 体系 API 服务

@Observable
final class TreeAPIService {
    static let shared = TreeAPIService()

    private let provider = MoyaProvider<TreeAPI>()

    private init() {}

    // MARK: - 请求方法

    /// 获取体系分类
    func fetchTags() async throws -> [TreeTagModel] {
        return try await provider.requestDecoded(.tags, responseType: StandardResponse<[TreeTagModel]>.self)
    }

    /// 获取体系文章列表
    func fetchArticleList(tagId: Int, page: Int) async throws -> PagedResult<InfoModel> {
        return try await provider.requestDecoded(.tagList(id: tagId, page: page), responseType: StandardResponse<PagedResult<InfoModel>>.self)
    }
}
