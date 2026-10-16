//
//  ModernNetworkLogger.swift
//  AlamofireModernNetworkLogger
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Konstantin Kabanov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Alamofire
import Foundation
import CocoaLumberjack
#if canImport(CocoaLumberjackSwift)
import CocoaLumberjackSwift
#endif

/// 新体系的网络日志详细程度；Release 始终只记录失败摘要。
enum ModernNetworkLogLevel {
    case off
    case debug
    case info
    case warn
    case error
    case fatal
}

/// 将 Alamofire 请求摘要写入系统与文件日志，Debug 正文写入文件和控制台。
final class ModernNetworkLogger {
    static let shared = ModernNetworkLogger()
    var level: ModernNetworkLogLevel = .info
    var filterPredicate: NSPredicate?

    private let queue = DispatchQueue(label: "RxStudy.NetworkLog")
    private var startedAt: [UUID: TimeInterval] = [:]
    private var loggedStarts: Set<UUID> = []

    init() {}

    deinit { NotificationCenter.default.removeObserver(self) }

    func startLogging() {
        guard LoggingConfiguration.mode == .modern else { return }
        stopLogging()
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(requestDidStart(notification:)),
                           name: Request.didResumeNotification, object: nil)
        // Request 恢复通知可能早于 URLRequest 创建，task 恢复后再补齐请求详情。
        center.addObserver(self, selector: #selector(requestDidStart(notification:)),
                           name: Request.didResumeTaskNotification, object: nil)
        center.addObserver(self, selector: #selector(requestDidFinish(notification:)),
                           name: Request.didFinishNotification, object: nil)
    }

    func stopLogging() {
        NotificationCenter.default.removeObserver(self)
        queue.async {
            self.startedAt.removeAll()
            self.loggedStarts.removeAll()
        }
    }

    @objc private func requestDidStart(notification: Notification) {
        guard let request = notification.request as? DataRequest else { return }
        queue.async {
            guard self.level != .off, self.level != .fatal else { return }
            let urlRequest = request.request ?? request.task?.originalRequest
            if let urlRequest, self.filterPredicate?.evaluate(with: urlRequest) == true { return }
            // 重试或暂停后恢复仍使用同一关联 ID，不覆盖首次开始时间。
            if self.startedAt[request.id] == nil {
                self.startedAt[request.id] = ProcessInfo.processInfo.systemUptime
            }
            #if DEBUG
            guard self.level == .debug || self.level == .info,
                  let urlRequest, self.loggedStarts.insert(request.id).inserted else { return }
            DDLogInfo("[网络][请求] \(self.summary(request, urlRequest: urlRequest))")
            if self.level == .debug {
                let headers = ModernLogRedactor.headers(urlRequest.allHTTPHeaderFields ?? [:])
                let body = ModernLogRedactor.body(urlRequest.httpBody,
                                                   contentType: urlRequest.value(forHTTPHeaderField: "Content-Type"))
                DDLogDebug("---------------------\n[网络][请求详情] \(self.summary(request, urlRequest: urlRequest))\nHeaders:\n\(headers)\nBody:\n\(body)",
                           context: ModernLogging.detailContext)
            }
            #endif
        }
    }

    @objc private func requestDidFinish(notification: Notification) {
        guard let request = notification.request as? DataRequest else { return }
        queue.async {
            let start = self.startedAt.removeValue(forKey: request.id)
            self.loggedStarts.remove(request.id)
            guard self.level != .off, self.level != .fatal else { return }
            let urlRequest = request.request ?? request.task?.originalRequest
            if let urlRequest, self.filterPredicate?.evaluate(with: urlRequest) == true { return }
            let status = request.response?.statusCode
            let failed = request.error != nil || status.map { $0 >= 400 } == true
            let elapsed = request.metrics?.taskInterval.duration
                ?? start.map { ProcessInfo.processInfo.systemUptime - $0 }
            let duration = elapsed.map { String(format: "%.3fs", $0) } ?? "未知"
            let summary = "\(self.summary(request, urlRequest: urlRequest)) status=\(status.map(String.init) ?? "未知") 耗时=\(duration)"
            if failed {
                let error = request.error.map {
                    LoggingConfiguration.redactionEnabled
                        ? "\(($0 as NSError).domain):\(($0 as NSError).code)"
                        : $0.localizedDescription
                } ?? "HTTP"
                DDLogWarn("[网络][失败] \(summary) error=\(error)")
            }
            #if DEBUG
            if !failed && (self.level == .debug || self.level == .info) {
                DDLogInfo("[网络][响应] \(summary)")
            }
            if self.level == .debug {
                let headers = request.response?.allHeaderFields.reduce(into: [String: String]()) {
                    $0[String(describing: $1.key)] = String(describing: $1.value)
                } ?? [:]
                let body = ModernLogRedactor.body(request.data,
                                                   contentType: request.response?.value(forHTTPHeaderField: "Content-Type"))
                DDLogDebug("---------------------\n[网络][响应详情] \(summary)\nHeaders:\n\(ModernLogRedactor.headers(headers))\nBody:\n\(body)",
                           context: ModernLogging.detailContext)
            }
            #endif
        }
    }

    private func summary(_ request: DataRequest, urlRequest: URLRequest?) -> String {
        let method = urlRequest?.httpMethod ?? "未知"
        return "id=\(request.id) \(method) \(ModernLogRedactor.url(urlRequest?.url))"
    }
}
