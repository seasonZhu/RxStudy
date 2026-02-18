//
//  AppDelegate+Debug.swift
//  RxStudy
//
//  Created by dy on 2026/2/11.
//  Copyright © 2026 season. All rights reserved.
//

import UIKit

extension AppDelegate {
    func setupDebugTools() {
        // cocoaDebugSetting() // CocoaDebug 库已移除
        // lifetimeTrackerSetting() // LifetimeTracker 库已移除
    }
}

// MARK: - CocoaDebug配置
#if DEBUG
#endif

extension AppDelegate {
    func cocoaDebugSetting() {
        // CocoaDebug 库已移除 - 暂时注释
        // #if DEBUG
        //     CocoaDebug.enable()
        // #endif
    }
}

// MARK: - 生命周期跟踪
#if DEBUG
#endif

extension AppDelegate {
    func lifetimeTrackerSetting() {
        // LifetimeTracker 库已移除 - 暂时注释
        // #if DEBUG
        //     LifetimeTracker.setup(
        //         onUpdate: LifetimeTrackerDashboardIntegration(
        //             visibility: .alwaysVisible,
        //             style: .circular,
        //             textColorForNoIssues: .systemGreen,
        //             textColorForLeakDetected: .systemRed
        //         ).refreshUI
        //     )
        // #endif
    }
}

extension AppDelegate {
    func logPrintDebug() {
        /// LogUtils的简单使用
        LogUtils.debug("哈哈", "呵呵")

        LogUtils.debug("kStatusBarHeight\(kStatusBarHeight)")

        LogUtils.debug("kSafeBottomMargin\(kSafeBottomMargin)")

        // logger.log("this log is OSLog, RxStudy") // logger 未定义 - 暂时注释

    }
}
