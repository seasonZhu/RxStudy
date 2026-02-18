//
//  Banner.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

public struct Banner: Codable {
    public var id: Int?

    public var title: String?

    public var originId: Int?

    public var link: String? { url }

    public let desc: String?

    public let imagePath: String?

    public let isVisible: Int?

    public let order: Int?

    public let type: Int?

    public let url: String?
}

extension Banner: WebLoadInfo {}
