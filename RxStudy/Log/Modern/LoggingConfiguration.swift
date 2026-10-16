/// 修改后重新编译并启动；一次启动只使用一种日志体系。
enum LoggingConfiguration {
    static let mode: LoggingMode = .legacy
}

enum LoggingMode {
    case legacy
    case modern
}
