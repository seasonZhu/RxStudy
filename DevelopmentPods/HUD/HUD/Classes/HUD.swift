//
//  HUD.swift
//  RxStudy
//
//  Created by season on 2021/7/14.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

/// 弹窗协议,抹平MB和SV的用法
public protocol HUD {
    /// 为啥不用start,因为容易混淆
    static func beginLoading()
    
    static func stopLoading()
    
    static func showText(_ text: String)
}
