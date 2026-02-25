//
//  SwiftUIApp.swift
//  RxStudy - SwiftUIApp
//
//  SwiftUI 迁移专用 Target 入口
//

import SwiftUI
import UIKit

@main
struct SwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView()
        }
    }

    init() {
        configureTabBarAppearance()
    }

    private func configureTabBarAppearance() {
        // 配置 TabBar 外观，防止透明问题
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // 设置选中和未选中状态的颜色
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray

        // 应用到所有状态
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - TabBar 视图

struct TabBarView: View {
    @State private var selectedTab = 0

    var body: some View {
        // NavigationView 在外层，保证 push 时 TabBar 自动隐藏
        NavigationView {
            TabView(selection: $selectedTab) {
                // 首页
                HomeView()
                    .tabItem {
                        Label("首页", systemImage: "house.fill")
                    }
                    .tag(0)

                // 项目
                ProjectView()
                    .tabItem {
                        Label("项目", systemImage: "folder.fill")
                    }
                    .tag(1)

                // 公众号
                PublicNumberView()
                    .tabItem {
                        Label("公众号", systemImage: "person.2.fill")
                    }
                    .tag(2)

                // 体系
                TreeView()
                    .tabItem {
                        Label("体系", systemImage: "square.grid.3x3.fill")
                    }
                    .tag(3)

                // 我的
                MineView()
                    .tabItem {
                        Label("我的", systemImage: "person.fill")
                    }
                    .tag(4)
            }
            .accentColor(.blue)
        }
        .navigationViewStyle(.stack)
        .tint(.blue)
    }
}

#Preview {
    TabBarView()
}
