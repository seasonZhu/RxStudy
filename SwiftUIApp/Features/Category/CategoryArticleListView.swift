//
//  CategoryArticleListView.swift
//  RxStudy - SwiftUIApp
//
//  分类文章列表视图
//  展示某个分类下的文章列表，支持下拉刷新和上拉加载更多
//

import SwiftUI

// MARK: - 分类文章列表视图

struct CategoryArticleListView<T: CategoryItem>: View {
    let viewModel: CategoryPageViewModel<T>
    let categoryId: Int
    let categoryName: String
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
                        await viewModel.loadArticles(categoryId: categoryId, isRefresh: true)
                    }
                }
            } else {
                EmptyStateView(icon: "tray", message: "暂无文章")
            }
        }
        .onAppear {
            // 只在首次激活时加载数据
            if !viewModel.isInitialized && categoryId > 0 {
                viewModel.isInitialized = true
                Task {
                    await viewModel.loadArticles(categoryId: categoryId, isRefresh: true)
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            // 当页面重新激活时，如果没数据则重新加载
            if newValue && viewModel.articles.isEmpty && !viewModel.isLoading && categoryId > 0 {
                Task {
                    await viewModel.loadArticles(categoryId: categoryId, isRefresh: true)
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
                        Task {
                            await viewModel.loadMoreIfNeeded(article, categoryId: categoryId)
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
            await viewModel.loadArticles(categoryId: categoryId, isRefresh: true)
        }
    }
}
