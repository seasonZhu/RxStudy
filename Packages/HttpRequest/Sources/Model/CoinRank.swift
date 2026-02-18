//
//  CoinRank.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

public struct CoinRank: Codable {
    public let coinCount: Int?
    public let level: Int?
    public let nickname: String?
    public let rank: String?
    public let userId: Int?
    public let username: String?

    public var myInfo: String {
        guard let rank,
              let level,
              let coinCount
        else {
            return "排名: -- 等级: -- 积分: --"
        }
        return "排名: \(rank) 等级: \(level) 积分: \(coinCount)"
    }

    public var rankInfo: String {
        if let username = username {
            return "\(username)\n\n\(myInfo)"
        } else {
            return myInfo
        }
    }
}
