//
//  Tab.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct Tab: Codable {

    let children: [Tab]?
    let courseId: Int?
    let id: Int?
    let name: String?
    let order: Int?
    let parentChapterId: Int?
    let userControlSetTop: Bool?
    let visible: Int?

}

extension Tab: TabAble {}
