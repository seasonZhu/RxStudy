//
//  HomeView.swift
//  RxStudy - SwiftUIApp
//
//  首页视图
//  使用 @Observable + @State
//

import SwiftUI

// MARK: - 首页视图

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            contentView

            // 加载指示器
            if viewModel.isLoading && viewModel.articles.isEmpty {
                LoadingView()
            }
        }
        .navigationBar("首页") {} trailing: {
            NavigationLink(destination: HotKeyView()) {
                Image(systemName: "magnifyingglass")
            }
        }
        .task {
            // 首次加载数据
            if viewModel.articles.isEmpty {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.articles.isEmpty {
            articleListView
        } else if !viewModel.isLoading {
            emptyView
        } else {
            EmptyView()
        }
    }

    // MARK: - 文章列表

    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Banner 轮播
                if !viewModel.banners.isEmpty {
                    BannerCarouselView(banners: viewModel.banners)
                }

                // 文章列表
                ForEach(viewModel.articles) { article in
                    NavigationLink(destination: WebUIController(article: article)) {
                        ArticleCellView(article: article)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        // 预加载：接近底部时加载更多
                        Task {
                            await viewModel.loadMoreIfNeeded(article)
                        }
                    }
                }

                // 加载更多指示器
                if viewModel.isLoadingMore {
                    LoadingMoreView()
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - 空状态视图

    private var emptyView: some View {
        EmptyStateView(
            icon: "tray",
            message: "暂无内容",
            showRetry: viewModel.errorMessage != nil
        ) {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

// MARK: - 预览

#Preview {
    HomeView()
}
