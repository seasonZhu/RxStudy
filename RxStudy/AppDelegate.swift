//
//  AppDelegate.swift
//  RxStudy
//
//  Created by season on 2019/1/29.
//  Copyright © 2019 season. All rights reserved.
//

import UIKit

import SVProgressHUD

#if canImport(Flutter)
import Flutter
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    #if canImport(Flutter)
    lazy var lifeCycleDelegate = FlutterPluginAppLifeCycleDelegate()
    #endif

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        #if canImport(Flutter) && canImport(FlutterPluginRegistrant)
        /// 初始化Flutter模块
        FlutterManager.shared()
        #endif
        
        /// 初始化UniApp模块
        UniMPManager.shared.initDCUniMPSDKEngineEnvironment(launchOptions: launchOptions)
        
        /// 崩溃配置
        installCrashHandler()
        
        /// 日志配置
        logSetting()
        
        /// 路由配置
        routerSetting()
        
        /// 键盘配置
        IQKeyboardManagerSetting()
        
        /// SVProgressHUD配置
        SVProgressHUD.setting()
        
        /// 网络状态监听
        networkListening()
        
        /// 网络请求日志打印配置
        networkActivityLogSetting()
        
        /// CocoaDebug配置
        cocoaDebugSetting()
        
        /// 生命周期跟踪
        lifetimeTrackerSetting()
        
        /// 屏幕截图\录屏监听
        screenCapturedListen()
        
        /// 自动登录
        AccountManager.shared.autoLogin()
        
        /// APIKey安全读取
        apiKeySafeLoad()
        
        /// LogUtils的简单使用
        LogUtils.debug("哈哈", "呵呵")
        
        LogUtils.debug("kStatusBarHeight\(kStatusBarHeight)")
        
        LogUtils.debug("kSafeBottomMargin\(kSafeBottomMargin)")
        
        logger.log("this log is OSLog, RxStudy")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: UISceneSession Lifecycle
extension AppDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - 通过Safari跳转到App
extension AppDelegate {
    /// 在Safari浏览器中输入wandroid://hotkey,可以跳转到热词搜索页
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        let urlString = url.absoluteString
        debugLog("urlString: \(urlString)")

        /// 外部网页路由到App的逻辑
        if urlString.contains("wandroid://") {
            /// 如果你把项目玩崩溃了,然后又想测试从Safari浏览器跳转到App,目前仅注册了"wandroid://hotkey",然后崩溃弹窗会导致无法路由,这里传[LAJumpTypeKey: "4"]可以解决
            TheRouter.openURL(urlString, userInfo: [LAJumpTypeKey: "4"])
        }
        
        return true
    }
}

// MARK: - 网络日志打印
extension AppDelegate {
    private func networkActivityLogSetting() {
        #if DEBUG
            NetworkActivityLogger.shared.level = .debug
            NetworkActivityLogger.shared.startLogging()
        #endif
    }
}

// MARK: - 网络状态监听
import Alamofire

