//
//  ScreenAdapter.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

// MARK: - 屏幕适配工具

/// 屏幕适配工具类
public struct ScreenAdapter {

    /// 基准屏幕宽度（iPhone 14 Pro）
    public static let baseWidth: CGFloat = 393

    /// 基准屏幕高度（iPhone 14 Pro）
    public static let baseHeight: CGFloat = 852

    /// 当前屏幕宽度
    public static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    /// 当前屏幕高度
    public static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }

    /// 屏幕比例
    public static var scale: CGFloat {
        return UIScreen.main.scale
    }

    /// 状态栏高度
    public static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first as? UIWindowScene
            return window?.windows.first?.safeAreaInsets.top ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }

    /// 导航栏高度
    public static var navigationBarHeight: CGFloat {
        return 44
    }

    /// TabBar高度
    public static var tabBarHeight: CGFloat {
        return 49
    }

    /// 安全区域顶部
    public static var safeAreaTop: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            return window?.safeAreaInsets.top ?? 0
        }
        return 0
    }

    /// 安全区域底部
    public static var safeAreaBottom: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            return window?.safeAreaInsets.bottom ?? 0
        }
        return 0
    }

    /// 是否为横屏
    public static var isLandscape: Bool {
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }

    /// 是否为竖屏
    public static var isPortrait: Bool {
        return !isLandscape
    }

    /// 是否为iPhone
    public static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    /// 是否为iPad
    public static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    /// 是否是全面屏
    public static var isFullScreen: Bool {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            return (window?.safeAreaInsets.bottom ?? 0) > 0
        }
        return false
    }

    // MARK: - 宽度适配

    /// 根据宽度适配
    /// - Parameter value: 基准值
    /// - Parameter base: 基准屏幕宽度
    public static func adaptiveWidth(_ value: CGFloat, base: CGFloat = baseWidth) -> CGFloat {
        return value * (screenWidth / base)
    }

    // MARK: - 高度适配

    /// 根据高度适配
    /// - Parameter value: 基准值
    /// - Parameter base: 基准屏幕高度
    public static func adaptiveHeight(_ value: CGFloat, base: CGFloat = baseHeight) -> CGFloat {
        return value * (screenHeight / base)
    }

    // MARK: - 最小值适配

    /// 根据宽度和高度的最小值适配
    /// - Parameter value: 基准值
    public static func adaptiveMin(_ value: CGFloat) -> CGFloat {
        let minBase = min(baseWidth, baseHeight)
        let minScreen = min(screenWidth, screenHeight)
        return value * (minScreen / minBase)
    }

    // MARK: - 字体适配

    /// 适配字体大小
    /// - Parameter value: 基准值
    /// - Parameter base: 基准屏幕宽度
    public static func adaptiveFont(_ value: CGFloat, base: CGFloat = baseWidth) -> CGFloat {
        return value * (screenWidth / base)
    }

    /// 适配字体（带最大值限制）
    /// - Parameters:
    ///   - value: 基准值
    ///   - max: 最大值
    public static func adaptiveFont(_ value: CGFloat, max: CGFloat) -> CGFloat {
        let adaptive = adaptiveFont(value)
        return min(adaptive, max)
    }

    // MARK: - 圆角适配

    /// 适配圆角
    /// - Parameter value: 基准值
    public static func adaptiveCornerRadius(_ value: CGFloat) -> CGFloat {
        return adaptiveWidth(value)
    }

    // MARK: - 间距适配

    /// 适配间距
    /// - Parameter value: 基准值
    public static func adaptiveSpacing(_ value: CGFloat) -> CGFloat {
        return adaptiveWidth(value)
    }

    // MARK: - 尺寸适配

    /// 适配尺寸
    /// - Parameter size: 基准尺寸
    public static func adaptiveSize(_ size: CGSize) -> CGSize {
        return CGSize(
            width: adaptiveWidth(size.width),
            height: adaptiveHeight(size.height)
        )
    }

    /// 适配正方形尺寸
    /// - Parameter value: 基准值
    public static func adaptiveSquare(_ value: CGFloat) -> CGFloat {
        return adaptiveWidth(value)
    }
}

// MARK: - View 适配修饰符

public extension View {

    /// 适配宽度
    /// - Parameter value: 基准值
    func adaptiveWidth(_ value: CGFloat) -> some View {
        frame(width: ScreenAdapter.adaptiveWidth(value))
    }

    /// 适配高度
    /// - Parameter value: 基准值
    func adaptiveHeight(_ value: CGFloat) -> some View {
        frame(height: ScreenAdapter.adaptiveHeight(value))
    }

    /// 适配尺寸
    /// - Parameters:
    ///   - width: 基准宽度
    ///   - height: 基准高度
    func adaptiveSize(width: CGFloat, height: CGFloat) -> some View {
        frame(
            width: ScreenAdapter.adaptiveWidth(width),
            height: ScreenAdapter.adaptiveHeight(height)
        )
    }

    /// 适配正方形
    /// - Parameter value: 基准值
    func adaptiveSquare(_ value: CGFloat) -> some View {
        frame(
            width: ScreenAdapter.adaptiveSquare(value),
            height: ScreenAdapter.adaptiveSquare(value)
        )
    }

    /// 适配内边距
    /// - Parameter value: 基准值
    func adaptivePadding(_ value: CGFloat) -> some View {
        padding(ScreenAdapter.adaptiveSpacing(value))
    }

    /// 适配圆角
    /// - Parameter value: 基准值
    func adaptiveCornerRadius(_ value: CGFloat) -> some View {
        clipShape(RoundedCorner(radius: ScreenAdapter.adaptiveCornerRadius(value)))
    }

    /// 适配字体
    /// - Parameter value: 基准值
    func adaptiveFontSize(_ value: CGFloat) -> some View {
        font(.system(size: ScreenAdapter.adaptiveFont(value)))
    }
}

// MARK: - 预览

#if DEBUG
struct ScreenAdapter_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 屏幕信息
            VStack(alignment: .leading, spacing: 10) {
                Text("屏幕信息")
                    .font(.headline)

                Text("屏幕宽度: \(Int(ScreenAdapter.screenWidth))")
                Text("屏幕高度: \(Int(ScreenAdapter.screenHeight))")
                Text("状态栏高度: \(Int(ScreenAdapter.statusBarHeight))")
                Text("安全区域顶部: \(Int(ScreenAdapter.safeAreaTop))")
                Text("安全区域底部: \(Int(ScreenAdapter.safeAreaBottom))")
                Text("是否全面屏: \(ScreenAdapter.isFullScreen)")
                Text("是否横屏: \(ScreenAdapter.isLandscape)")
                Text("是否iPad: \(ScreenAdapter.isPad)")
            }
            .padding()
            .previewDisplayName("屏幕信息")

            // 适配示例
            VStack(spacing: 20) {
                Text("适配示例")
                    .font(.headline)

                // 适配宽度
                Rectangle()
                    .fill(Color.blue)
                    .adaptiveWidth(200)
                    .adaptiveHeight(100)

                // 适配圆角
                Rectangle()
                    .fill(Color.green)
                    .adaptiveWidth(150)
                    .adaptiveHeight(150)
                    .adaptiveCornerRadius(20)

                // 适配字体
                Text("适配字体大小")
                    .adaptiveFontSize(18)
            }
            .padding()
            .previewDisplayName("适配示例")
        }
    }
}
#endif
