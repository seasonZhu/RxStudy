//
//  TreeArticleListViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  体系文章列表 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 体系文章列表 ViewModel

@MainActor
@Observable
final class TreeArticleListViewModel {
    // MARK: - 状态

    /// 文章列表
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

    private let apiService = TreeAPIService.shared
    private let tagId: Int
    private(set) var tagName: String
    private var currentPage = 0
    @ObservationIgnored private var requestGeneration = 0

    // MARK: - 初始化

    init(tagId: Int, tagName: String) {
        self.tagId = tagId
        self.tagName = tagName
    }

    // MARK: - 公共方法

    /// 加载文章列表
    func loadData() async {
        await loadArticles(isRefresh: true)
    }

    /// 加载更多文章
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
            let pageResult = try await apiService.fetchArticleList(tagId: tagId, page: requestedPage)
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
