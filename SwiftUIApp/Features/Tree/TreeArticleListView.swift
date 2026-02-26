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
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 文章列表视图

    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.articles) { article in
                    ArticleCellView(article: article)
                        .onAppear {
                            Task {
                                await viewModel.loadMoreIfNeeded(article)
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

// MARK: - 预览

#Preview {
    TreeArticleListView(tagId: 1, tagName: "Android")
}
