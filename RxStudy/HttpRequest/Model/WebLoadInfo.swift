//
//  WebLoadInfo.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

protocol WebLoadInfo {
    var isShowRightButtonItem: Bool { set get }
    var id: Int? { set get }
    var title: String? { set get }
    var link: String? { get }
}
