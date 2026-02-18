//
//  Theme.swift
//  RxStudy
//
//  Created by dy on 2022/11/1.
//  Copyright © 2022 season. All rights reserved.
//

import RxTheme

/// 主题协议，定义应用的主题颜色规范
protocol Theme {
    /// 背景颜色
    var backgroundColor: UIColor { get }

    /// 文本颜色
    var textColor: UIColor { get }
}

/// 浅色主题配置
struct LightTheme: Theme {
    let backgroundColor = UIColor.white
    let textColor = UIColor.black
}

/// 深色主题配置
struct DarkTheme: Theme {
    let backgroundColor = UIColor.black
    let textColor = UIColor.white
}

/// 主题类型枚举
///
/// 使用 `RxTheme` 库实现主题切换功能
enum ThemeType {
    /// 浅色主题
    case light

    /// 深色主题
    case dark
}

extension ThemeType: ThemeProvider {
    /// 当前主题类型对应的主题对象
    var associatedObject: Theme {
        switch self {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        }
    }
}

/// 主题服务实例
///
/// 通过此服务可以切换当前应用的主题
///
/// # 示例
/// ```swift
/// // 切换到深色主题
/// themeService.switch(.dark)
///
/// // 切换到浅色主题
/// themeService.switch(.light)
/// ```
let themeService = ThemeType.service(initial: .light)

/// 切换当前主题
///
/// 在浅色主题和深色主题之间切换
func themeTriggered() {
    switch themeService.type {
    case .light:
        themeService.switch(.dark)
    case .dark:
        themeService.switch(.light)
    }
}

/// 触觉反馈类型
///
/// 使用 `UINotificationFeedbackGenerator` 提供用户反馈
enum Haptics {
    /// 成功反馈
    case success

    /// 警告反馈
    case warning

    /// 错误反馈
    case error
}

extension Haptics {
    /// 执行触觉反馈
    ///
    /// 根据当前枚举值触发相应的系统触觉反馈
    func feedback() {
        let generator = UINotificationFeedbackGenerator()
        switch self {
        case .success:
            generator.notificationOccurred(.success)
        case .warning:
            generator.notificationOccurred(.warning)
        case .error:
            generator.notificationOccurred(.error)
        }
    }
}
