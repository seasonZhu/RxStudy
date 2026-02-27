//
//  View+Navigation.swift
//  RxStudy - SwiftUIApp
//
//  导航栏和 TabBar 显示控制扩展
//

import SwiftUI

// MARK: - 导航栏和 TabBar 显示控制

extension View {

    // MARK: - TabBar

    /// 隐藏 TabBar（用于二级页面）
    /// - Note: 使用 iOS 16+ 的 .toolbar(.hidden, for: .tabBar) API
    func hideTabBar() -> some View {
        self.toolbar(.hidden, for: .tabBar)
    }

    /// 显示 TabBar
    /// - Note: 使用 iOS 16+ 的 .toolbar(.visible, for: .tabBar) API
    func showTabBar() -> some View {
        self.toolbar(.visible, for: .tabBar)
    }

    // MARK: - NavigationBar

    /// 隐藏导航栏
    /// - Note: 使用 iOS 16+ 的 .toolbar(.hidden, for: .navigationBar) API
    func hideNavigationBar() -> some View {
        self.toolbar(.hidden, for: .navigationBar)
    }

    /// 显示导航栏
    /// - Note: 使用 iOS 16+ 的 .toolbar(.visible, for: .navigationBar) API
    func showNavigationBar() -> some View {
        self.toolbar(.visible, for: .navigationBar)
    }

    // MARK: - 组合

    /// 隐藏导航栏和 TabBar（用于全屏内容页面）
    func hideNavigationBarAndTabBar() -> some View {
        self.toolbar(.hidden, for: .navigationBar, .tabBar)
    }

    /// 显示导航栏和 TabBar
    func showNavigationBarAndTabBar() -> some View {
        self.toolbar(.visible, for: .navigationBar, .tabBar)
    }
}

// MARK: - 使用示例

/*

 // 隐藏 TabBar（二级页面）
 WebUIController()
     .hideTabBar()

 // 隐藏导航栏和 TabBar（全屏页面）
 FullScreenContentView()
     .hideNavigationBarAndTabBar()

 // 显示 TabBar（返回一级页面时）
 PrimaryView()
     .showTabBar()

 */
