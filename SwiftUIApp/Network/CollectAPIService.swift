//
//  CollectAPIService.swift
//  RxStudy - SwiftUIApp
//
//  收藏 API 服务
//  使用 async/await 封装
//

import Foundation
import Moya

// MARK: - 收藏 API 定义

enum CollectAPI {
    case collectList(page: Int)       // 获取收藏列表
}

extension CollectAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }

    var path: String {
        switch self {
        case .collectList(let page):
            return "/lg/collect/list/\(page)/json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        let cookie = AccountAPIService.shared.cookieHeaderValue
        return cookie.isEmpty ? nil : ["cookie": cookie]
    }
}

// MARK: - 收藏 API 服务

@Observable
final class CollectAPIService {
    static let shared = CollectAPIService()

    private let provider = MoyaProvider<CollectAPI>()

    private init() {}

    /// 获取收藏列表
    func fetchCollectList(page: Int) async throws -> Page<InfoModel> {
        return try await provider.requestDecoded(.collectList(page: page), responseType: BaseModel<Page<InfoModel>>.self)
    }
}
