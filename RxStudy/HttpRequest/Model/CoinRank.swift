//
//  CoinRank.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct CoinRank : Codable {

    let coinCount : Int?
    let level : Int?
    let nickname : String?
    let rank : String?
    let userId : Int?
    let username : String?
    
    var rankInfo: String {
        guard let rank = self.rank, let userName = self.username, let level = self.level, let coinCount = self.coinCount else {
            return ""
        }
        return "排名:" + rank + " 用户名:" + userName + " 等级" + level.toString + " 积分:" + coinCount.toString
    }
}
