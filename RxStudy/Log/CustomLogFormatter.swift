//
//  CustomLogFormatter.swift
//  RxStudy
//
//  Created by dy on 2023/11/2.
//  Copyright © 2023 season. All rights reserved.
//

import CocoaLumberjack

/// 创建一个自定义的 log 格式器类
class CustomLogFormatter: NSObject, DDLogFormatter {
    let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        let level = logLevelString(logMessage.flag)
        let context = logMessage.context
        let message = logMessage.message
        return "[\(timestamp)] [\(level)] [\(context)] \(message)"
    }
    
    func logLevelString(_ level: DDLogFlag) -> String {
        switch level {
        case .error: return "ERROR"
        case .warning: return "WARNING"
        case .info: return "INFO"
        case .debug: return "DEBUG"
        case .verbose: return "VERBOSE"
        default: return "UNKNOWN"
        }
    }
}
