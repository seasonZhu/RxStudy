//
//  CoinCollectModels.swift
//  RxStudy - SwiftUIApp
//
//  积分和收藏数据模型
//

import Foundation

// MARK: - 积分相关模型

/// 积分信息（与 CoinRank 相同，用于个人积分）
typealias CoinUserInfoModel = CoinRankModel

/// 积分排名模型
struct CoinRankModel: Codable, Identifiable {
    let coinCount: Int?
    let level: Int?
    let nickname: String?
    let rank: String?
    let userId: Int?
    let username: String?

    /// Identifiable 需要 id，使用计算属性
    var id: Int {
        userId ?? 0
    }

    /// 我的信息（排名、等级、积分）
    var myInfo: String {
        guard let rank,
              let level,
              let coinCount else {
            return "排名: -- 等级: -- 积分: --"
        }
        return "排名: \(rank) 等级: \(level) 积分: \(coinCount)"
    }

    /// 排名信息（用于显示）
    var rankInfo: String {
        if let username = username {
            return "\(username)\n\n\(myInfo)"
        } else {
            return myInfo
        }
    }
}

/// 积分排名分页模型
struct CoinRankPageModel: Codable {
    let curPage: Int?
    let pageCount: Int?
    let datas: [CoinRankModel]?

    var hasMore: Bool {
        guard let cur = curPage, let total = pageCount else { return false }
        return cur < total
    }
}

/// 我的积分记录模型
struct MyHistoryCoin: Codable, Identifiable {
    let coinCount: Int?
    let date: Int?
    let desc: String?
    let id: Int?
    let reason: String?
    let type: Int?
    let userId: Int?
    let userName: String?
}

/// 我的积分分页模型
struct MyCoinPageModel: Codable {
    let curPage: Int?
    let pageCount: Int?
    let datas: [MyHistoryCoin]?

    var hasMore: Bool {
        guard let cur = curPage, let total = pageCount else { return false }
        return cur < total
    }
}

// MARK: - 收藏相关模型

struct CollectPageModel: Codable {
    let curPage: Int?
    let pageCount: Int?
    let datas: [CollectArticleModel]?

    var hasMore: Bool {
        guard let cur = curPage, let total = pageCount else { return false }
        return cur < total
    }
}
