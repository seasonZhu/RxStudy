//
//  WebLoadInfo.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

public protocol WebLoadInfo {
    var id: Int? { get set }
    var originId: Int? { get set }
    var title: String? { get set }
    var link: String? { get }
}
