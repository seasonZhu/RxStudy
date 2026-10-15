//
//  CategoryArticleListView.swift
//  RxStudy - SwiftUIStudy
//
//  分类文章列表视图
//  展示某个分类下的文章列表，支持下拉刷新和上拉加载更多
//

import SwiftUI

// MARK: - 分类文章列表视图

struct CategoryArticleListView<T: CategoryItem>: View {
    let viewModel: CategoryArticleListViewModel<T>
    let isActive: Bool

    var body: some View {
        ZStack {
            if !viewModel.articles.isEmpty {
                articleListView
            } else if viewModel.isLoading {
                LoadingView(message: "加载中...")
            } else if let error = viewModel.errorMessage {
                ErrorStateView(message: error) {
                    Task {
                        await viewModel.refresh()
                    }
                }
            } else {
                EmptyStateView(icon: "tray", message: "暂无文章")
            }
        }
        .onChange(of: isActive, initial: true) { _, active in
            // 邻页预加载不发请求；切回时复用该分类已加载的数据。
            if active {
                Task {
                    await viewModel.loadIfNeeded()
                }
            }
        }
    }

    // MARK: - 文章列表视图

    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.articles) { article in
                    NavigationLink(
                        destination: WebUIController(article: article),
                        label: {
                            ArticleCellView(article: article)
                        }
                    )
                    .buttonStyle(.plain)
                    .onAppear {
                        guard isActive else { return }
                        Task {
                            await viewModel.loadMoreIfNeeded(article)
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    LoadingMoreView()
                } else if !viewModel.hasMoreData && !viewModel.articles.isEmpty {
                    NoMoreDataView()
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}
