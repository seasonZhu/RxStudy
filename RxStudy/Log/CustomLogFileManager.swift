//
//  CustomLogFileManager.swift
//  RxStudy
//
//  Created by dy on 2023/11/2.
//  Copyright © 2023 season. All rights reserved.
//

import CocoaLumberjack

/// 创建一个自定义的 log 文件管理器类
class CustomLogFileManager: NSObject, DDLogFileManager {

    var maximumNumberOfLogFiles: UInt = 7
    
    var logFilesDiskQuota: UInt64 = 10 * 1024 * 1024
    
    var logsDirectory: String
    
    var unsortedLogFilePaths: [String] {
        /// 返回一个包含所有 log 文件路径的数组
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: logsDirectory)
            let filePaths = fileNames.map { (logsDirectory as NSString).appendingPathComponent($0) }
            return filePaths
        } catch {
            print("Error listing log files: \(error)")
            return []
        }
    }
    
    var unsortedLogFileNames: [String] {
        unsortedLogFilePaths.map { ($0 as NSString).lastPathComponent}
    }
    
    var unsortedLogFileInfos: [DDLogFileInfo] {
        unsortedLogFilePaths.map { DDLogFileInfo(filePath: $0)}
    }
    
    var sortedLogFilePaths: [String] {
        /// 返回一个按日期排序的 log 文件路径数组
        let fileNames = unsortedLogFilePaths
        
        /// 从文件名中提取时间戳
        let timestamps = fileNames.map { fileName in
            (fileName as NSString).lastPathComponent.components(separatedBy: "_").dropFirst().joined(separator: "_")
        }
        
        /// 按时间戳排序文件名
        let sortedFileNames = zip(fileNames, timestamps).sorted { $0.1 > $1.1 }.map { $0.0 }
        
        return sortedFileNames
    }
    
    var sortedLogFileNames: [String] {
        // 返回一个按日期排序的 log 文件名称数组
        let filePaths = sortedLogFilePaths
        let fileNames = filePaths.map { ($0 as NSString).lastPathComponent }
        return fileNames
    }
    
    var sortedLogFileInfos: [DDLogFileInfo] {
        sortedLogFilePaths.map { DDLogFileInfo(filePath: $0)}
    }
    
    
    override init() {
        /// 设置 logsDirectory 为 Documents/Logs 目录
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        logsDirectory = (documentsDirectory as NSString).appendingPathComponent("Logs")
        
        super.init()
        
        /// 创建 logsDirectory 如果它不存在
        do {
            try FileManager.default.createDirectory(atPath: logsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating logs directory: \(error)")
        }
    }
    
    func newLogFileName() -> String {
        /// 返回一个新的 log 文件名，格式为 "AppName_YYYY-MM-DD_HH-mm-ss.log"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown"
        return "\(appName)_\(timestamp).log"
    }
    
    func createNewLogFile() throws -> String {
        /// 在 logsDirectory 中创建一个新的 log 文件，并返回它的路径
        let fileName = newLogFileName()
        let filePath = (logsDirectory as NSString).appendingPathComponent(fileName)
        
        FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        
        return filePath
    }
    
    func deleteOldLogFiles() {
        // 删除超过磁盘配额或最大文件数的旧 log 文件
        let filePaths = sortedLogFilePaths
        
        var totalSize: UInt64 = 0
        var oldestFilePath: String?
        
        for filePath in filePaths {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                if let fileSize = attributes[.size] as? UInt64 {
                    totalSize += fileSize
                }
                if oldestFilePath == nil {
                    oldestFilePath = filePath
                }
            } catch {
                print("Error getting file attributes: \(error)")
            }
        }
        
        while totalSize > logFilesDiskQuota || filePaths.count > maximumNumberOfLogFiles {
            if let filePath = oldestFilePath {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                    totalSize -= fileSize(filePath)
                    print("Deleted old log file: \(filePath)")
                } catch {
                    print("Error deleting file: \(error)")
                }
            }
            
            oldestFilePath = nextOlderPath(oldestFilePath)
        }
    }
    
    // MARK: - Helper methods
    
    func fileSize(_ filePath: String) -> UInt64 {
        // 返回指定文件路径的文件大小（以字节为单位）
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = attributes[.size] as? UInt64 {
                return fileSize
            } else {
                return 0
            }
        } catch {
            print("Error getting file size: \(error)")
            return 0
        }
    }
    
    func nextOlderPath(_ filePath: String?) -> String? {
        // 返回比给定文件路径更旧的文件路径，如果没有则返回 nil
        guard let filePath = filePath else { return nil }
        
        let index = sortedLogFilePaths.firstIndex(of: filePath) ?? NSNotFound
        
        if index != NSNotFound && index + 1 < sortedLogFilePaths.count {
            return sortedLogFilePaths[index + 1]
        } else {
            return nil
        }
    }
}

