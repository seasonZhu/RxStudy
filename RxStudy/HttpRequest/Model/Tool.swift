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
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        desc = try values.decodeIfPresent(String.self, forKey: .desc)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        isNew = try values.decodeIfPresent(Int.self, forKey: .isNew)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        order = try values.decodeIfPresent(Int.self, forKey: .order)
        showInTab = try values.decodeIfPresent(Int.self, forKey: .showInTab)
        tabName = try values.decodeIfPresent(String.self, forKey: .tabName)
        visible = try values.decodeIfPresent(Int.self, forKey: .visible)
        originId = try values.decodeIfPresent(Int.self, forKey: .originId)
    }

}

extension Tool: WebLoadInfo {}
