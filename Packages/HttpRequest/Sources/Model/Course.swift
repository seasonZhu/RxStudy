//
//  Course.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

/// 实际上没有使用这个数据结构,都是用的Tab
public struct Course: Codable {
    public let author: String?
    public let children: [Course]?
    public let courseId: Int?
    public let cover: String?
    public let desc: String?
    public let id: Int?
    public let lisense: String?
    public let lisenseLink: String?
    public let name: String?
    public let order: Int?
    public let parentChapterId: Int?
    public let userControlSetTop: Bool?
    public let visible: Int?
}

extension Course: TabAble {}
