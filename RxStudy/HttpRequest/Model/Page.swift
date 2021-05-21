//
//  Page.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

/// 有分页的基础模型
struct Page<Content: Codable> : Codable {
    let curPage : Int?
    let datas : [Content]?
    let offset : Int?
    let over : Bool?
    let pageCount : Int?
    let size : Int?
    let total : Int?
}
