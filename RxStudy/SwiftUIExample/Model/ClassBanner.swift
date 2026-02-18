//
//  ClassBanner.swift
//  RxStudy
//
//  Created by dy on 2022/10/11.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

class ClassBanner: ObservableObject, Identifiable, Codable {    
    
    var id: Int?
    
    var title: String?
    
    var originId: Int?
    
    var link: String? { url }
        
    let desc: String?
    
    let imagePath: String?
    let isVisible: Int?
    let order: Int?
    
    let type: Int?
    let url: String?
}

extension ClassBanner: WebLoadInfo {}
