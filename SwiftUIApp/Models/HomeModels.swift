//
//  HomeModels.swift
//  RxStudy - SwiftUIApp
//
//  首页数据模型
//

import Foundation

// MARK: - Banner 模型

struct HomeBannerModel: Codable, Identifiable {
    let id: Int?
    let title: String?
    let desc: String?
    let imagePath: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id, title, desc
        case imagePath = "imagePath"
        case url
    }
}

// MARK: - 文章分页模型

struct HomeArticlePageModel: Codable {
    let curPage: Int?
    let pageCount: Int?
    let datas: [InfoModel]?

    var hasMore: Bool {
        guard let cur = curPage, let total = pageCount else { return false }
        return cur < total
    }
}

// 保留兼容性别名
typealias HomeArticleModel = InfoModel
