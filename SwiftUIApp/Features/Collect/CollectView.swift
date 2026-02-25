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
    @State private var showLogin = false

    var body: some View {
        contentView
            .navigationTitle("我的收藏")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkLoginAndLoad()
            }
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.isLoggedIn {
            notLoginView
        } else if !viewModel.articles.isEmpty {
            articlesListView
        } else if viewModel.isLoading {
            loadingView
        } else {
            emptyOrErrorView
        }
    }

    // MARK: - 文章列表视图

    private var articlesListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.articles) { article in
                    CollectArticleCellView(article: article)
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

    private var notLoginView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("未登录")
                .font(.system(size: 17))

            Button("立即登录") {
                showLogin = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingView: some View {
        ProgressView("加载中...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyOrErrorView: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.errorMessage == nil ? "bookmark" : "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(viewModel.errorMessage ?? "暂无收藏")
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            if viewModel.errorMessage != nil {
                Button("重新加载") {
                    Task {
                        await viewModel.loadData()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 私有方法

    private func checkLoginAndLoad() {
        guard viewModel.isLoggedIn else {
            return
        }
        Task {
            await viewModel.loadData()
        }
    }
}

// MARK: - 收藏文章单元格

struct CollectArticleCellView: View {
    let article: CollectArticleModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题
            Text(article.title ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)

            // 描述
            if let desc = article.desc, !desc.isEmpty {
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // 底部信息
            HStack(spacing: 8) {
                if let author = article.author {
                    Text(author)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                if let chapterName = article.chapterName {
                    Text(chapterName)
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }

                Text(article.niceDate ?? article.niceShareDate ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

// MARK: - 预览

#Preview {
    CollectView()
}
