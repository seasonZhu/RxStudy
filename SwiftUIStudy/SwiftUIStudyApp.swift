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
        configureNavigationBarAppearance()
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

    private func configureNavigationBarAppearance() {
        // 配置 NavigationBar 外观，防止透明问题
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        // 设置大标题和标准标题的属性
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]

        // 设置背景色
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .separator

        // 应用到所有状态
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        }

        // 设置导航栏标题颜色
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = .systemBlue

        // 强制所有导航栏使用 inline 模式（关键！）
        UINavigationBar.appearance().prefersLargeTitles = false
    }
}

// MARK: - TabBar 视图

struct TabBarView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("首页", systemImage: "house.fill")
            }
            .tag(0)

            // 项目（使用通用分类组件）
            NavigationView {
                CategoryPageView<ProjectTagModel>(categoryType: .project)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("项目", systemImage: "folder.fill")
            }
            .tag(1)

            // 公众号（使用通用分类组件）
            NavigationView {
                CategoryPageView<PublicNumberTagModel>(categoryType: .publicNumber)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("公众号", systemImage: "person.2.fill")
            }
            .tag(2)

            // 体系
            NavigationView {
                TreeView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("体系", systemImage: "square.grid.3x3.fill")
            }
            .tag(3)

            // 我的
            NavigationView {
                MineView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("我的", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(.blue)
        .tint(.blue)
    }
}

#Preview {
    TabBarView()
}
