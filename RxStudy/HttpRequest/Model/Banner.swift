//
//  Banner.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct Banner : Codable {
    
    var title : String?
    
    var collectId: Int? { id }
    
    var link: String? { url }
        
    let desc : String?
    let id : Int?
    let imagePath : String?
    let isVisible : Int?
    let order : Int?
    
    let type : Int?
    let url : String?
}

extension Banner: WebLoadInfo {}
