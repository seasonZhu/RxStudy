//
//  UIViewController+Extension.swift
//  RxStudy
//
//  Created by dy on 2025/6/11.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

/*
 获取到的状态栏高度为 0”问题，常见原因如下：

 获取时机太早
 如果在 AppDelegate 的 didFinishLaunchingWithOptions 或 SceneDelegate 的 willConnectTo 里获取，UI 还没布局完成，状态栏高度可能为 0。

 没有激活的 windowScene
 如果 App 还没有 window 或 windowScene 没激活，也会导致拿到 0。
 
 在视图控制器的 viewDidAppear 或 viewDidLayoutSubviews 获取，目前发现在viewDidLoad里面也是可以正常获取到的,就是没法像之前写到Constant里面静态获取了
 */
extension UIViewController {
    var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
}
