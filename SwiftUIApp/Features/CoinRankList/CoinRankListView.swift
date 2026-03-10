//
//  CoinRankListView.swift
//  RxStudy - SwiftUIApp
//
//  积分排名列表视图
//

import SwiftUI

// MARK: - 积分排名视图

struct CoinRankListView: View {
    @State private var viewModel = CoinRankListViewModel()

    var body: some View {
        contentView
            .navigationTitle("积分排名")
            .navigationBarTitleDisplayMode(.inline)
            .hideTabBar()
            .onAppear {
                Task {
                    await viewModel.loadData()
                }
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.ranks.isEmpty {
            ranksListView
        } else if viewModel.isLoading {
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 排名列表视图

    private var ranksListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.ranks) { rank in
                    CoinRankListCellView(rank: rank)
                        .onAppear {
                            Task {
                                await viewModel.loadMoreIfNeeded(rank)
                            }
                        }
                }

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

// MARK: - 积分排名单元格（RxStudy 样式）

struct CoinRankListCellView: View {
    let rank: CoinRankModel

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                if let username = rank.username {
                    Text(username)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.leading, 15)
                }

                Text(rank.myInfo)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.leading, 15)

                Divider()
                    .padding(.leading, 15)
            }
        }
        .padding(.vertical, 12)
        .background(Color.systemBackground)
    }
}

// MARK: - 预览

#Preview {
    CoinRankListView()
}
