//
//  SwiftUI.swift
//  RxStudy
//
//  Created by dy on 2022/9/26.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

class ClassCoinRank: ObservableObject, Identifiable, Codable {

    let coinCount: Int?
    let level: Int?
    let nickname: String?
    let rank: String?
    let userId: Int?
    let username: String?
    
    var myInfo: String {
        guard let rank,
              let level,
              let coinCount else {
            return "排名: -- 等级: -- 积分: --"
        }
        return "排名: \(rank) 等级: \(level) 积分: \(coinCount)"
    }
    
    var rankInfo: String {
        if let username = username {
            return "\(username)\n\n\(myInfo)"
        } else {
            return myInfo
        }
    }
}
