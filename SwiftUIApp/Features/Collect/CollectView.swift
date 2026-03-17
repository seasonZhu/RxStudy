//
//  CollectView.swift
//  RxStudy - SwiftUIApp
//
//  我的收藏页面视图
//

import SwiftUI

// MARK: - 收藏视图

struct CollectView: View {
    @State private var viewModel = CollectViewModel()

    var body: some View {
        contentView
            .navigationTitle("我的收藏")
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
        if !viewModel.articles.isEmpty {
            articlesListView
        } else if viewModel.isLoading {
            LoadingView(message: "加载中...")
        } else {
            emptyOrErrorView
        }
    }

    // MARK: - 文章列表视图

    private var articlesListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.articles) { article in
                    NavigationLink(destination: WebUIController(article: article)) {
                        ArticleCellView(article: article)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        Task {
                            await viewModel.loadMoreIfNeeded(article)
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    LoadingMoreView()
                }
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
    }

    // MARK: - 辅助视图

    private var emptyOrErrorView: some View {
        Group {
            if let error = viewModel.errorMessage {
                ErrorStateView(message: error) {
                    Task {
                        await viewModel.loadData()
                    }
                }
            } else {
                EmptyStateView(
                    icon: "bookmark",
                    message: "暂无收藏"
                )
            }
        }
    }
}

// MARK: - 预览

#Preview {
    CollectView()
}
