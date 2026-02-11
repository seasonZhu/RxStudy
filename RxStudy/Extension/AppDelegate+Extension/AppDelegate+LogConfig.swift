//
//  AppDelegate+LogConfig.swift
//  RxStudy
//
//  Created by dy on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SSZipArchive

extension AppDelegate {

    /// 设置日志配置
    func setupLogConfiguration() {
        #if DEBUG
        dynamicLogLevel = .verbose
        #else
        dynamicLogLevel = .warning
        #endif

        DDLog.add(DDOSLogger.sharedInstance)

        let fileLogger = DDFileLogger(logFileManager: CustomLogFileManager())
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        fileLogger.logFormatter = CustomLogFormatter()

        DDLog.add(fileLogger)

        print("logsDirectory: \(fileLogger.logFileManager.logsDirectory)")
        print("sortedLogFilePaths: \(fileLogger.logFileManager.sortedLogFilePaths)")
    }

    /// 上传日志
    func uploadLogs() {
        let fileLogger = DDFileLogger()
        let filePaths = fileLogger.logFileManager.sortedLogFilePaths

        guard filePaths.isNotEmpty else { return }

        let zipName = "Logs\(Date().timeIntervalSince1970)"
        let zipPath = fileLogger.logFileManager.logsDirectory.replacingOccurrences(of: "Logs", with: "\(zipName).zip")

        let result = SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: filePaths)

        if result {
            let zipURL = URL(fileURLWithPath: zipPath)
            // TODO: 实现上传逻辑
            try? FileManager.default.removeItem(atPath: zipPath)
        }
    }
}
