//
//  ColorExtensions.swift
//  RxStudy - SwiftUIApp
//
//  SwiftUI Color 扩展
//  提供 UIKit 系统颜色的便捷访问
//

import SwiftUI

// MARK: - Color 扩展

extension Color {
    /// 系统背景色
    static let systemBackground = Color(UIColor.systemBackground)

    /// 系统分组背景色（用于列表等）
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)

    /// 分隔线颜色
    static let separator = Color(UIColor.separator)

    /// 次要分组背景色
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)

    /// 二级系统背景色
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)

    /// 三级系统背景色
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    // MARK: - Label 颜色

    /// 主要标签颜色
    static let label = Color(UIColor.label)

    /// 次要标签颜色
    static let secondaryLabel = Color(UIColor.secondaryLabel)

    /// 三级标签颜色
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)

    // MARK: - 填充颜色

    /// 系统填充色
    static let systemFill = Color(UIColor.systemFill)

    /// 二级系统填充色
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)

    /// 三级系统填充色
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)

    /// 四级系统填充色
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)

    // MARK: - 其他常用颜色

    /// 系统蓝色
    static let systemBlue = Color(UIColor.systemBlue)

    /// 系统绿色
    static let systemGreen = Color(UIColor.systemGreen)

    /// 系统橙色
    static let systemOrange = Color(UIColor.systemOrange)

    /// 系统粉色
    static let systemPink = Color(UIColor.systemPink)

    /// 系统紫色
    static let systemPurple = Color(UIColor.systemPurple)

    /// 系统红色
    static let systemRed = Color(UIColor.systemRed)

    /// 系统黄色
    static let systemYellow = Color(UIColor.systemYellow)

    /// 系统灰色
    static let systemGray = Color(UIColor.systemGray)

    /// 系统青色
    static let systemCyan = Color(UIColor.systemCyan)

    /// 系统靛蓝色
    static let systemIndigo = Color(UIColor.systemIndigo)
}
