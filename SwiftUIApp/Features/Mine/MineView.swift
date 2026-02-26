//
//  MineView.swift
//  RxStudy - SwiftUIApp
//
//  我的页面视图
//

import SwiftUI
import Kingfisher

// MARK: - 我的页面视图

struct MineView: View {
    @State private var viewModel = MineViewModel()
    @State private var showLogin = false

    private let accountService = AccountAPIService.shared

    var body: some View {
        contentView
            .onAppear {
                viewModel.refreshUserInfo()
                // 尝试自动加载用户信息
                Task {
                    await accountService.autoLoadUserInfo()
                }
            }
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // 用户信息卡片
                userInfoCard

                // 功能列表
                functionList
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - 用户信息卡片

    private var userInfoCard: some View {
        VStack(spacing: 16) {
            // 头像
            KFImage(URL(string: viewModel.userInfo?.icon ?? ""))
                .placeholder {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                }
                .retry(maxCount: 2, interval: .seconds(1))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())

            // 用户名
            if let username = viewModel.userInfo?.nickname {
                Text(username)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
            } else if !viewModel.isLoggedIn {
                Text("未登录")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            } else {
                // 已登录但用户信息还在加载中
                Text("加载中...")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }

            // ID
            if let id = viewModel.userInfo?.id {
                Text("ID: \(id)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            // 登录/退出按钮
            if viewModel.isLoggedIn {
                Button("退出登录") {
                    Task {
                        await viewModel.logout()
                    }
                }
                .buttonStyle(.bordered)
            } else {
                Button("立即登录") {
                    showLogin = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.systemBackground))
    }

    // MARK: - 功能列表

    private var functionList: some View {
        VStack(spacing: 12) {
            // 积分
            NavigationLink(destination: CoinView()) {
                FunctionRow(icon: "star.fill", title: "我的积分", color: .yellow) {
                    // 不需要 action，NavigationLink 处理导航
                }
            }

            // 积分排名
            NavigationLink(destination: CoinRankListView()) {
                FunctionRow(icon: "list.number", title: "积分排名", color: .orange) {
                    // 不需要 action，NavigationLink 处理导航
                }
            }

            // 收藏
            NavigationLink(destination: CollectView()) {
                FunctionRow(icon: "bookmark.fill", title: "我的收藏", color: .blue) {
                    // 不需要 action，NavigationLink 处理导航
                }
            }
        }
        .padding(.top, 12)
    }
}
// MARK: - 功能行

struct FunctionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)

            // 标题
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)

            Spacer()

            // 箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

// MARK: - 预览

#Preview {
    MineView()
}
