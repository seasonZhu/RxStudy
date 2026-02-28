//
//  AppDelegate+AppConfig.swift
//  RxStudy
//
//  Created by dy on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import UIKit

import SVProgressHUD

extension AppDelegate {

    /// 设置应用配置
    func setupAppConfiguration() {
        setupSVProgressHUD()
        // setupKeyboardManager() // IQKeyboardManager 库已移除
        setupNetworkActivityLogger()
    }

    // MARK: - SVProgressHUD 配置

    private func setupSVProgressHUD() {
        SVProgressHUD.setting()
    }

    // MARK: - 键盘管理器配置

    private func setupKeyboardManager() {
        // IQKeyboardManager 库已移除 - 暂时注释
        // // Core functionality
        // IQKeyboardManager.shared.isEnabled = true
        //
        // // Toolbar
        // IQKeyboardToolbarManager.shared.isEnabled = true
        //
        // // Tap to resign
        // IQKeyboardManager.shared.resignOnTouchOutside = false
        //
        // // Appearance
        // IQKeyboardManager.shared.keyboardConfiguration.overrideAppearance = false
        // IQKeyboardManager.shared.keyboardConfiguration.appearance = .default
    }

    // MARK: - 网络日志打印

    private func setupNetworkActivityLogger() {
        #if DEBUG
            NetworkActivityLogger.shared.level = .debug
            NetworkActivityLogger.shared.startLogging()
        #endif
    }
}
