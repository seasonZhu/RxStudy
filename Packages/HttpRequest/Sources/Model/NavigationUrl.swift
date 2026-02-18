//
//  NavigationUrl.swift
//  RxStudy
//
//  Created by dy on 2022/6/28.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

public struct NavigationUrl: Codable {
    public let articles: [Info]?
    public let cid: Int?
    public let name: String?
}
