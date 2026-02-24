//
//  Color+Extension.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

// MARK: - 深色模式颜色支持

public extension Color {

    /// 创建适配深色模式的颜色
    /// - Parameters:
    ///   - light: 明亮主题的颜色
    ///   - dark: 黑暗主题的颜色（可选）
    static func adaptive(light: Color, dark: Color? = nil) -> Color {
        return Color(UIColor(lightThemeColor: UIColor(light), darkThemeColor: dark.map { UIColor($0) }))
    }

    /// 从十六进制字符串创建颜色
    /// - Parameter hex: 十六进制字符串（支持 #RGB、#ARGB、#RRGGBB、#AARRGGBB 格式）
    /// - Parameter alpha: 透明度（0-1），如果hex中已包含alpha则忽略此参数
    static func hex(_ hex: String, alpha: CGFloat = 1.0) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return Color(.sRGB, red: 0, green: 0, blue: 0, opacity: alpha)
        }

        let red, green, blue, alphaValue: CGFloat
        let length = hexSanitized.count

        if length == 6 {  // #RRGGBB
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
            alphaValue = alpha
        } else if length == 8 {  // #AARRGGBB
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alphaValue = CGFloat(rgb & 0x000000FF) / 255.0
        } else if length == 3 {  // #RGB
            red = CGFloat((rgb & 0xF00) >> 8) / 15.0
            green = CGFloat((rgb & 0x0F0) >> 4) / 15.0
            blue = CGFloat(rgb & 0x00F) / 15.0
            alphaValue = alpha
        } else if length == 4 {  // #ARGB
            red = CGFloat((rgb & 0xF000) >> 12) / 15.0
            green = CGFloat((rgb & 0x0F00) >> 8) / 15.0
            blue = CGFloat((rgb & 0x00F0) >> 4) / 15.0
            alphaValue = CGFloat(rgb & 0x000F) / 15.0
        } else {
            return Color(.sRGB, red: 0, green: 0, blue: 0, opacity: alpha)
        }

        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alphaValue)
    }

    /// 随机颜色
    static var random: Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }

    /// 转换为UIColor
    var uiColor: UIColor {
        return UIColor(self)
    }
}

// MARK: - 预定义主题颜色

public extension Color {

    /// Play Android 标题颜色 - light为黑，dark为白
    static let playAndroidTitle = Color.adaptive(light: .black, dark: .white)

    /// Play Android 背景颜色 - light为白，dark为黑
    static let playAndroidBg = Color.adaptive(light: .white, dark: .black)

    /// 系统蓝色
    static let systemBlue = Color.blue

    /// 系统红色
    static let systemRed = Color.red

    /// 系统绿色
    static let systemGreen = Color.green

    /// 系统橙色
    static let systemOrange = Color.orange

    /// 系统黄色
    static let systemYellow = Color.yellow

    /// 系统粉色
    static let systemPink = Color.pink

    /// 系统紫色
    static let systemPurple = Color.purple

    /// 系统灰色
    static let systemGray = Color.gray

    /// 分隔线颜色
    static let separator = Color.adaptive(
        light: Color(white: 0.0, opacity: 0.12),
        dark: Color(white: 1.0, opacity: 0.12)
    )

    /// 次要文本颜色
    static let secondaryText = Color.secondary

    /// 三级文本颜色
    static let tertiaryText = Color.adaptive(
        light: Color(white: 0.0, opacity: 0.45),
        dark: Color(white: 1.0, opacity: 0.45)
    )
}

// MARK: - 预览

#if DEBUG
struct ColorSwiftUIExtension_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 基础颜色
            VStack(spacing: 10) {
                Text("基础颜色").font(.headline)
                HStack {
                    Rectangle().fill(Color.red).frame(width: 50, height: 50)
                    Rectangle().fill(Color.green).frame(width: 50, height: 50)
                    Rectangle().fill(Color.blue).frame(width: 50, height: 50)
                }
            }
            .padding()
            .previewDisplayName("基础颜色")

            // 主题颜色
            VStack(spacing: 10) {
                Text("主题颜色").font(.headline)
                HStack {
                    Rectangle().fill(Color.playAndroidTitle).frame(width: 50, height: 50)
                    Rectangle().fill(Color.playAndroidBg).frame(width: 50, height: 50)
                    Rectangle().fill(Color.separator).frame(width: 50, height: 50)
                }
            }
            .padding()
            .previewDisplayName("主题颜色")

            // 十六进制颜色
            VStack(spacing: 10) {
                Text("十六进制颜色").font(.headline)
                HStack {
                    Rectangle().fill(Color.hex("#FF5733")).frame(width: 50, height: 50)
                    Rectangle().fill(Color.hex("#33FF57")).frame(width: 50, height: 50)
                    Rectangle().fill(Color.hex("#3357FF")).frame(width: 50, height: 50)
                }
            }
            .padding()
            .previewDisplayName("十六进制颜色")

            // 随机颜色
            VStack(spacing: 10) {
                Text("随机颜色").font(.headline)
                HStack {
                    Rectangle().fill(Color.random).frame(width: 50, height: 50)
                    Rectangle().fill(Color.random).frame(width: 50, height: 50)
                    Rectangle().fill(Color.random).frame(width: 50, height: 50)
                }
            }
            .padding()
            .previewDisplayName("随机颜色")
        }
    }
}
#endif
