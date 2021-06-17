//
//  MyCoin.swift
//  RxStudy
//
//  Created by season on 2021/6/15.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct MyCoin: Codable {
    let coinCount : Int?
    let level : Int?
    let nickname : String?
    let rank : String?
    let userId : Int?
    let username : String?
    
    var myInfo: String {
        guard let coinCount = self.coinCount, let level = self.level, let rank = self.rank else {
            return "积分: --  等级: --  排名: --"
        }
        return "积分: \(coinCount)  等级: \(level)  排名: \(rank)"
    }
}
