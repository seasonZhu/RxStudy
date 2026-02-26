//
//  AppNavigationBarExamples.swift
//  RxStudy - SwiftUIApp
//
//  自定义导航栏使用示例
//

import SwiftUI

// MARK: - 示例 1: 简单标题导航栏

struct Example1_SimpleTitle: View {
    var body: some View {
        VStack {
            Text("首页内容")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .navigationBar("首页")
    }
}

// MARK: - 示例 2: 带左侧头像按钮

struct Example2_WithAvatar: View {
    var body: some View {
        VStack {
            Text("首页内容")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .navigationBar("首页", trailing:  {
          Button(action: {}) {
            Image(systemName: "person.circle.fill")
              .font(.system(size: 24))
          }
          .foregroundColor(.blue)
        })
    }
}

// MARK: - 示例 3: 带右侧搜索和通知按钮

struct Example3_WithRightButtons: View {
    var body: some View {
        VStack {
            Text("首页内容")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .navigationBar("首页") {} trailing: {
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
                Button(action: {}) {
                    Image(systemName: "bell")
                }
            }
            .foregroundColor(.blue)
            .font(.system(size: 18))
        }
    }
}

// MARK: - 示例 4: 完全自定义（左、中、右）

struct Example4_FullyCustom: View {
    var body: some View {
        VStack {
            Text("首页内容")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .appNavigationBar(
            leading: {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                    .font(.system(size: 17))
                }
                .foregroundColor(.blue)
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
                    Image(systemName: "ellipsis")
                }
                .foregroundColor(.blue)
                .font(.system(size: 18))
            }
        )
    }
}

// MARK: - 示例 5: 透明导航栏

struct Example5_Transparent: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Text("内容区域")
                    .font(.title)
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .appNavigationBar(
            leading: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            },
            center: {
                Text("透明导航栏")
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold))
            },
            trailing: {
                Image(systemName: "gear")
                    .foregroundColor(.white)
            },
            backgroundColor: .clear,
            foregroundColor: .white,
            showDivider: false
        )
    }
}

// MARK: - 示例 6: 直接使用组件

struct Example6_DirectComponent: View {
    var body: some View {
        VStack {
            // 直接使用导航栏组件
            AppNavigationBar.title("首页")

            ScrollView {
                VStack(spacing: 20) {
                    Text("内容区域")
                        .font(.title)
                    ForEach(0..<20) { i in
                        Text("列表项 \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.systemBackground)
                    }
                }
            }
        }
        .background(Color.systemGroupedBackground)
    }
}

// MARK: - 预览容器

struct AppNavigationBarExamples_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            Example1_SimpleTitle()
                .tabItem { Label("简单标题", systemImage: "1.circle") }

            Example2_WithAvatar()
                .tabItem { Label("带头像", systemImage: "2.circle") }

            Example3_WithRightButtons()
                .tabItem { Label("右侧按钮", systemImage: "3.circle") }

            Example4_FullyCustom()
                .tabItem { Label("完全自定义", systemImage: "4.circle") }

            Example5_Transparent()
                .tabItem { Label("透明导航栏", systemImage: "5.circle") }
        }
    }
}
