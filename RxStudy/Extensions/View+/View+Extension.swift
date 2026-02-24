//
//  View+Extension.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

// MARK: - 通用修饰符

public extension View {

    /// 设置指定角的圆角
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 需要圆角的角
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// 添加自定义阴影
    /// - Parameters:
    ///   - color: 阴影颜色
    ///   - radius: 模糊半径
    ///   - x: x轴偏移
    ///   - y: y轴偏移
    func customShadow(color: Color = .black, radius: CGFloat = 5, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color.opacity(0.2), radius: radius, x: x, y: y)
    }

    /// 设置尺寸（CGSize）
    /// - Parameters:
    ///   - size: 尺寸
    ///   - alignment: 对齐方式
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }

    /// 添加内边距（EdgeInsets）
    /// - Parameter insets: 内边距
    func edgePadding(_ insets: EdgeInsets) -> some View {
        self.padding(insets)
    }

    /// 隐藏视图
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }

    /// 条件应用修饰符
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 条件应用修饰符，带else分支
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}

// MARK: - 触摸反馈

public extension View {

    /// 添加点击效果
    /// - Parameter action: 点击回调
    func tapEffect(onClick action: @escaping () -> Void) -> some View {
        self.onTapGesture(perform: action)
    }

    /// 添加长按效果
    /// - Parameters:
    ///   - minimumDuration: 最小长按时长
    ///   - action: 长按回调
    func longPressEffect(minimumDuration: Double = 0.5, action: @escaping () -> Void) -> some View {
        self.onLongPressGesture(minimumDuration: minimumDuration, perform: action)
    }
}

// MARK: - 键盘处理

public extension View {

    /// 点击空白区域收起键盘
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - 设备方向

public extension View {

    /// 仅在横屏显示
    @ViewBuilder
    func landscapeOnly() -> some View {
        if UIDevice.current.orientation.isLandscape {
            self
        } else {
            EmptyView()
        }
    }

    /// 仅在竖屏显示
    @ViewBuilder
    func portraitOnly() -> some View {
        if UIDevice.current.orientation.isPortrait {
            self
        } else {
            EmptyView()
        }
    }
}

// MARK: - 自定义圆角形状

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 预览

#if DEBUG
struct ViewExtension_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 圆角
            VStack(spacing: 20) {
                Text("圆角效果").font(.headline)
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                    .cornerRadius(radius: 10, corners: .allCorners)

                Rectangle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                    .cornerRadius(radius: 10, corners: [.topLeft, .topRight])
            }
            .padding()
            .previewDisplayName("圆角")

            // 阴影
            VStack(spacing: 20) {
                Text("阴影效果").font(.headline)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .cornerRadius(radius: 10, corners: .allCorners)
                    .customShadow()

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .cornerRadius(radius: 10, corners: .allCorners)
                    .customShadow(color: .red, radius: 10, x: 5, y: 5)
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .previewDisplayName("阴影")

            // 条件显示
            VStack(spacing: 20) {
                Text("条件显示").font(.headline)
                Text("可见").if(true) { view in
                    view.foregroundColor(.green)
                }
                Text("隐藏").hidden(true)
            }
            .padding()
            .previewDisplayName("条件")
        }
    }
}
#endif
