import Foundation
import CocoaLumberjack
#if canImport(CocoaLumberjackSwift)
import CocoaLumberjackSwift
#endif
import Alamofire
#if canImport(ZipArchive)
import ZipArchive
#else
import SSZipArchive
#endif

/// 使用真实日志、网络和压缩依赖，所有文件写入隔离临时目录。
final class AppDelegate {}
extension Array {
    var isNotEmpty: Bool { !isEmpty }
}

private final class MockProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        if request.url!.path == "/offline" {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }
        let status = request.url!.path == "/http-error" ? 500 : 200
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json", "Set-Cookie": "cookie-secret"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(#"{"value":"response-marker","token":"response-secret"}"#.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

@main
private enum LogTests {
    private static var assertions = 0

    static func check(_ value: @autoclosure () -> Bool, _ message: String) {
        precondition(value(), message)
        assertions += 1
    }

    static func wait(_ message: String, until predicate: () -> Bool) {
        let deadline = Date().addingTimeInterval(10)
        while !predicate() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.02))
        }
        check(predicate(), message)
    }

    static func main() throws {
        if LoggingConfiguration.mode == .legacy {
            try testLegacyMode()
            return
        }
        AppDelegate().setupLogConfiguration()
        AppDelegate().testSetupLegacyNetwork()
        check(DDLog.allLoggers.isEmpty, "新模式启动了旧接收器")
        let fm = FileManager.default
        let root = fm.temporaryDirectory.appendingPathComponent("RxStudyLogTests-" + UUID().uuidString)
        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: root) }

        let json = ModernLogRedactor.body(Data(#"{"user":{"password":"password-secret","phone":"13800138000"},"token":"token-secret","list":[{"email":"test@example.com"}],"value":"visible"}"#.utf8), contentType: "application/json")
        for secret in ["password-secret", "13800138000", "token-secret", "test@example.com"] {
            check(!json.contains(secret), "JSON 脱敏失败")
        }
        check(json.contains("visible"), "普通 JSON 值不应丢失")
        let form = ModernLogRedactor.body(Data("password=form-secret&value=visible".utf8), contentType: "application/x-www-form-urlencoded")
        check(!form.contains("form-secret") && form.contains("visible"), "表单脱敏失败")
        let url = ModernLogRedactor.url(URL(string: "https://user:pass@example.com/13800138000?access_token=url-secret&q=visible#fragment"))
        check(!url.contains("url-secret") && !url.contains("13800138000") && !url.contains("user:pass") && !url.contains("fragment"), "URL 脱敏失败")
        let headers = ModernLogRedactor.headers(["Authorization": "header-secret", "X-Custom": "custom-secret", "Content-Type": "application/json"])
        check(!headers.contains("header-secret") && !headers.contains("custom-secret") && headers.contains("application"), "请求头脱敏失败")
        let huge = ModernLogRedactor.body(Data(repeating: 65, count: 65537), contentType: "application/json")
        check(huge.contains("65537") && huge.contains("已截断") && huge.utf8.count <= 65536, "超限正文处理失败")
        let expanding = ModernLogRedactor.body(Data(("[" + Array(repeating: "0", count: 32000).joined(separator: ",") + "]").utf8), contentType: "application/json")
        check(expanding.utf8.count <= 65536, "格式化后正文超过限制")
        check(ModernLogRedactor.body(Data("{}".utf8), contentType: "application/octet-stream").contains("二进制正文"), "二进制数据被当作 JSON 记录")
        check(ModernLogRedactor.body(Data([0, 255, 1]), contentType: "application/octet-stream").contains("大小=3"), "二进制摘要失败")
        check(!ModernLogRedactor.body(Data("unstructured-secret".utf8), contentType: "text/plain").contains("unstructured-secret"), "非结构化文本泄露")
        check(ModernLogRedactor.body(nil, contentType: nil) == "无正文", "空正文处理失败")

        let logs = root.appendingPathComponent("ModernLogs")
        let app = ModernLogging(logsDirectory: logs.path)
        app.start()
        let initialCount = DDLog.allLoggers.count
        app.start()
        check(DDLog.allLoggers.count == initialCount, "重复注册日志器")
        let fileLogger = DDLog.allLoggers.compactMap { $0 as? DDFileLogger }.first!
        check(fileLogger.maximumFileSize == 1024 * 1024 && fileLogger.rollingFrequency == 86400, "轮转配置错误")
        check(fileLogger.logFileManager.maximumNumberOfLogFiles == 7 && fileLogger.logFileManager.logFilesDiskQuota == 10 * 1024 * 1024, "配额配置错误")
        let fileManager = fileLogger.logFileManager as! ModernLogFileManager
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown"
        check(!fileManager.isLogFile(withName: appName + "_2026-10-14_10-11-12.log"), "新体系不应识别旧命名日志")
        check(fileManager.isLogFile(withName: fileManager.newLogFileName), "新文件未识别")
        check(!fileManager.isLogFile(withName: "other_2026-10-14_10-11-12.log") && !fileManager.isLogFile(withName: "notes.txt"), "错误识别无关文件")

        try fm.createDirectory(at: logs, withIntermediateDirectories: true)
        let legacyDirectory = root.appendingPathComponent("Logs")
        try fm.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        let legacy = legacyDirectory.appendingPathComponent(appName + "_2020-01-01_00-00-00.log")
        try Data("legacy-export-marker".utf8).write(to: legacy)
        DDLogFileInfo(filePath: legacy.path).isArchived = true

        // 直接验证系统接收器对详细正文的过滤，不依赖系统 Console 的展示策略。
        let system = DDLog.allLoggers.compactMap { $0 as? DDOSLogger }.first!
        let detail = DDLogMessage("file-only-marker", level: .verbose, flag: .debug,
                                  context: ModernLogging.detailContext, file: #file, function: #function,
                                  line: #line, tag: nil, timestamp: nil)
        check(system.logFormatter!.format(message: detail) == nil, "详细正文进入系统接收器")
        let summary = DDLogMessage("summary-marker", level: .verbose, flag: .warning,
                                   context: 0, file: #file, function: #function, line: #line,
                                   tag: nil, timestamp: nil)
        check(system.logFormatter!.format(message: summary) == "summary-marker", "摘要被错误过滤")

        let listener = ModernNetworkLogger.shared
        #if DEBUG
        listener.level = .debug
        #else
        listener.level = .warn
        #endif
        listener.startLogging()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockProtocol.self]
        let session = Session(configuration: configuration)
        let success = session.request("https://example.test/success", method: .post,
                                      parameters: ["value": "request-marker", "password": "request-secret"],
                                      encoding: JSONEncoding.default)
        let http = session.request("https://example.test/http-error")
        let offline = session.request("https://example.test/offline")
        let invalid = session.request("http://[")
        let validation = session.request("https://example.test/validation").validate(statusCode: 201..<300)
        let requests = [success, http, offline, invalid, validation]
        var completed = 0
        for request in requests { request.response { _ in completed += 1 } }
        wait("请求未完成") { completed == requests.count }
        func contents() -> String {
            DDLog.flushLog()
            return fileLogger.logFileManager.sortedLogFilePaths.compactMap { try? String(contentsOfFile: $0, encoding: .utf8) }.joined()
        }
        wait("失败摘要不完整") {
            let text = contents()
            return [http, offline, invalid, validation].allSatisfy { text.contains("[网络][失败] id=\($0.id)") }
        }
        let logged = contents()
        for secret in ["request-secret", "response-secret", "cookie-secret"] { check(!logged.contains(secret), "网络日志泄露凭据") }
        #if DEBUG
        check(logged.contains("[网络][响应] id=\(success.id)"), "成功摘要缺失")
        check(logged.components(separatedBy: "[网络][请求] id=\(success.id)").count == 2, "请求开始日志重复或缺失")
        check(logged.contains("request-marker") && logged.contains("response-marker"), "Debug 文件缺少正文")
        #else
        check(!logged.contains(success.id.uuidString), "Release 记录了成功请求")
        check(!logged.contains("request-marker") && !logged.contains("response-marker"), "Release 记录了正文")
        #endif
        listener.stopLogging()

        DDLogWarn("export-latest-marker")
        var export: Result<URL, Error>?
        app.exportLogs { result in
            check(Thread.isMainThread, "导出回调不在主线程")
            export = result
        }
        wait("导出未完成") { export != nil }
        let archive = try export!.get()
        defer { try? fm.removeItem(at: archive) }
        check(fm.fileExists(atPath: archive.path), "成功 ZIP 被删除")
        let extracted = root.appendingPathComponent("Extracted")
        check(SSZipArchive.unzipFile(atPath: archive.path, toDestination: extracted.path), "ZIP 无法解压")
        let exported = try fm.contentsOfDirectory(at: extracted, includingPropertiesForKeys: nil)
            .compactMap { try? String(contentsOf: $0, encoding: .utf8) }.joined()
        check(exported.contains("export-latest-marker"), "导出缺少最近写入的日志")
        check(!exported.contains("legacy-export-marker"), "新体系导出了旧目录日志")

        let rotationManager = ModernLogFileManager(logsDirectory: root.appendingPathComponent("Rotation").path)
        let rotationLogger = DDFileLogger(logFileManager: rotationManager)
        rotationLogger.maximumFileSize = 128
        let rotationLog = DDLog()
        rotationLog.add(rotationLogger)
        rotationLog.log(asynchronous: false, message: DDLogMessage(
            DDLogMessageFormat(stringLiteral: String(repeating: "x", count: 256)),
            level: .verbose, flag: .warning))
        wait("达到大小后未轮转") { rotationManager.sortedLogFileInfos.contains { $0.isArchived } }
        rotationLogger.maximumFileSize = 0
        rotationLogger.rollingFrequency = 0.05
        rotationLog.log(asynchronous: false, message: DDLogMessage("时间轮转验证", level: .verbose, flag: .warning))
        wait("到期后未轮转") { rotationManager.sortedLogFileInfos.filter { $0.isArchived }.count >= 2 }
        rotationLog.removeAllLoggers()

        // 独立目录验证归档清理和活动文件保护。
        let quotaDirectory = root.appendingPathComponent("Quota")
        try fm.createDirectory(at: quotaDirectory, withIntermediateDirectories: true)
        let quota = ModernLogFileManager(logsDirectory: quotaDirectory.path)
        let quotaLogger = DDFileLogger(logFileManager: quota)
        quota.maximumNumberOfLogFiles = 100
        quota.logFilesDiskQuota = 1024 * 1024
        let unrelated = quotaDirectory.appendingPathComponent("notes.txt")
        try Data("keep".utf8).write(to: unrelated)
        for index in 0..<10 {
            let path = quotaDirectory.appendingPathComponent(String(quota.newLogFileName.dropLast(4)) + " \(index).log")
            try Data(repeating: 65, count: 100).write(to: path)
            DDLogFileInfo(filePath: path.path).isArchived = true
        }
        quota.maximumNumberOfLogFiles = 7
        wait("归档数量未清理") { quota.sortedLogFilePaths.count <= 7 }
        check(fm.fileExists(atPath: unrelated.path), "清理误删无关文件")
        quota.logFilesDiskQuota = 250
        wait("归档配额未生效") { quota.sortedLogFileInfos.reduce(0) { $0 + $1.fileSize } <= 250 }
        let active = quotaDirectory.appendingPathComponent(quota.newLogFileName)
        try Data(repeating: 65, count: 1000).write(to: active)
        quota.logFilesDiskQuota = 1
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        check(fm.fileExists(atPath: active.path), "清理删除活动文件")

        let notConfigured = ModernLogging(logsDirectory: root.appendingPathComponent("Unused").path)
        var failedExport = false
        notConfigured.exportLogs { result in
            if case .failure = result { failedExport = true }
        }
        wait("未初始化导出没有返回错误") { failedExport }
        let emptyApp = ModernLogging(logsDirectory: root.appendingPathComponent("Empty").path)
        emptyApp.start()
        var emptyError: String?
        emptyApp.exportLogs { result in
            if case .failure(let error) = result { emptyError = error.localizedDescription }
        }
        wait("空日志导出没有返回错误") { emptyError != nil }
        check(emptyError == "没有可导出的日志", "空日志错误不明确")

        // 成功压缩使用真实 ZIP 库；失败通过注入压缩结果确定性触发。
        let failedApp = ModernLogging(logsDirectory: root.appendingPathComponent("CompressionFailure").path,
                               createArchive: { _, _ in false })
        failedApp.start()
        DDLogWarn("压缩失败路径验证")
        var compressionError: String?
        var failureCallbacks = 0
        failedApp.exportLogs { result in
            failureCallbacks += 1
            if case .failure(let error) = result { compressionError = error.localizedDescription }
        }
        wait("压缩失败没有返回错误") { compressionError != nil }
        check(compressionError == "日志压缩失败" && failureCallbacks == 1, "压缩失败回调错误")
        check(try! String(contentsOf: legacy, encoding: .utf8) == "legacy-export-marker", "新体系清理影响了旧目录")
        withExtendedLifetime(quotaLogger) {}
        DDLog.removeAllLoggers()
        print("通过：\(assertions) 项日志验证")
    }
    static func testLegacyMode() throws {
        let fm = FileManager.default
        check(DDLog.allLoggers.isEmpty, "测试启动前已有接收器")
        ModernLogging.shared.start()
        check(DDLog.allLoggers.isEmpty, "旧模式启动了新接收器")
        var inactiveError: String?
        ModernLogging.shared.exportLogs { result in
            check(Thread.isMainThread, "未启用错误回调不在主队列")
            if case .failure(let error) = result { inactiveError = error.localizedDescription }
        }
        wait("旧模式导出未返回") { inactiveError != nil }
        check(inactiveError == "新日志体系未启用", "旧模式导出错误不明确")
        let delegate = AppDelegate()
        delegate.setupLogConfiguration()
        check(DDLog.allLoggers.count == 2, "旧体系接收器数量改变")
        let system = DDLog.allLoggers.compactMap { $0 as? DDOSLogger }.first!
        check(system === DDOSLogger.sharedInstance, "旧体系系统接收器被替换")
        let file = DDLog.allLoggers.compactMap { $0 as? DDFileLogger }.first!
        check(file.logFileManager is CustomLogFileManager, "旧体系文件管理器被替换")
        let legacyDirectory = URL(fileURLWithPath: file.logFileManager.logsDirectory)
        let modernDirectory = legacyDirectory.deletingLastPathComponent().appendingPathComponent("ModernLogs")
        try fm.createDirectory(at: modernDirectory, withIntermediateDirectories: true)
        let sentinel = modernDirectory.appendingPathComponent("modern-sentinel.log")
        try Data("modern-marker".utf8).write(to: sentinel)
        DDLogWarn("legacy-file-marker")
        DDLog.flushLog()
        check(file.logFileManager.sortedLogFilePaths.allSatisfy { $0.hasPrefix(legacyDirectory.path + "/") }, "旧体系读取了新目录")
        ModernLogging.shared.start()
        check(DDLog.allLoggers.count == 2, "旧模式额外注册了新接收器")
        delegate.testSetupLegacyNetwork()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockProtocol.self]
        let session = Session(configuration: configuration)
        var completed = false
        session.request("https://example.test/legacy-network-marker").response { _ in completed = true }
        wait("旧网络请求未完成") { completed }
        RunLoop.current.run(until: Date().addingTimeInterval(0.15))
        NetworkActivityLogger.shared.stopLogging()
        DDLog.flushLog()
        let text = file.logFileManager.sortedLogFilePaths.compactMap { try? String(contentsOfFile: $0, encoding: .utf8) }.joined()
        check(text.contains("legacy-file-marker"), "旧文件日志未写入")
        check(!text.contains("[网络]"), "旧模式写入了新体系网络日志")
        check(try! String(contentsOf: sentinel, encoding: .utf8) == "modern-marker", "旧体系影响了新目录")
        DDLog.removeAllLoggers()
        print("旧模式通过：\(assertions) 项验证")
    }

}
