//
//  AccountInfo.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

public struct AccountInfo: Codable {
    public let admin: Bool?
    public let chapterTops: [Int]?
    public var collectIds: [Int]?
    public let email: String?
    public let icon: String?
    public let id: Int?
    public let nickname: String?
    public var password: String?
    public let publicName: String?
    public let token: String?
    public let type: Int?
    public var username: String?
}
