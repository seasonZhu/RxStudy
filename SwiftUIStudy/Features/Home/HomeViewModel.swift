//
//  HomeViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  首页 ViewModel
//  使用 @Observable + async/await
//

import Foundation

/// SwiftUI 最新数据模型完整解析：@Observable、@State、@Bindable（iOS17+ 全新范式）
/// https://juejin.cn/post/7578177007576268854

// MARK: - 首页 ViewModel

@MainActor
@Observable
final class HomeViewModel {
    // MARK: - 状态

    /// 文章列表
    private(set) var articles: [InfoModel] = []

    /// Banner 列表
    private(set) var banners: [Banner] = []

    /// 加载状态
    private(set) var isLoading = false

    /// 加载更多状态
    private(set) var isLoadingMore = false

    /// 错误信息
    private(set) var errorMessage: String?

    /// 是否还有更多数据
    private(set) var hasMoreData = true

    // MARK: - 私有属性

    private let apiService = HomeAPIService.shared
    private var currentPage = 0
    @ObservationIgnored private var requestGeneration = 0

    // MARK: - 初始化

    init() {
        // 初始状态
    }

    // MARK: - 公共方法

    /// 刷新数据
    func refresh() async {
        await loadData(isRefresh: true)
    }

    /// 加载更多数据
    func loadMore() async {
        guard !isLoading && !isLoadingMore && hasMoreData else { return }
        await loadData(isRefresh: false)
    }

    /// 检查是否需要加载更多（由 View 调用）
    func loadMoreIfNeeded(_ article: InfoModel) async {
        guard let index = articles.firstIndex(where: { $0.id == article.id }),
              index >= articles.count - 3,
              !isLoading,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadMore()
    }

    // MARK: - 私有方法

    private func loadData(isRefresh: Bool) async {
        guard !Task.isCancelled else { return }
        if isRefresh {
            guard !isLoading else { return }
            // 新刷新取代旧分页，旧请求不得再修改数据或加载状态。
            requestGeneration += 1
            isLoading = true
            isLoadingMore = false
        } else {
            guard !isLoading && !isLoadingMore && hasMoreData else { return }
            isLoadingMore = true
        }
        let generation = requestGeneration
        let requestedPage = isRefresh ? 1 : currentPage + 1
        errorMessage = nil

        defer {
            if generation == requestGeneration {
                isLoading = false
                isLoadingMore = false
            }
        }

        do {
            if isRefresh {
                // 保留首页 Banner、置顶文章和普通文章的并行请求。
                async let banners = apiService.fetchBanners()
                async let topArticles = apiService.fetchTopArticles()
                async let articles = apiService.fetchArticleList(page: requestedPage)
                let (bannersResult, topArticlesResult, pageResult) = try await (banners, topArticles, articles)

                guard !Task.isCancelled, generation == requestGeneration else { return }
                self.banners = bannersResult
                self.articles = topArticlesResult + (pageResult.datas ?? [])
                currentPage = requestedPage
                hasMoreData = pageResult.hasMore
            } else {
                let pageResult = try await apiService.fetchArticleList(page: requestedPage)
                guard !Task.isCancelled, generation == requestGeneration else { return }
                articles.append(contentsOf: pageResult.datas ?? [])
                currentPage = requestedPage
                hasMoreData = pageResult.hasMore
            }
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), generation == requestGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }
}
