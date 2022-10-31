//
//  Message.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

struct Message : Codable {

    let category : Int?
    let date : Int?
    let fromUser : String?
    let fromUserId : Int?
    let fullLink : String?
    let id : Int?
    let isRead : Int?
    let link : String?
    let message : String?
    let niceDate : String?
    let tag : String?
    let title : String?
    let userId : Int?
}

/// 跳转到WebController的简化模型
struct MessageLoadInfo: WebLoadInfo {
    var id: Int?
    
    var originId: Int?
    
    var title: String?
    
    var link: String?
    
    
}
