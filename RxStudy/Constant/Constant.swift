//
//  Constant.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

/// 状态栏的高度
let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

/// 导航栏的高度
let kNavigationBarHeight: CGFloat = 44.0

/// 整体顶部间距
let kTopMargin = kStatusBarHeight + kNavigationBarHeight

/// 底部安全区间距
let kSafeBottomMargin: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0

/// tabbar的高度
let kTabbarHeight: CGFloat = 49

/// 整体底部间距
let kBottomMargin = kSafeBottomMargin + kTabbarHeight

let kUsername = "kUsername"

let kPassword = "kPassword"
