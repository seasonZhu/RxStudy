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
        cocoaDebugSetting()
        lifetimeTrackerSetting()
    }
}

// MARK: - CocoaDebug配置
#if DEBUG
import CocoaDebug
#endif

extension AppDelegate {
    func cocoaDebugSetting() {
        #if DEBUG
            CocoaDebug.enable()
        #endif
    }
}

// MARK: - 生命周期跟踪
#if DEBUG
import LifetimeTracker
#endif

extension AppDelegate {
    func lifetimeTrackerSetting() {
        #if DEBUG
            LifetimeTracker.setup(
                onUpdate: LifetimeTrackerDashboardIntegration(
                    visibility: .alwaysVisible,
                    style: .circular,
                    textColorForNoIssues: .systemGreen,
                    textColorForLeakDetected: .systemRed
                ).refreshUI
            )
        #endif
    }
}

extension AppDelegate {
    func logPrintDebug() {
        /// LogUtils的简单使用
        LogUtils.debug("哈哈", "呵呵")
        
        LogUtils.debug("kStatusBarHeight\(kStatusBarHeight)")
        
        LogUtils.debug("kSafeBottomMargin\(kSafeBottomMargin)")
        
        logger.log("this log is OSLog, RxStudy")

    }
}
