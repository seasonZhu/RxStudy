//
//  View+LoginGuard.swift
//  RxStudy - SwiftUIApp
//
//  登录拦截扩展
//  用于需要登录才能访问的功能入口
//

import SwiftUI

// MARK: - 登录拦截辅助类型

/// 登录守卫结果
enum LoginGuardResult {
    /// 已登录，执行导航
    case navigate
    /// 未登录，弹出登录页
    case requireLogin
}

// MARK: - View 登录拦截扩展

extension View {

    /// 为需要登录的功能添加登录拦截
    /// - Parameters:
    ///   - isLoggedIn: 是否已登录
    ///   - showLogin: 登录页面显示状态绑定
    ///   - destination: 导航目标视图
    /// - Returns: 如果已登录则显示导航链接，否则显示触发登录的按钮
    func loginGuard<Destination: View>(
        isLoggedIn: Bool,
        showLogin: Binding<Bool>,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        Group {
            if isLoggedIn {
                NavigationLink(destination: destination()) {
                    self
                }
            } else {
                Button {
                    showLogin.wrappedValue = true
                } label: {
                    self
                }
            }
        }
    }
}

// MARK: - 便捷的登录行组件

/// 带登录拦截的功能行
struct LoginGuardedRow<Content: View, Destination: View>: View {
    let isLoggedIn: Bool
    let showLogin: Binding<Bool>
    let icon: String
    let title: String
    let color: Color
    let destination: () -> Destination
    let content: () -> Content

    var body: some View {
        Group {
            if isLoggedIn {
                NavigationLink(destination: destination()) {
                    content()
                }
            } else {
                Button {
                    showLogin.wrappedValue = true
                } label: {
                    content()
                }
            }
        }
    }
}

// MARK: - 使用示例

/*

 // 在 MineView 中使用示例：

 LoginGuardedRow(
     isLoggedIn: viewModel.isLoggedIn,
     showLogin: $showLogin,
     icon: "star.fill",
     title: "我的积分",
     color: .yellow
 ) {
     // 行内容
     FunctionRowContent(icon: "star.fill", title: "我的积分", color: .yellow)
 } destination: {
     // 导航目标
     CoinView()
 }

 */
