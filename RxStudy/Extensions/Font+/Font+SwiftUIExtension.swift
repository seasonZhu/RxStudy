//
//  Font+Extension.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

// MARK: - 字体扩展

public extension Font {

    /// 系统字体（快捷方式）
    /// - Parameter size: 字号
    static func system(size: CGFloat) -> Font {
        return .system(size: size)
    }

    /// 系统字体（加粗）
    /// - Parameter size: 字号
    static func systemBold(size: CGFloat) -> Font {
        return .system(size: size, weight: .bold)
    }

    /// 系统字体（中等粗细）
    /// - Parameter size: 字号
    static func systemMedium(size: CGFloat) -> Font {
        return .system(size: size, weight: .medium)
    }

    /// 系统字体（细体）
    /// - Parameter size: 字号
    static func systemLight(size: CGFloat) -> Font {
        return .system(size: size, weight: .light)
    }

    /// 系统字体（半粗）
    /// - Parameter size: 字号
    static func systemSemibold(size: CGFloat) -> Font {
        return .system(size: size, weight: .semibold)
    }
}

// MARK: - 预定义字体大小

public extension Font {

    /// 大标题字体
    static let largeTitle = Font.system(size: 34, weight: .bold)

    /// 标题1字体
    static let title1 = Font.system(size: 28, weight: .bold)

    /// 标题2字体
    static let title2 = Font.system(size: 22, weight: .bold)

    /// 标题3字体
    static let title3 = Font.system(size: 20, weight: .semibold)

    /// 正文（粗体）字体
    static let headline = Font.system(size: 17, weight: .semibold)

    /// 正文（半粗）字体
    static let subheadline = Font.system(size: 17, weight: .medium)

    /// 正文（常规）字体
    static let body = Font.system(size: 17)

    /// 说明文字字体
    static let callout = Font.system(size: 16)

    /// 次要文字字体
    static let footnote = Font.system(size: 13)

    /// 说明文字（小）字体
    static let caption = Font.system(size: 12)

    /// 说明文字（极小）字体
    static let caption2 = Font.system(size: 11)
}

// MARK: - 自定义字体（如果需要）

public extension Font {

    /// 注册自定义字体
    /// - Parameter name: 字体名称
    /// - Parameter size: 字号
    static func custom(name: String, size: CGFloat) -> Font {
        return .custom(name, size: size)
    }
}

// MARK: - Text样式扩展

public extension Text {

    /// 设置字体
    /// - Parameter font: 字体
    func font(_ font: Font) -> Text {
        self.font(font)
    }

    /// 设置粗体
    func bold() -> Text {
        self.font(.system(size: 17, weight: .bold))
    }

    /// 设置中等粗细
    func medium() -> Text {
        self.font(.system(size: 17, weight: .medium))
    }

    /// 设置细体
    func light() -> Text {
        self.font(.system(size: 17, weight: .light))
    }

    /// 设置半粗
    func semibold() -> Text {
        self.font(.system(size: 17, weight: .semibold))
    }
}

// MARK: - 动态字体支持

public extension Font {

    /// 获取动态字体大小
    /// - Parameter baseSize: 基础字号
    /// - Parameter style: 文本样式
    static func dynamic(baseSize: CGFloat, style: Font.TextStyle = .body) -> Font {
        return .system(size: baseSize, design: .default)
    }
}

// MARK: - 字体工具类

public struct FontUtils {

    /// 根据屏幕宽度调整字号
    /// - Parameter baseSize: 基础字号
    /// - Parameter screenComparison: 对比屏幕宽度（默认iPhone 14 Pro 393）
    public static func adaptiveSize(
        baseSize: CGFloat,
        screenComparison: CGFloat = 393
    ) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return baseSize * (screenWidth / screenComparison)
    }

    /// 自适应字体
    /// - Parameters:
    ///   - baseSize: 基础字号
    ///   - weight: 字重
    ///   - screenComparison: 对比屏幕宽度
    public static func adaptiveFont(
        baseSize: CGFloat,
        weight: Font.Weight = .regular,
        screenComparison: CGFloat = 393
    ) -> Font {
        let size = adaptiveSize(baseSize: baseSize, screenComparison: screenComparison)
        return .system(size: size, weight: weight)
    }
}

// MARK: - 预览

#if DEBUG
struct FontSwiftUIExtension_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 预定义字体
            VStack(alignment: .leading, spacing: 10) {
                Text("大标题 (Large Title)")
                    .font(.largeTitle)

                Text("标题1 (Title 1)")
                    .font(.title1)

                Text("标题2 (Title 2)")
                    .font(.title2)

                Text("标题3 (Title 3)")
                    .font(.title3)

                Text("正文标题 (Headline)")
                    .font(.headline)

                Text("副标题 (Subheadline)")
                    .font(.subheadline)

                Text("正文 (Body)")
                    .font(.body)

                Text("说明文字 (Callout)")
                    .font(.callout)

                Text("次要文字 (Footnote)")
                    .font(.footnote)

                Text("说明文字 (Caption)")
                    .font(.caption)

                Text("说明文字2 (Caption 2)")
                    .font(.caption2)
            }
            .padding()
            .previewDisplayName("预定义字体")

            // 字重示例
            VStack(alignment: .leading, spacing: 10) {
                Text("Light")
                    .font(.systemLight(size: 20))

                Text("Regular")
                    .font(.system(size: 20))

                Text("Medium")
                    .font(.systemMedium(size: 20))

                Text("Semibold")
                    .font(.systemSemibold(size: 20))

                Text("Bold")
                    .font(.systemBold(size: 20))
            }
            .padding()
            .previewDisplayName("字重示例")

            // 自适应字体
            VStack(alignment: .leading, spacing: 10) {
                Text("自适应字体示例")
                    .font(FontUtils.adaptiveFont(baseSize: 18, weight: .bold))

                Text("当前屏幕宽度: \(Int(UIScreen.main.bounds.width))")
                    .font(.footnote)

                Text("自适应大小: \(FontUtils.adaptiveSize(baseSize: 16))")
                    .font(.caption)
            }
            .padding()
            .previewDisplayName("自适应字体")
        }
    }
}
#endif
