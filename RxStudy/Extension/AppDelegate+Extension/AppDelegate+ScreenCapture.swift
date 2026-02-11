//
//  AppDelegate+ScreenCapture.swift
//  RxStudy
//
//  Created by code optimization on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {

    /// 设置屏幕截图/录屏监听
    func setupScreenCaptureMonitoring() {
        // 监听截屏
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { _ in
            print("屏幕正在被截屏")
        }

        // 监听录屏
        NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            if UIScreen.main.isCaptured {
                print("屏幕正在被捕获，可以在这里做一些隐藏内容的操作")
            } else {
                print("屏幕没有被捕获，可以移除那个覆盖的视图")
            }
        }
    }
}
