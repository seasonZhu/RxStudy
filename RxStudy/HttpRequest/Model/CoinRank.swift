//
//  CoinRank.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct CoinRank: Codable {

    let coinCount: Int?
    let level: Int?
    let nickname: String?
    let rank: String?
    let userId: Int?
    let username: String?
    
    init(coinCount: Int? = nil, level: Int? = nil, nickname: String? = nil, rank: String? = nil, userId: Int? = nil, username: String? = nil) {
        self.coinCount = coinCount
        self.level = level
        self.nickname = nickname
        self.rank = rank
        self.userId = userId
        self.username = username
    }
    
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
