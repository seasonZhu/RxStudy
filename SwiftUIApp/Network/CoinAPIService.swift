//
//  CoinAPIService.swift
//  RxStudy - SwiftUIApp
//
//  积分 API 服务
//  使用 async/await 封装
//

import Foundation
import Moya

// MARK: - 积分 API 定义

enum CoinAPI {
    case coinRank(page: Int)        // 获取积分排名
    case userCoinInfo               // 获取个人积分信息
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
    func fetchCoinRank(page: Int) async throws -> Page<CoinRankModel> {
        return try await provider.requestDecoded(.coinRank(page: page), responseType: BaseModel<Page<CoinRankModel>>.self)
    }

    /// 获取个人积分信息
    func fetchUserInfo() async throws -> CoinUserInfoModel {
        return try await provider.requestDecoded(.userCoinInfo, responseType: BaseModel<CoinUserInfoModel>.self)
    }

    /// 获取我的积分记录列表
    func fetchMyCoinList(page: Int) async throws -> Page<MyHistoryCoin> {
        return try await provider.requestDecoded(.myCoinList(page: page), responseType: BaseModel<Page<MyHistoryCoin>>.self)
    }
}
