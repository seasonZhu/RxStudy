//
//  SearchResultViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  搜索结果 ViewModel
//

import Foundation

@MainActor
@Observable
class SearchResultViewModel {
    // MARK: - 状态

    /// 文章列表
    private(set) var articles: [InfoModel] = []

    /// 是否正在加载
    private(set) var isLoading = false

    /// 是否正在加载更多
    private(set) var isLoadingMore = false

    /// 是否没有更多数据
    private(set) var hasNoMoreData = false

    /// 错误信息
    private(set) var errorMessage: String?

    // MARK: - 分页

    private var currentPage = 0
    @ObservationIgnored private var requestGeneration = 0

    // MARK: - 依赖

    private let keyword: String
    private let apiService: HomeAPIService

    // MARK: - 初始化

    init(keyword: String, apiService: HomeAPIService = .shared) {
        self.keyword = keyword
        self.apiService = apiService
        print("🔍 初始化 SearchResultViewModel，关键词: \(keyword)")
    }

    // MARK: - 方法

    /// 刷新数据，等待请求和状态更新完成后返回。
    func refresh() async {
        await loadArticles(isRefresh: true)
    }

    /// 加载更多
    func loadMore() async {
        guard !isLoading, !isLoadingMore, !hasNoMoreData else { return }
        await loadArticles(isRefresh: false)
    }

    /// 当滚动到倒数第 3 个时开始加载。
    func loadMoreIfNeeded(article: InfoModel) async {
        guard !isLoading, !isLoadingMore, !hasNoMoreData,
              let index = articles.firstIndex(where: { $0.id == article.id }),
              index >= articles.count - 3 else { return }
        await loadMore()
    }

    // MARK: - 私有方法

    private func loadArticles(isRefresh: Bool) async {
        guard !Task.isCancelled else { return }
        if isRefresh {
            guard !isLoading else { return }
            requestGeneration += 1
            isLoading = true
            isLoadingMore = false
        } else {
            guard !isLoading, !isLoadingMore, !hasNoMoreData else { return }
            isLoadingMore = true
        }
        let generation = requestGeneration
        let requestedPage = isRefresh ? 0 : currentPage + 1
        errorMessage = nil

        defer {
            if generation == requestGeneration {
                isLoading = false
                isLoadingMore = false
            }
        }

        do {
            let page = try await apiService.searchArticles(keyword: keyword, page: requestedPage)
            guard !Task.isCancelled, generation == requestGeneration else { return }
            if isRefresh {
                articles = page.datas ?? []
            } else {
                articles.append(contentsOf: page.datas ?? [])
            }
            currentPage = requestedPage
            hasNoMoreData = page.over ?? false
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), generation == requestGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }
}
