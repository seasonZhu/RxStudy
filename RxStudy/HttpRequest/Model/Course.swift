//
//  Course.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

/// 实际上没有使用这个数据结构,都是用的Tab
struct Course : Codable {

    let author : String?
    let children : [Course]?
    let courseId : Int?
    let cover : String?
    let desc : String?
    let id : Int?
    let lisense : String?
    let lisenseLink : String?
    let name : String?
    let order : Int?
    let parentChapterId : Int?
    let userControlSetTop : Bool?
    let visible : Int?
}

extension Course: TabAble {}
