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
}
