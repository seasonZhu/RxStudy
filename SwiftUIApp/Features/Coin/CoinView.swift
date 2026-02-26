//
//  CoinView.swift
//  RxStudy - SwiftUIApp
//
//  我的积分页面视图
//

import SwiftUI

// MARK: - 积分视图

struct CoinView: View {
    @State private var viewModel = CoinViewModel()
    @State private var showLogin = false

    var body: some View {
        contentView
            .navigationTitle("我的积分")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkLoginAndLoad()
            }
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.isLoggedIn {
            notLoginView
        } else if viewModel.userInfo != nil || !viewModel.coins.isEmpty {
            coinContentView
        } else if viewModel.isLoading {
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 积分内容视图

    private var coinContentView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // 积分信息卡片
                if let userInfo = viewModel.userInfo {
                    userInfoCard(userInfo)
                }

                // 积分记录列表
                if !viewModel.coins.isEmpty {
                    coinsListView
                }

                // 加载更多指示器
                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - 用户信息卡片

    private func userInfoCard(_ userInfo: CoinRankModel) -> some View {
        VStack(spacing: 16) {
            // 积分
            VStack(spacing: 8) {
                Text("\(userInfo.coinCount ?? 0)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue)

                Text("当前积分")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            // 排名和等级
            HStack(spacing: 32) {
                if let rank = userInfo.rank, let level = userInfo.level {
                    VStack(spacing: 4) {
                        Text("排名: \(rank)")
                            .font(.system(size: 16))
                        Text("等级: \(level)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                VStack(spacing: 4) {
                    Text("ID: \(userInfo.userId ?? 0)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.systemBackground)
    }

    // MARK: - 积分记录列表视图

    private var coinsListView: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.coins) { coin in
                MyCoinCellView(coin: coin)
                    .onAppear {
                        Task {
                            await viewModel.loadMoreIfNeeded(coin)
                        }
                    }
            }
        }
    }

    // MARK: - 辅助视图

    private var notLoginView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("未登录")
                .font(.system(size: 17))

            Button("立即登录") {
                showLogin = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingView: some View {
        ProgressView("加载中...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(viewModel.errorMessage ?? "加载失败")
                .font(.system(size: 14))
                .foregroundColor(.red)

            Button("重新加载") {
                Task {
                    await viewModel.loadData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - 私有方法

    private func checkLoginAndLoad() {
        guard viewModel.isLoggedIn else {
            return
        }
        Task {
            await viewModel.loadData()
        }
    }
}

// MARK: - 我的积分记录单元格（RxStudy 样式）

struct MyCoinCellView: View {
    let coin: MyHistoryCoin

    var body: some View {
        // 按照 RxStudy 的方式：desc?.replacingOccurrences(of: " , ", with: "\n\n")
        Text(coin.desc?.replacingOccurrences(of: " , ", with: "\n\n") ?? "")
            .font(.system(size: 16))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.systemBackground)
    }
}

// MARK: - 预览

#Preview {
    CoinView()
}
