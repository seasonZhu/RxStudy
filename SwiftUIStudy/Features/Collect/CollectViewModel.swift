//
//  CollectViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  我的收藏页面 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 收藏 ViewModel

@MainActor
@Observable
final class CollectViewModel {
    // MARK: - 状态

    /// 收藏列表
    private(set) var articles: [InfoModel] = []

    /// 加载状态
    private(set) var isLoading = false

    /// 加载更多状态
    private(set) var isLoadingMore = false

    /// 错误信息
    private(set) var errorMessage: String?

    /// 是否还有更多数据
    private(set) var hasMoreData = true

    // MARK: - 私有属性

    private let apiService = CollectAPIService.shared
    private var currentPage = 0
    @ObservationIgnored private var requestGeneration = 0

    // MARK: - 初始化

    init() {
        // 不在 init 中检查登录状态，由 View 处理
    }

    // MARK: - 公共方法

    /// 加载收藏列表
    func loadData() async {
        await loadArticles(isRefresh: true)
    }

    /// 加载更多
    func loadMore() async {
        guard !isLoading && !isLoadingMore && hasMoreData else { return }
        await loadArticles(isRefresh: false)
    }

    /// 检查是否需要加载更多
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

    private func loadArticles(isRefresh: Bool) async {
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
        let requestedPage = isRefresh ? 0 : currentPage + 1
        errorMessage = nil

        defer {
            if generation == requestGeneration {
                isLoading = false
                isLoadingMore = false
            }
        }

        do {
            let pageResult = try await apiService.fetchCollectList(page: requestedPage)
            guard !Task.isCancelled, generation == requestGeneration else { return }
            if isRefresh {
                articles = pageResult.datas ?? []
            } else {
                articles.append(contentsOf: pageResult.datas ?? [])
            }
            currentPage = requestedPage
            hasMoreData = pageResult.hasMore
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), generation == requestGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }
}
