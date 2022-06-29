//
//  Tool.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

struct Tool : Codable {

    let desc : String?
    let icon : String?
    
    let isNew : Int?
    
    
    let order : Int?
    let showInTab : Int?
    let tabName : String?
    let visible : Int?
    
    var id : Int?
    
    var originId: Int?
    
    var title: String?
    
    let link : String?
    
    /// 这里我将name -> title,这样就可以遵守WebLoadInfo协议
    enum CodingKeys: String, CodingKey {
        case desc = "desc"
        case icon = "icon"
        case id = "id"
        case isNew = "isNew"
        case link = "link"
        case title = "name"
        case order = "order"
        case showInTab = "showInTab"
        case tabName = "tabName"
        case visible = "visible"
        case originId = "originId"
    }
}

extension Tool: WebLoadInfo {}
