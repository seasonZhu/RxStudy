//
//  Constant.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

/// 状态栏的高度(竖屏限定)
@MainActor let kStatusBarHeight: CGFloat = 47
/// 导航栏的高度(竖屏限定)
@MainActor let kNavigationBarHeight: CGFloat = 44.0

/// 整体顶部间距(竖屏限定)
@MainActor let kTopMargin = kStatusBarHeight + kNavigationBarHeight

/// 底部安全区间距(竖屏限定) 34
@MainActor let kSafeBottomMargin: CGFloat = UIApplication.shared.mainWindow?.safeAreaInsets.bottom ?? 0

/// tabbar的高度 从图层看是48
@MainActor let kTabbarHeight: CGFloat = 49

/// 屏宽
@MainActor let kScreenWidth = UIScreen.main.bounds.width

/// 屏宽的9/16
@MainActor let kScreenWidth_9_16 = UIScreen.main.bounds.width / 16.0 * 9

/// 屏高
@MainActor let kScreenHeight = UIScreen.main.bounds.height

/// 整体底部间距 从图层看是83 但是图层的tabbar的高度是48, 底部安全区间距是34 48 + 34 = 82
@MainActor let kBottomMargin = kSafeBottomMargin + kTabbarHeight

/// 保存用户名的key
@MainActor let kUsername = "kUsername"

/// 保存密码的key
@MainActor let kPassword = "kPassword"

/// 是否是灰色模式的key
@MainActor let kIsGrayMode = "kIsGrayMode"

/// 必须这么显式的编写,才能表示其意义
@MainActor let void: Void = ()

/// 命名空间
@MainActor let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String

/// 是否是第一次进入App
@MainActor let kIsFirst = "IsFirst"

typealias ValueCallback<T> = (T) -> Void
