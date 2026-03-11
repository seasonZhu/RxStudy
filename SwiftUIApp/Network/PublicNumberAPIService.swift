//
//  PublicNumberAPIService.swift
//  RxStudy - SwiftUIApp
//
//  公众号 API 服务
//  使用 async/await 封装
//

import Foundation
import Moya

// MARK: - 公众号 API 定义

enum PublicNumberAPI {
    case tags                          // 获取公众号分类
    case tagList(id: Int, page: Int)   // 获取公众号文章列表
}

extension PublicNumberAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }

    var path: String {
        switch self {
        case .tags:
            return "/wxarticle/chapters/json"
        case .tagList(let id, let page):
            return "/wxarticle/list/\(id)/\(page)/json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return nil
    }
}

// MARK: - 公众号 API 服务

@Observable
final class PublicNumberAPIService {
    static let shared = PublicNumberAPIService()

    private let provider = MoyaProvider<PublicNumberAPI>()

    private init() {}

    // MARK: - 请求方法

    /// 获取公众号分类
    func fetchTags() async throws -> [PublicNumberTagModel] {
        return try await provider.requestDecoded(.tags, responseType: StandardResponse<[PublicNumberTagModel]>.self)
    }

    /// 获取公众号文章列表
    func fetchArticleList(accountId: Int, page: Int) async throws -> Page<InfoModel> {
        return try await provider.requestDecoded(.tagList(id: accountId, page: page), responseType: StandardResponse<Page<InfoModel>>.self)
    }
}
