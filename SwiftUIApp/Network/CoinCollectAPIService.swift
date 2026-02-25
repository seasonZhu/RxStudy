//
//  CoinCollectAPIService.swift
//  RxStudy - SwiftUIApp
//
//  积分和收藏 API 服务
//  使用 async/await 封装
//

import Foundation
import Moya

// MARK: - 积分 API 定义

enum CoinAPI {
    case coinRank(page: Int)        // 获取积分排名
    case userCoinInfo              // 获取个人积分信息
    case myCoinList(page: Int)      // 获取积分列表
}

extension CoinAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }

    var path: String {
        switch self {
        case .coinRank(let page):
            return "/coin/rank/\(page)/json"
        case .userCoinInfo:
            return "/lg/coin/userinfo/json"
        case .myCoinList(let page):
            return "/lg/coin/list/\(page)/json"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        // 从 AccountAPIService 获取 Cookie
        let cookie = AccountAPIService.shared.cookieHeaderValue
        return cookie.isEmpty ? nil : ["cookie": cookie]
    }
}

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
        // 从 AccountAPIService 获取 Cookie
        let cookie = AccountAPIService.shared.cookieHeaderValue
        return cookie.isEmpty ? nil : ["cookie": cookie]
    }
}

// MARK: - 积分 API 服务

@Observable
final class CoinAPIService {
    static let shared = CoinAPIService()

    private let provider = MoyaProvider<CoinAPI>()

    private init() {}

    /// 获取积分排名
    func fetchCoinRank(page: Int) async throws -> CoinRankPageModel {
        return try await provider.requestDecoded(.coinRank(page: page), responseType: StandardResponse<CoinRankPageModel>.self)
    }

    /// 获取个人积分信息
    func fetchUserInfo() async throws -> CoinUserInfoModel {
        return try await provider.requestDecoded(.userCoinInfo, responseType: StandardResponse<CoinUserInfoModel>.self)
    }

    /// 获取我的积分记录列表
    func fetchMyCoinList(page: Int) async throws -> MyCoinPageModel {
        return try await provider.requestDecoded(.myCoinList(page: page), responseType: StandardResponse<MyCoinPageModel>.self)
    }
}

// MARK: - 收藏 API 服务

@Observable
final class CollectAPIService {
    static let shared = CollectAPIService()

    private let provider = MoyaProvider<CollectAPI>()

    private init() {}

    /// 获取收藏列表
    func fetchCollectList(page: Int) async throws -> CollectPageModel {
        return try await provider.requestDecoded(.collectList(page: page), responseType: StandardResponse<CollectPageModel>.self)
    }
}
