//
//  PublicNumberView.swift
//  RxStudy - SwiftUIApp
//
//  公众号页面视图
//  上下结构：顶部分类标签 + 底部横向滑动文章列表（双向绑定）
//

import SwiftUI

// MARK: - 公众号视图

struct PublicNumberView: View {
    @State private var viewModel = PublicNumberViewModel()
    @State private var currentPage: Int = 0

    var body: some View {
        contentView
            .navigationBar("公众号")
            .onAppear {
                if !viewModel.publicNumbers.isEmpty {
                    viewModel.selectPublicNumber(viewModel.publicNumbers[0])
                }
            }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.publicNumbers.isEmpty {
            publicNumberContentView
        } else if viewModel.isLoading {
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 公众号内容视图（上下结构 + 横向滑动）

    private var publicNumberContentView: some View {
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
                    ForEach(Array(viewModel.publicNumbers.enumerated()), id: \.element.id) { index, number in
                        CategoryTag(
                            name: number.name?.replaceHtmlElement ?? "",
                            isSelected: currentPage == index
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentPage = index
                                viewModel.selectPublicNumber(number)
                            }
                            // 自动滚动到中间
                            withAnimation {
                                proxy.scrollTo(number.id, anchor: .center)
                            }
                        }
                        .id(number.id)
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 44)
            .background(Color.systemBackground)
            .onAppear {
                // 初始滚动到选中标签
                if let firstNumber = viewModel.publicNumbers.first, let numberId = firstNumber.id {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(numberId, anchor: .center)
                        }
                    }
                }
            }
            // 监听页面变化，同步滚动 tag
            .onChange(of: currentPage) { _, newValue in
                if newValue < viewModel.publicNumbers.count {
                    let number = viewModel.publicNumbers[newValue]
                    if let numberId = number.id {
                        withAnimation {
                            proxy.scrollTo(numberId, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 横向滑动的文章列表

    private var articleList: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(viewModel.publicNumbers.enumerated()), id: \.element.id) { index, number in
                PublicNumberArticleListView(
                    viewModel: viewModel,
                    accountId: number.id ?? 0,
                    accountName: number.name ?? "",
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
                    await viewModel.loadPublicNumbers()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - 单个公众号的文章列表

struct PublicNumberArticleListView: View {
    let viewModel: PublicNumberViewModel
    let accountId: Int
    let accountName: String
    let isActive: Bool

    // 使用单独的加载状态
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var articles: [InfoModel] = []
    @State private var hasMoreData = true
    @State private var currentPage = 0
    @State private var errorMessage: String?
    @State private var isInitialized = false

    private let apiService = PublicNumberAPIService.shared

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
            if !isInitialized && accountId > 0 {
                isInitialized = true
                Task {
                    await loadArticleList(isRefresh: true)
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            // 当页面重新激活时，如果没数据则重新加载
            if newValue && articles.isEmpty && !isLoading && accountId > 0 {
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
            let pageResult = try await apiService.fetchArticleList(accountId: accountId, page: currentPage)

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

            Text("暂无文章")
                .font(.system(size: 17))
        }
    }
}

// MARK: - 预览

#Preview {
    NavigationView {
        PublicNumberView()
    }
}
