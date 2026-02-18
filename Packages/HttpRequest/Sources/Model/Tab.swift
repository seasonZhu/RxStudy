//
//  Tab.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

public struct Tab: Codable {
    public let children: [Tab]?
    public let courseId: Int?
    public let id: Int?
    public let name: String?
    public let order: Int?
    public let parentChapterId: Int?
    public let userControlSetTop: Bool?
    public let visible: Int?
}

extension Tab: TabAble {}
