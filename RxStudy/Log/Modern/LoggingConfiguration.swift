/// 修改后重新编译并启动；一次启动只使用一种日志体系。
enum LoggingConfiguration {
    static let mode: LoggingMode = .modern

    /// 仅作用于 Modern 的系统、控制台和文件输出；修改后重新编译启动。
    static let redactionEnabled = false
}

enum LoggingMode {
    case legacy
    case modern
}
