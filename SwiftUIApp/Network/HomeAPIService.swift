//
//  HomeAPIService.swift
//  RxStudy - SwiftUIApp
//
//  首页 API 服务
//  使用 async/await 封装
//

import Foundation
import Moya

// MARK: - 首页 API 定义

enum HomeAPI {
    case banner
    case topArticle
    case articleList(page: Int)
}

extension HomeAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }

    var path: String {
        switch self {
        case .banner:
            return "/banner/json"
        case .topArticle:
            return "/article/top/json"
        case .articleList(let page):
            return "/article/list/\(page)/json"
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

// MARK: - 首页 API 服务

@Observable
final class HomeAPIService {
    static let shared = HomeAPIService()

    private let provider = MoyaProvider<HomeAPI>()

    private init() {}

    // MARK: - 请求方法

    /// 获取 Banner 列表
    func fetchBanners() async throws -> [HomeBannerModel] {
        return try await provider.requestDecoded(.banner, responseType: StandardResponse<[HomeBannerModel]>.self)
    }

    /// 获取置顶文章
    func fetchTopArticles() async throws -> [HomeArticleModel] {
        return try await provider.requestDecoded(.topArticle, responseType: StandardResponse<[HomeArticleModel]>.self)
    }

    /// 获取文章列表
    func fetchArticleList(page: Int) async throws -> HomePageModel {
        return try await provider.requestDecoded(.articleList(page: page), responseType: StandardResponse<HomePageModel>.self)
    }
}
