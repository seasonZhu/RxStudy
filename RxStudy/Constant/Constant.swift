//
//  Constant.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

/// 状态栏的高度(竖屏限定)
let kStatusBarHeight: CGFloat = if #available(iOS 13.0, *) {
    UIApplication.shared.MainWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 24
} else {
    UIApplication.shared.statusBarFrame.height
}

/// 导航栏的高度(竖屏限定)
let kNavigationBarHeight: CGFloat = 44.0

/// 整体顶部间距(竖屏限定)
let kTopMargin = kStatusBarHeight + kNavigationBarHeight

/// 底部安全区间距(竖屏限定) 34
let kSafeBottomMargin: CGFloat = UIApplication.shared.MainWindow?.safeAreaInsets.bottom ?? 0

/// tabbar的高度 从图层看是48
let kTabbarHeight: CGFloat = 49

/// 屏宽
let kScreenWidth = UIScreen.main.bounds.width

/// 屏宽的9/16
let kScreenWidth_9_16 = UIScreen.main.bounds.width / 16.0 * 9

/// 屏高
let kScreenHeight = UIScreen.main.bounds.height

/// 整体底部间距 从图层看是83 但是图层的tabbar的高度是48, 底部安全区间距是34 48 + 34 = 82
let kBottomMargin = kSafeBottomMargin + kTabbarHeight

/// 保存用户名的key
let kUsername = "kUsername"

/// 保存密码的key
let kPassword = "kPassword"

/// 是否是灰色模式的key
let kIsGrayMode = "kIsGrayMode"

/// 必须这么显式的编写,才能表示其意义
let void: Void = ()

/// 命名空间
let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String

/// 是否是第一次进入App
let kIsFirst = "IsFirst"

typealias ValueCallback<T> = (T) -> Void

extension UIApplication {
    static var appDelegate: AppDelegate? { UIApplication.shared.delegate as? AppDelegate }
    
    var  MainWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let keyWindow = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow }) {
                return keyWindow
            } else {
                return UIApplication.shared.delegate?.window ?? nil
            }
        } else {
            if UIApplication.shared.windows.last?.isKind(of: UIWindow.self) == false {
                return nil
            }
            return UIApplication.shared.keyWindow
        }
    }
}
