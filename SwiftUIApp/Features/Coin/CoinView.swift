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

    var body: some View {
        contentView
            .navigationTitle("我的积分")
            .navigationBarTitleDisplayMode(.inline)
            .hideTabBar()
            .onAppear {
                // 页面出现时加载数据（已在入口处验证登录）
                Task {
                    await viewModel.loadData()
                }
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if viewModel.userInfo != nil || !viewModel.coins.isEmpty {
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
            HStack(spacing: 32) {
              Text("积分: \(userInfo.coinCount ?? 0)")
                  .font(.system(size: 16))
              Text("排名: \(userInfo.rank ?? "0")")
                  .font(.system(size: 16))
              Text("等级: \(userInfo.level ?? 0)")
                  .font(.system(size: 16))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.systemGray)
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
