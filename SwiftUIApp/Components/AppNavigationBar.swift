//
//  AppNavigationBar.swift
//  RxStudy - SwiftUIApp
//
//  自定义应用导航栏
//  可自定义左、中、右三个区域的内容
//

import SwiftUI

// MARK: - 应用导航栏

struct AppNavigationBar: View {

    // MARK: - 属性

    /// 左侧视图
    let leading: AnyView?

    /// 中间视图（通常是标题）
    let center: AnyView?

    /// 右侧视图
    let trailing: AnyView?

    /// 背景颜色
    var backgroundColor: Color

    /// 前景颜色
    var foregroundColor: Color

    /// 是否显示底部分隔线
    var showDivider: Bool

    /// 导航栏高度
    var height: CGFloat

    // MARK: - 初始化

    init(
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder center: () -> some View = { EmptyView() },
        @ViewBuilder trailing: () -> some View = { EmptyView() },
        backgroundColor: Color = .systemBackground,
        foregroundColor: Color = .primary,
        showDivider: Bool = true,
        height: CGFloat = 44
    ) {
        self.leading = AnyView(leading())
        self.center = AnyView(center())
        self.trailing = AnyView(trailing())
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.showDivider = showDivider
        self.height = height
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // 导航栏内容
            ZStack {
                // 中间区域（居中）
                if let center = center {
                    center
                        .frame(maxWidth: .infinity)
                }

                // 两侧区域（左右对齐）
                HStack {
                    // 左侧区域
                    if let leading = leading {
                        leading
                    } else {
                        Spacer()
                            .frame(minWidth: 56)
                    }

                    Spacer()

                    // 右侧区域
                    if let trailing = trailing {
                        trailing
                    } else {
                        Spacer()
                            .frame(minWidth: 56)
                    }
                }
            }
            .frame(height: height)
            .frame(minHeight: height)
            .padding(.horizontal, 16)
            .background(backgroundColor)

            // 底部分隔线
            if showDivider {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
            }
        }
    }
}

// MARK: - 便利扩展

extension AppNavigationBar {

    /// 创建标准文本标题导航栏
    static func title(
        _ title: String,
        titleColor: Color = .primary,
        backgroundColor: Color = .systemBackground,
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) -> AppNavigationBar {
        AppNavigationBar(
            leading: leading,
            center: {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(titleColor)
            },
            trailing: trailing,
            backgroundColor: backgroundColor,
            foregroundColor: titleColor
        )
    }
}

// MARK: - 视图扩展

extension View {

    /// 在视图顶部添加自定义导航栏
    func appNavigationBar(
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder center: () -> some View = { EmptyView() },
        @ViewBuilder trailing: () -> some View = { EmptyView() },
        backgroundColor: Color = .systemBackground,
        foregroundColor: Color = .primary,
        showDivider: Bool = true
    ) -> some View {
        VStack(spacing: 0) {
            AppNavigationBar(
                leading: leading,
                center: center,
                trailing: trailing,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                showDivider: showDivider
            )

            self
        }
        .background(Color.systemGroupedBackground)
    }

    /// 在视图顶部添加标准标题导航栏
    func navigationBar(
        _ title: String,
        titleColor: Color = .primary,
        backgroundColor: Color = .systemBackground,
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) -> some View {
        VStack(spacing: 0) {
            AppNavigationBar.title(
                title,
                titleColor: titleColor,
                backgroundColor: backgroundColor,
                leading: leading,
                trailing: trailing
            )

            self
        }
        .background(Color.systemGroupedBackground)
    }
}

// MARK: - 预览

#Preview("标准标题") {
    VStack {
        AppNavigationBar.title("首页")

        Spacer()

        Text("内容区域")
            .font(.title)
            .foregroundColor(.secondary)

        Spacer()
    }
    .background(Color.systemGroupedBackground)
}

#Preview("自定义左右按钮") {
    VStack {
        AppNavigationBar(
            leading: {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 17))
                }
            },
            center: {
                Text("详情页")
                    .font(.system(size: 17, weight: .semibold))
            },
            trailing: {
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                    }
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                    }
                }
                .foregroundColor(.blue)
                .font(.system(size: 18))
            }
        )

        Spacer()

        Text("详情页内容")
            .font(.title)
            .foregroundColor(.secondary)

        Spacer()
    }
    .background(Color.systemGroupedBackground)
}

#Preview("复杂中间内容") {
    VStack {
        AppNavigationBar(
            leading: {
                Image(systemName: "person.circle")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
            },
            center: {
                VStack(spacing: 2) {
                    Text("主标题")
                        .font(.system(size: 17, weight: .semibold))
                    Text("副标题")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            },
            trailing: {
                Button(action: {}) {
                    Image(systemName: "bell")
                }
                .foregroundColor(.blue)
                .font(.system(size: 18))
            }
        )

        Spacer()

        Text("带副标题的导航栏")
            .font(.title)
            .foregroundColor(.secondary)

        Spacer()
    }
    .background(Color.systemGroupedBackground)
}

#Preview("透明导航栏") {
    ZStack {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack {
            AppNavigationBar(
                leading: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                },
                center: {
                    Text("透明导航栏")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                },
                trailing: {
                    Image(systemName: "gear")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                },
                backgroundColor: .clear,
                foregroundColor: .white,
                showDivider: false
            )

            Spacer()

            Text("内容区域")
                .font(.title)
                .foregroundColor(.white)

            Spacer()
        }
    }
}
