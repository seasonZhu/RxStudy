//
//  AppDelegate.swift
//  RxStudy
//
//  Created by season on 2019/1/29.
//  Copyright © 2019 season. All rights reserved.
//

import UIKit

import IQKeyboardManagerSwift
import Alamofire
import SVProgressHUD
import KSCrash
import LifetimeTracker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /// 崩溃配置
        installCrashHandler()
        
        /// 日志配置
        logSetting()
        
        /// 键盘配置
        IQKeyboardManager.shared.enable = true
        
        /// SVProgressHUD配置
        SVProgressHUD.setting()
        
        /// 网络请求日志打印配置
        #if DEBUG
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        #endif
        
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
        
        /// 背景色配置
        window?.backgroundColor = .playAndroidBackground
        
        /// 自动登录
        AccountManager.shared.autoLogin()
        
        /// 网络状态监听
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { _ in
            let value = NetworkReachabilityManager.default?.isReachable == true
            AccountManager.shared.networkIsReachableRelay.accept(value)
        })
        
        screenCapturedListen()
        
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

extension AppDelegate {
    private func installCrashHandler() {
        let installation = makeEmailInstallation()
        installation.install()
        KSCrash.sharedInstance().deleteBehaviorAfterSendAll = KSCDeleteBehavior(rawValue: 0)
        installation.sendAllReports { array, completed, error in
            if completed {
                print("Sent \(array?.count ?? 0) reports")
            } else {
                print("Failed to send reports: \(error.debugDescription)")
            }
        }
    }
    
    private func makeEmailInstallation() -> KSCrashInstallation {
        let emailAddress = "zhujilong1987@163.com"
        let email = KSCrashInstallationEmail.sharedInstance()!
        email.recipients = [emailAddress]
        email.subject = "Crash Report"
        email.message = "This is a crash report"
        email.filenameFmt = "crash-report-%d.txt.gz"
        
        email.addConditionalAlert(withTitle: "Crash Detected", message: "The app crashed last time it was launched. Send a crash report?", yesAnswer: "Sure!", noAnswer: "No thanks")
        
        email.setReportStyle(KSCrashEmailReportStyle(rawValue: 1), useDefaultFilenameFormat: true)
        
        return email
        
    }
}

import CocoaLumberjack
import SSZipArchive

extension AppDelegate {
    func logSetting() {
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
    
    func logsUpload() {
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
