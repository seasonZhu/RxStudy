//
//  HUD.swift
//  RxStudy
//
//  Created by season on 2021/7/14.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

/// 弹窗协议
protocol HUD {
    static func beginLoading()
    
    static func stopLoading()
    
    static func showText(_ text: String)
}
