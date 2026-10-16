import Foundation
import CocoaLumberjack

/// 新体系使用独立目录和默认文件命名，不识别旧体系文件。
final class ModernLogFileManager: DDLogFileManagerDefault {
    convenience init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.init(logsDirectory: documents.appendingPathComponent("ModernLogs", isDirectory: true).path)
    }
}
