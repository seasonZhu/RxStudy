//
//  HotKey.swift
//  RxStudy - Shared
//
//  热词模型
//

import Foundation

/// 热词模型
struct HotKey: Codable, Identifiable {
    let id: Int?
    let link: String?
    let name: String?
    let order: Int?
    let visible: Int?
}

/// 别名（兼容 SwiftUIApp）
typealias HotKeyModel = HotKey
