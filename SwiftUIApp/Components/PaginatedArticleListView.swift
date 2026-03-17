//
//  PaginatedArticleListView.swift
//  RxStudy - SwiftUIApp
//
//  分页文章列表组件
//  通用组件，支持下拉刷新、加载更多、空状态、错误状态
//

import SwiftUI

// MARK: - 分页文章列表组件

struct PaginatedArticleListView<Item: Identifiable>: View {
    let items: [Item]
    let isLoading: Bool
    let isLoadingMore: Bool
    let hasMoreData: Bool
    let errorMessage: String?
    let onRefresh: () async -> Void
    let onLoadMore: () async -> Void
    let content: (Item) -> AnyView

    // 初始化
    init(
        items: [Item],
        isLoading: Bool,
        isLoadingMore: Bool = false,
        hasMoreData: Bool = true,
        errorMessage: String? = nil,
        onRefresh: @escaping () async -> Void,
        onLoadMore: @escaping () async -> Void,
        @ViewBuilder content: @escaping (Item) -> AnyView
    ) {
        self.items = items
        self.isLoading = isLoading
        self.isLoadingMore = isLoadingMore
        self.hasMoreData = hasMoreData
        self.errorMessage = errorMessage
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
        self.content = content
    }

    var body: some View {
        ZStack {
            if !items.isEmpty {
                articleListView
            } else if isLoading {
                LoadingView()
            } else if let error = errorMessage {
                ErrorStateView(message: error) {
                    Task { await onRefresh() }
                }
            } else {
                EmptyStateView(
                    icon: "tray",
                    message: "暂无内容"
                )
            }
        }
    }

    // MARK: - 文章列表视图

    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    content(item)
                        .onAppear {
                            Task {
                                await onLoadMore()
                            }
                        }
                }

                if isLoadingMore {
                    LoadingMoreView()
                } else if !hasMoreData && !items.isEmpty {
                    NoMoreDataView()
                }
            }
        }
        .refreshable {
            await onRefresh()
        }
    }
}

// MARK: - 简化版本（基于 InfoModel）

struct InfoArticleListView: View {
    let articles: [InfoModel]
    let isLoading: Bool
    let isLoadingMore: Bool
    let hasMoreData: Bool
    let errorMessage: String?
    let onRefresh: () async -> Void
    let onLoadMore: (InfoModel) async -> Void
    let onArticleTap: (InfoModel) -> Void

    var body: some View {
        PaginatedArticleListView(
            items: articles,
            isLoading: isLoading,
            isLoadingMore: isLoadingMore,
            hasMoreData: hasMoreData,
            errorMessage: errorMessage,
            onRefresh: onRefresh,
            onLoadMore: { await onLoadMore(articles.last!) },
            content: { article in
                AnyView(
                    NavigationLink(destination: WebUIController(article: article)) {
                        ArticleCellView(article: article)
                    }
                    .buttonStyle(.plain)
                )
            }
        )
    }
}

// MARK: - 加载更多视图

struct LoadingMoreView: View {
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("加载中...")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}

// MARK: - 没有更多数据视图

struct NoMoreDataView: View {
    var body: some View {
        Text("没有更多了")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
}
