//
//  Message.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

public struct Message: Codable {
    public let category: Int?
    public let date: Int?
    public let fromUser: String?
    public let fromUserId: Int?
    public let fullLink: String?
    public let id: Int?
    public let isRead: Int?
    public let link: String?
    public let message: String?
    public let niceDate: String?
    public let tag: String?
    public let title: String?
    public let userId: Int?
}

/// 跳转到WebController的简化模型
public struct MessageLoadInfo: WebLoadInfo {
    public var id: Int?

    public var originId: Int?

    public var title: String?

    public var link: String?

    public init(id: Int? = nil, originId: Int? = nil, title: String? = nil, link: String? = nil) {
        self.id = id
        self.originId = originId
        self.title = title
        self.link = link
    }
}
