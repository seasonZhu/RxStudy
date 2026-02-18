//
//  AppDelegate.swift
//  RxStudy
//
//  Created by season on 2019/1/29.
//  Copyright © 2019 season. All rights reserved.
//

import UIKit

#if canImport(Flutter)
import Flutter
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /// 服务路由
    let serivceHost = "scheme://services?"

    /// web跳转路由
    let webRouterUrl = "scheme://webview/home"

    #if canImport(Flutter)
    lazy var lifeCycleDelegate = FlutterPluginAppLifeCycleDelegate()
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // MARK: - 跨平台模块初始化
        setupCrossPlatformModules(launchOptions: launchOptions)

        // MARK: - 应用配置
        setupAppConfiguration()
        setupCrashHandler()
        setupLogConfiguration()
        setupRouterConfiguration()
        setupNetworkMonitoring()
        setupScreenCaptureMonitoring()
        setupSecurityConfiguration()

        // MARK: - 调试工具配置
        setupDebugTools()

        // MARK: - 自动登录
        AccountManager.shared.autoLogin()

        // MARK: - 调试日志
        logPrintDebug()

        return true
    }

    // MARK: - Cross Platform Modules

    private func setupCrossPlatformModules(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        #if canImport(Flutter) && canImport(FlutterPluginRegistrant)
        FlutterManager.shared()
        #endif

        // UniMP 库已移除 - 暂时注释
        // UniMPManager.shared.initDCUniMPSDKEngineEnvironment(launchOptions: launchOptions)
    }

    // MARK: - UIApplication Lifecycle

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

// MARK: - UISceneSession Lifecycle

extension AppDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

// MARK: - URL Handling

extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let urlString = url.absoluteString
        debugLog("urlString: \(urlString)")

        if urlString.contains("wandroid://") {
            TheRouter.openURL(urlString, userInfo: [LAJumpTypeKey: "4"])
        }

        return true
    }
}

// MARK: - Flutter Lifecycle

#if canImport(Flutter)
extension AppDelegate: FlutterAppLifeCycleProvider {
    func add(_ delegate: FlutterApplicationLifeCycleDelegate) {
        lifeCycleDelegate.add(delegate)
    }
}
#endif
