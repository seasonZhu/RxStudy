//
//  SearchResultView.swift
//  RxStudy - SwiftUIApp
//
//  搜索结果页面
//

import SwiftUI

// MARK: - 搜索结果视图

struct SearchResultView: View {
    let keyword: String
    @State private var viewModel: SearchResultViewModel

    init(keyword: String) {
        self.keyword = keyword
        self._viewModel = State(initialValue: SearchResultViewModel(keyword: keyword))
    }

    var body: some View {
        Group {
            if !viewModel.articles.isEmpty {
                articleListView
            } else if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else {
                // 搜索结果为空的视图
                emptyView
            }
        }
        .navigationTitle(keyword)
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
        .onAppear {
            print("📱 SearchResultView onAppear，关键词: \(keyword)")
            print("📊 当前文章数: \(viewModel.articles.count)，是否加载中: \(viewModel.isLoading)")
            if viewModel.articles.isEmpty && !viewModel.isLoading {
                print("🔄 文章列表为空且未在加载，开始刷新...")
                viewModel.refresh()
            }
        }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.articles.isEmpty {
            articleListView
        } else if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(error)
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
                        // 预加载：接近底部时加载更多
                        _ = viewModel.loadMoreIfNeeded(article: article)
                    }
                }

                // 加载更多指示器
                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }

                // 没有更多数据提示
                if viewModel.hasNoMoreData && !viewModel.articles.isEmpty {
                    Text("没有更多数据了")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .refreshable {
            await viewModel.refreshAsync()
        }
    }

    // MARK: - 辅助视图

    private var loadingView: some View {
        ProgressView("搜索中...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.red)

            Button("重新加载") {
                viewModel.refresh()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("未找到相关结果")
                .font(.system(size: 17))
                .foregroundColor(.secondary)

            Text("请尝试其他关键词")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ViewModel 异步扩展

extension SearchResultViewModel {
    /// 刷新数据（异步，用于 refreshable）
    func refreshAsync() async {
        refresh()
        // 等待加载完成
        // 简单实现：等待一小段时间
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - 预览

#Preview {
    NavigationView {
        SearchResultView(keyword: "Android")
    }
}
