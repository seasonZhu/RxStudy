//
//  Banner.swift
//  RxStudy - Shared
//
//  统一 Banner 模型
//

import Foundation

public struct Banner: Codable, Identifiable {
    public var id: Int?

    public var title: String?

    public var originId: Int?

    public var link: String? { url }

    public let desc: String?

    public let imagePath: String?

    public let isVisible: Int?

    public let order: Int?

    public let type: Int?

    public let url: String?
}

extension Banner: WebLoadInfo {}
