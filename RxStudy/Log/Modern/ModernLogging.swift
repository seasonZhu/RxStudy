import Foundation
import CocoaLumberjack
#if canImport(CocoaLumberjackSwift)
import CocoaLumberjackSwift
#endif
#if canImport(ZipArchive)
import ZipArchive
#else
import SSZipArchive
#endif

/// 详细正文使用专用 context，仅文件接收器保留。
private final class ModernSystemLogFormatter: NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        logMessage.context == ModernLogging.detailContext ? nil : logMessage.message
    }
}

final class ModernLogging {
    static let shared = ModernLogging()
    static let subsystem = Bundle.main.bundleIdentifier ?? "RxStudy"
    static let detailContext = 1001

    private let exportQueue = DispatchQueue(label: "RxStudy.LogExport", qos: .utility)
    private let configurationLock = NSLock()
    private var fileLogger: DDFileLogger?

    private let logsDirectory: String?
    private let createArchive: (String, [String]) -> Bool

    /// 测试可传入隔离目录；应用默认仍使用 Documents/ModernLogs。
    init(logsDirectory: String? = nil,
         createArchive: @escaping (String, [String]) -> Bool = {
             SSZipArchive.createZipFile(atPath: $0, withFilesAtPaths: $1)
         }) {
        self.logsDirectory = logsDirectory
        self.createArchive = createArchive
    }

    func start() {
        guard LoggingConfiguration.mode == .modern else { return }
        configurationLock.lock()
        defer { configurationLock.unlock() }
        guard fileLogger == nil else { return }
        #if DEBUG
        dynamicLogLevel = .verbose
        #else
        dynamicLogLevel = .warning
        #endif

        let systemLogger = DDOSLogger(subsystem: Self.subsystem, category: "app")
        systemLogger.logFormatter = ModernSystemLogFormatter()
        let manager = logsDirectory.map { ModernLogFileManager(logsDirectory: $0) }
            ?? ModernLogFileManager()
        manager.maximumNumberOfLogFiles = 7
        manager.logFilesDiskQuota = 10 * 1024 * 1024
        let fileLogger = DDFileLogger(logFileManager: manager)
        fileLogger.rollingFrequency = 24 * 60 * 60
        fileLogger.maximumFileSize = 1024 * 1024
        fileLogger.logFormatter = ModernLogFormatter()
        self.fileLogger = fileLogger
        DDLog.add(systemLogger, with: dynamicLogLevel)
        DDLog.add(fileLogger, with: dynamicLogLevel)
        #if DEBUG
        ModernNetworkLogger.shared.level = .debug
        #else
        ModernNetworkLogger.shared.level = .warn
        #endif
        ModernNetworkLogger.shared.startLogging()
    }

    private enum ExportError: LocalizedError {
        case inactiveMode, notConfigured, noLogs, compressionFailed

        var errorDescription: String? {
            switch self {
            case .inactiveMode: return "新日志体系未启用"
            case .notConfigured: return "日志尚未初始化"
            case .noLogs: return "没有可导出的日志"
            case .compressionFailed: return "日志压缩失败"
            }
        }
    }

    func exportLogs(completion: @escaping (Result<URL, Error>) -> Void) {
        guard LoggingConfiguration.mode == .modern else {
            DispatchQueue.main.async { completion(.failure(ExportError.inactiveMode)) }
            return
        }
        configurationLock.lock()
        let logger = fileLogger
        configurationLock.unlock()
        guard let logger else {
            DispatchQueue.main.async { completion(.failure(ExportError.notConfigured)) }
            return
        }
        exportQueue.async {
            // 等待 DDLog 及文件接收器的待写消息落盘，避免主线程等待磁盘。
            DDLog.flushLog()
            logger.rollLogFile {
                self.exportQueue.async {
                    let result = Result { try self.makeArchive(logger: logger) }
                    DispatchQueue.main.async { completion(result) }
                }
            }
        }
    }

    private func makeArchive(logger: DDFileLogger) throws -> URL {
        let manager = FileManager.default
        let directory = manager.temporaryDirectory.appendingPathComponent("ModernLogExports", isDirectory: true)
        try manager.createDirectory(at: directory, withIntermediateDirectories: true)
        let identifier = UUID().uuidString
        let snapshot = directory.appendingPathComponent(identifier, isDirectory: true)
        let archive = directory.appendingPathComponent("ModernLogs-\(identifier).zip")
        try manager.createDirectory(at: snapshot, withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: snapshot) }

        // 在文件队列复制快照，避免复制期间写入活动文件；压缩在导出队列执行。
        let paths: [String] = try logger.loggerQueue.sync {
            try logger.logFileManager.sortedLogFilePaths.compactMap { path in
                let destination = snapshot.appendingPathComponent(URL(fileURLWithPath: path).lastPathComponent)
                do {
                    try manager.copyItem(atPath: path, toPath: destination.path)
                    return destination.path
                } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
                    // 框架可能正在清理刚超过配额的旧归档，不影响其余快照。
                    return nil
                }
            }
        }
        guard !paths.isEmpty else { throw ExportError.noLogs }
        guard createArchive(archive.path, paths) else {
            try? manager.removeItem(at: archive)
            throw ExportError.compressionFailed
        }
        return archive
    }
}
