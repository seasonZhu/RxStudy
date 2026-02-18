//
//  DebugLog.swift
//  RxStudy
//
//  Created by dy on 2021/9/3.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation
// import CocoaLumberjack // CocoaLumberjack API changed - temporarily disabled

enum LogUtils {
    enum LogType {
        case debug
        case info
        case warn
        case verbose
        case error
    }

    static var logcat: ((String) -> Void)?

    static func debug(_ items: Any...) {
        print(items, type: .debug)
    }

    static func info(_ items: Any...) {
        print(items, type: .info)
    }

    static func warn(_ items: Any...) {
        print(items, type: .warn)
    }

    static func verbose(_ items: Any...) {
        print(items, type: .verbose)
    }

    static func error(_ items: Any...) {
        print(items, type: .error)
    }

    static func logcat(_ logcat: @escaping ((String) -> Void)) {
        self.logcat = logcat
    }
}

extension LogUtils {
    private static func print(_ items: Any..., type: LogType = .debug) {
        let strings = items.map { String(describing: $0) }.joined(separator: ", ")
        logcat?(strings)
        // CocoaLumberjack API changed - using regular print for now
        // let message = DDLogMessageFormat(stringLiteral: "\(strings)")
        // type.log(message: message)
        Swift.print("[\(type)] \(strings)")
    }
}

extension LogUtils.LogType {
    fileprivate func log(message: String) {
        switch self {
        case .debug:
            Swift.print("[DEBUG] \(message)")
        case .info:
            Swift.print("[INFO] \(message)")
        case .warn:
            Swift.print("[WARN] \(message)")
        case .verbose:
            Swift.print("[VERBOSE] \(message)")
        case .error:
            Swift.print("[ERROR] \(message)")
        }
    }
}

/// 仅在Debug模式下打印,我小看了print,这个方法打印出来的效果和print打印出来的效果完全不一样
public func debugLog(_ items: Any...) {
    let strings = items.map { String(describing: $0) }.joined(separator: ", ")
    // CocoaLumberjack API changed - using regular print for now
    // let message = DDLogMessageFormat(stringLiteral: "\(strings)")
    // DDLogDebug(message)
    Swift.print("[DEBUG] \(strings)")
}
