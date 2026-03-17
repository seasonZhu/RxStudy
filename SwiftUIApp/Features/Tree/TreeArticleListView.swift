//
//  TreeArticleListView.swift
//  RxStudy - SwiftUIApp
//
//  体系文章列表视图
//

import SwiftUI

// MARK: - 体系文章列表视图

struct TreeArticleListView: View {
    let tagId: Int
    let tagName: String

    var body: some View {
        TreeArticleListContentView(tagId: tagId, tagName: tagName)
    }
}

// MARK: - 体系文章列表内容视图

private struct TreeArticleListContentView: View {
    @State private var viewModel: TreeArticleListViewModel

    init(tagId: Int, tagName: String) {
        _viewModel = State(initialValue: TreeArticleListViewModel(tagId: tagId, tagName: tagName))
    }

    var body: some View {
        contentView
            .navigationTitle(viewModel.tagName)
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
        if !viewModel.articles.isEmpty {
            articleListView
        } else if viewModel.isLoading {
            LoadingView(message: "加载中...")
        } else if let error = viewModel.errorMessage {
            ErrorStateView(message: error) {
                Task {
                    await viewModel.loadData()
                }
            }
        } else {
            EmptyStateView(icon: "tray", message: "暂无内容")
        }
    }

    // MARK: - 文章列表视图

    private var articleListView: some View {
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
}

// MARK: - 预览

#Preview {
    TreeArticleListView(tagId: 1, tagName: "Android")
}