extension AppDelegate {
    private func networkListening() {
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { _ in
            let value = NetworkReachabilityManager.default?.isReachable == true
            AccountManager.shared.networkIsReachableRelay.accept(value)
        })
    }
    
    /// iOS17.4+ 可以使用原生的NWPathMonitor进行监听
    /// 同时使用Rx的可能效果优化会更好
    private func networkMonitorListening() {
        NetworkMonitor.shared.addListener { status in
            print("isConnected=\(status.isConnected), interface=\(status.interface)")
            let value = status.isConnected
            AccountManager.shared.networkIsReachableRelay.accept(value)
        }
        
        NetworkMonitor.shared.start()
        
        NetworkMonitor.shared.statusObservable
            .distinctUntilChanged()
            .subscribe(onNext: { status in
                print("Rx: isConnected=\(status.isConnected), interface=\(status.interface)")
                let value = status.isConnected
                AccountManager.shared.networkIsReachableRelay.accept(value)
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - CocoaDebug配置
#if DEBUG
import CocoaDebug
#endif

extension AppDelegate {
    private func cocoaDebugSetting() {
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
    private func lifetimeTrackerSetting() {
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

// MARK: - 崩溃配置
import KSCrash

extension AppDelegate {
    private func installCrashHandler() {
        let installation = makeEmailInstallation()
        let config = KSCrashConfiguration()
        try? installation.install(with: config)
        installation.sendAllReports { array, error in
            if array?.isNotEmpty == true {
                print("Sent \(array?.count ?? 0) reports")
            } else {
                /// 如果你把App玩崩溃了,然后正好手机又没有配置邮箱,就把这里deleteAllReports
                /// KSCrashReportStore
                let store = try? CrashReportStore.init(configuration: CrashReportStoreConfiguration())
                store?.deleteAllReports()
                print("Failed to send reports: \(error.debugDescription)")
            }
        }
    }
    
    private func makeEmailInstallation() -> CrashInstallation {
        let emailAddress = "zhujilong1987@163.com"
        let email = CrashInstallationEmail.shared
        email.recipients = [emailAddress]
        email.subject = "Crash Report"
        email.message = "This is a crash report"
        email.filenameFmt = "crash-report-%d.txt.gz"
        
        email.addConditionalAlert(withTitle: "Crash Detected", message: "The app crashed last time it was launched. Send a crash report?", yesAnswer: "Sure!", noAnswer: "No thanks")
        
        email.setReportStyle(.JSON, useDefaultFilenameFormat: true)
        
        return email
        
    }
}

// MARK: - 本地日志与上传

import CocoaLumberjack
import SSZipArchive

extension AppDelegate {
    private func logSetting() {
        #if DEBUG
        dynamicLogLevel = .verbose
        #else
        dynamicLogLevel = .warning
        #endif
                
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log

        /// 设置 file logger 的文件管理器为自定义的类
        let fileLogger = DDFileLogger(logFileManager: CustomLogFileManager()) // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        
        /// 设置 file logger 的格式器
        fileLogger.logFormatter = CustomLogFormatter()
        
        DDLog.add(fileLogger)
        
        /// /var/mobile/Containers/Data/Application/4C9CBFDB-5752-4163-B2F4-8B96F3DB5193/Library/Caches/Logs
        print("logsDirectory: \(fileLogger.logFileManager.logsDirectory)")
        
        print("sortedLogFilePaths: \(fileLogger.logFileManager.sortedLogFilePaths)")
    }
    
    private func logsUpload() {
        let fileLogger = DDFileLogger()
        
        let filePaths = fileLogger.logFileManager.sortedLogFilePaths

        if filePaths.isNotEmpty {
            
            let zipName = "Logs\(Date().timeIntervalSince1970)"
            
            let zipPath = fileLogger.logFileManager.logsDirectory.replacingOccurrences(of: "Logs", with: "\(zipName).zip")
            
            let result = SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: filePaths)
            
            /// 压缩成功
            if result {
                
                let zipURL = URL(fileURLWithPath: zipPath)
                
                var isUploadSuccess = true
                
                if isUploadSuccess {
                    /// 如果上传成功,压缩文件zip进行删除和文件夹里的文件都进行删除
                    try? FileManager.default.removeItem(atPath: zipPath)
                    
                    filePaths.forEach { filePath in
                        try? FileManager.default.removeItem(atPath: filePath)
                    }
                } else {
                    /// 如果上传失败,压缩文件zip进行删除
                    try? FileManager.default.removeItem(atPath: zipPath)
                }
            }
        }
    }
}

// MARK: - 屏幕截图\录屏监听
extension AppDelegate {
    private func screenCapturedListen() {
        /// 监听截屏
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { _ in
            print("屏幕正在被截屏")
        }
        
        /// 监听录屏
        NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: nil, queue: .main) { _ in
            if UIScreen.main.isCaptured {
                /// 屏幕正在被捕获，可以在这里做一些隐藏内容的操作，比如
                /// 显示一个覆盖所有内容的视图
                print("屏幕正在被捕获，可以在这里做一些隐藏内容的操作")
            } else {
                /// 屏幕没有被捕获，可以移除那个覆盖的视图
                print("屏幕没有被捕获，可以移除那个覆盖的视图")
            }
        }
    }
}

// MARK: - 路由配置

import TheRouter

/// 服务路由
public let serivceHost = "scheme://services?"

/// web跳转路由
public let webRouterUrl = "scheme://webview/home"

extension AppDelegate {
    func routerSetting() {
        // 日志回调，可以监控线上路由运行情况
        TheRouter.logcat { url, logType, errorMsg in
            debugLog("TheRouter: logMsg- \(url) \(logType.rawValue) \(errorMsg)")
        }
        
        // 类似RDVTabBarControlle也没有继承UITabbarController，导航栈也不同，那么就需要自己实现各种跳转逻辑
        // 实现的这个方法后,系统的跳转逻辑都不走了
//        TheRouter.customJumpAction { _, _ in
//
//        }
        
        // 路由懒加载注册,
        // - excludeCocoapods: 是否对Cocoapods生成的组件进行动态注册
        // - excludeCocoapods = true 不对Cocoapods生成的组件进行动态注册， false 对Cocoapods生成的组件也进行遍历动态注册
        // - useCache: 是否开启本地缓存功能
        TheRouterManager.loadRouterClass(excludeCocoapods: true, useCache: true)
        
        TheRouter.lazyRegisterRouterHandle { url, userInfo in
            TheRouterManager.injectRouterServiceConfig(webRouterUrl, serivceHost)
            /// - Parameters:
            ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
            ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
            ///   - urlPath: 将要打开的路由path
            ///   - userInfo: 路由传递的参数
            ///   - forceCheckEnable: 是否支持强制校验，强制校验要求Api声明与对应的类必须实现TheRouterAble协议
            ///   - forceCheckEnable 强制打开TheRouterApi定义的便捷类与实现TheRouterAble协议类是否相同，打开的话，debug环境会自动检测，避免线上出问题，建议打开
            ///   这里没有强制校验，因为我并没有整理路由表类
            return TheRouterManager.addGloableRouter(true, url, userInfo, forceCheckEnable: true)
        }
            
        // 动态注册服务
        TheRouterManager.registerServices(excludeCocoapods: true)
        
    }
}

// MARK: - IQKeyboardManager配置
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

extension AppDelegate {
    private func IQKeyboardManagerSetting() {
        // Core functionality
        IQKeyboardManager.shared.isEnabled = true
        // IQKeyboardManager.shared.keyboardDistance = 20.0
        
        // Toolbar (if using IQKeyboardToolbarManager subspec)
        // 更新到8.0.0之后,键盘上面工具栏需要单独开启
        IQKeyboardToolbarManager.shared.isEnabled = true
        
        // Tap to resign (if using Resign subspec)
        // 点击其他区域是否收起键盘
        IQKeyboardManager.shared.resignOnTouchOutside = false
        
        // Appearance (if using Appearance subspec)
        // 键盘样式,可以切换白天与黑暗模式
        IQKeyboardManager.shared.keyboardConfiguration.overrideAppearance = false
        
        IQKeyboardManager.shared.keyboardConfiguration.appearance = .default
    }
}

#if canImport(Flutter)
// MARK: - 原生页面跳转跳转到指定Flutter页面
extension AppDelegate: FlutterAppLifeCycleProvider {
    func add(_ delegate: FlutterApplicationLifeCycleDelegate) {
        lifeCycleDelegate.add(delegate)
    }
}
#endif

// MARK: - APIKey安全读取
extension AppDelegate {
    func apiKeySafeLoad() {
        /// 方案一：使用配置文件（.xcconfig）,这里不要被文章搞混淆了,直接使用Build Setting,User-Defined配置,再到Info.plist中设置即可
        if let amapApiKey = Bundle.main.object(forInfoDictionaryKey: "AMAP_API_KEY") as? String {
            print("amapApiKey:\(amapApiKey)")
        }
        
        if let umApiKey = Bundle.main.object(forInfoDictionaryKey: "UM_API_KEY") as? String {
            print("umApiKey:\(umApiKey)")
        }
        
        /// 方案二：通过按需资源（On-Demand Resources）保护API密钥,在Resource Tags进行配置
        KeyConstants.loadAPIKeys { result in
            switch result {
            case .success(let success):
                print("myServiceXKey:\(KeyConstants.APIKeys.myServiceXKey)")
                print("myServiceYKey:\(KeyConstants.APIKeys.myServiceYKey)")
            case .failure(let failure):
                break
            }
        }
        
        /// 方案五：混淆技术保护密钥,这里我查了一下,这里并不是混淆
        print("testKey:\(testKey)")
    }
}
