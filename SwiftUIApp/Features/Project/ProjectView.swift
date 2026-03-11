//
//  ProjectView.swift
//  RxStudy - SwiftUIApp
//
//  项目页面视图
//  上下结构：顶部分类标签 + 底部横向滑动文章列表（双向绑定）
//

import SwiftUI

// MARK: - 项目视图

struct ProjectView: View {
    @State private var viewModel = ProjectViewModel()
    @State private var currentPage: Int = 0

    var body: some View {
        contentView
            .navigationBar("项目")
            .onAppear {
                if !viewModel.tags.isEmpty {
                    viewModel.selectTag(viewModel.tags[0])
                }
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.tags.isEmpty {
            projectContentView
        } else if viewModel.isLoading {
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 项目内容视图（上下结构 + 横向滑动）

    private var projectContentView: some View {
        VStack(spacing: 0) {
            // 顶部分类选择器
            categoryPicker

            // 横向滑动的文章列表
            articleList
        }
    }

    // MARK: - 分类选择器（与页面双向绑定）

    private var categoryPicker: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(viewModel.tags.enumerated()), id: \.element.id) { index, tag in
                        CategoryTag(
                            name: tag.name?.replaceHtmlElement ?? "",
                            isSelected: currentPage == index
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentPage = index
                                viewModel.selectTag(tag)
                            }
                            // 自动滚动到中间
                            withAnimation {
                                proxy.scrollTo(tag.id, anchor: .center)
                            }
                        }
                        .id(tag.id)
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 44)
            .background(Color.systemBackground)
            .onAppear {
                // 初始滚动到选中标签
                if let firstTag = viewModel.tags.first, let tagId = firstTag.id {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(tagId, anchor: .center)
                        }
                    }
                }
            }
            // 监听页面变化，同步滚动 tag
            .onChange(of: currentPage) { _, newValue in
                if newValue < viewModel.tags.count {
                    let tag = viewModel.tags[newValue]
                    if let tagId = tag.id {
                        withAnimation {
                            proxy.scrollTo(tagId, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 横向滑动的文章列表

    private var articleList: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(viewModel.tags.enumerated()), id: \.element.id) { index, tag in
                ArticleListView(
                    viewModel: viewModel,
                    tagId: tag.id ?? 0,
                    tagName: tag.name ?? "",
                    isActive: currentPage == index
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
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
                    await viewModel.loadTags()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - 分类标签

struct CategoryTag: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(name)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 单个标签的文章列表

struct ArticleListView: View {
    let viewModel: ProjectViewModel
    let tagId: Int
    let tagName: String
    let isActive: Bool

    // 使用单独的加载状态
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var articles: [InfoModel] = []
    @State private var hasMoreData = true
    @State private var currentPage = 0
    @State private var errorMessage: String?
    @State private var isInitialized = false

    private let apiService = ProjectAPIService.shared

    var body: some View {
        ZStack {
            if !articles.isEmpty {
                articleListView
            } else if isLoading {
                ProgressView("加载中...")
            } else if let error = errorMessage {
                errorView(error)
            } else {
                emptyView
            }
        }
        .onAppear {
            // 只在首次激活时加载数据
            if !isInitialized && tagId > 0 {
                isInitialized = true
                Task {
                    await loadArticleList(isRefresh: true)
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            // 当页面重新激活时，如果没数据则重新加载
            if newValue && articles.isEmpty && !isLoading && tagId > 0 {
                Task {
                    await loadArticleList(isRefresh: true)
                }
            }
        }
    }

    // MARK: - 文章列表视图

    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(articles) { article in
                    NavigationLink(
                        destination: WebUIController(article: article),
                        label: {
                            ArticleCellView(article: article)
                        }
                    )
                    .buttonStyle(.plain)
                    .onAppear {
                        Task {
                            await loadMoreIfNeeded(article)
                        }
                    }
                }

                if isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .refreshable {
            await loadArticleList(isRefresh: true)
        }
    }

    // MARK: - 加载数据

    private func loadArticleList(isRefresh: Bool) async {
        if isRefresh {
            isLoading = true
            currentPage = 0
            hasMoreData = true
            errorMessage = nil
        } else {
            isLoadingMore = true
        }

        do {
            currentPage = isRefresh ? 1 : currentPage + 1
            let pageResult = try await apiService.fetchProjectList(tagId: tagId, page: currentPage)

            await MainActor.run {
                if isRefresh {
                    articles = pageResult.datas ?? []
                } else {
                    if let newArticles = pageResult.datas {
                        articles.append(contentsOf: newArticles)
                    }
                }
                hasMoreData = pageResult.hasMore
                isLoading = false
                isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                if isRefresh {
                    currentPage = 0
                } else {
                    currentPage -= 1
                }
                isLoading = false
                isLoadingMore = false
            }
        }
    }

    // MARK: - 加载更多

    private func loadMoreIfNeeded(_ article: InfoModel) async {
        guard let index = articles.firstIndex(where: { $0.id == article.id }),
              index >= articles.count - 3,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadArticleList(isRefresh: false)
    }

    // MARK: - 辅助视图

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.red)

            Button("重新加载") {
                Task {
                    await loadArticleList(isRefresh: true)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("暂无项目")
                .font(.system(size: 17))
        }
    }
}

// MARK: - 预览

#Preview {
    NavigationView {
        ProjectView()
    }
}
