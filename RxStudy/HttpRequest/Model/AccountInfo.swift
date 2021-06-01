//
//  AccountInfo.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct AccountInfo : Codable {

    let admin : Bool?
    let chapterTops : [Int]?
    let collectIds : [Int]?
    let email : String?
    let icon : String?
    let id : Int?
    let nickname : String?
    let password : String?
    let publicName : String?
    let token : String?
    let type : Int?
    let username : String?
}
