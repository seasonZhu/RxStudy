//
//  Tool.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

public struct Tool: Codable {
    public let desc: String?
    public let icon: String?

    public let isNew: Int?

    public let order: Int?
    public let showInTab: Int?
    public let tabName: String?
    public let visible: Int?

    public var id: Int?

    public var originId: Int?

    public var title: String?

    public let link: String?

    /// 这里我将name -> title,这样就可以遵守WebLoadInfo协议
    enum CodingKeys: String, CodingKey {
        case desc
        case icon
        case id
        case isNew
        case link
        case title = "name"
        case order
        case showInTab
        case tabName
        case visible
        case originId
    }
}

extension Tool: WebLoadInfo {}
