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
    case hotKey
    case search(keyword: String, page: Int)
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
        case .hotKey:
            return "/hotkey/json"
        case .search(let keyword, let page):
            return "/article/query/\(page)/json"
        }
    }

    var task: Task {
        switch self {
        case .search(let keyword, _):
            return .requestParameters(parameters: ["k": keyword], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }

    var method: Moya.Method {
        switch self {
        case .search:
            return .post
        default:
            return .get
        }
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
    func fetchArticleList(page: Int) async throws -> PagedResult<InfoModel> {
        return try await provider.requestDecoded(.articleList(page: page), responseType: StandardResponse<PagedResult<InfoModel>>.self)
    }

    /// 获取热词
    func getHotKeys() async throws -> [HotKeyModel] {
        return try await provider.requestDecoded(.hotKey, responseType: StandardResponse<[HotKeyModel]>.self)
    }

    /// 搜索文章
    func searchArticles(keyword: String, page: Int) async throws -> PagedResult<InfoModel> {
        print("🔍 API请求: 搜索关键词=\(keyword), 页码=\(page)")
        print("🌐 URL: https://www.wanandroid.com/article/query/\(page)/json")
        print("📦 参数: k=\(keyword)")

        let result = try await provider.requestDecoded(.search(keyword: keyword, page: page), responseType: StandardResponse<PagedResult<InfoModel>>.self)

        print("✅ API响应成功，返回 \(result.datas?.count ?? 0) 条数据")
        return result
    }
}
