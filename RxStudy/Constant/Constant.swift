//
//  Constant.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

/// 状态栏的高度(竖屏限定)
let kStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

/// 导航栏的高度(竖屏限定)
let kNavigationBarHeight: CGFloat = 44.0

/// 整体顶部间距(竖屏限定)
let kTopMargin = kStatusBarHeight + kNavigationBarHeight

/// 底部安全区间距(竖屏限定)
let kSafeBottomMargin: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0

/// tabbar的高度
let kTabbarHeight: CGFloat = 49

/// 屏宽
let kScreenWidth = UIScreen.main.bounds.width

/// 屏宽的9/16
let kScreenWidth_9_16 = UIScreen.main.bounds.width / 16.0 * 9

/// 屏高
let kScreenHeight = UIScreen.main.bounds.height

/// 整体底部间距
let kBottomMargin = kSafeBottomMargin + kTabbarHeight

/// 保存用户名的key
let kUsername = "kUsername"

/// 保存密码的key
let kPassword = "kPassword"

/// 必须这么显式的编写,才能表示其意义
let void: Void = ()

/// 更新自定义句柄,这个是我自己写的JS,并定义其句柄
let JSCallback = "wanAndroid"

/// 命名空间
let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
