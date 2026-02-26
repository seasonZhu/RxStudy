//
//  TreeArticleListViewModel.swift
//  RxStudy - SwiftUIApp
//
//  体系文章列表 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 体系文章列表 ViewModel

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

    // MARK: - 内存优化

    private let maxDataSourceCount = 200
    private let dataCleanupThreshold = 250

    // MARK: - 私有属性

    private let apiService = TreeAPIService.shared
    private let tagId: Int
    private(set) var tagName: String
    private var currentPage = 0

    // MARK: - 初始化

    init(tagId: Int, tagName: String) {
        self.tagId = tagId
        self.tagName = tagName
    }

    // MARK: - 公共方法

    /// 加载文章列表
    func loadData() async {
        currentPage = 0
        hasMoreData = true
        await loadArticles(isRefresh: true)
    }

    /// 加载更多文章
    func loadMore() async {
        guard !isLoadingMore && hasMoreData else { return }
        await loadArticles(isRefresh: false)
    }

    /// 检查是否需要加载更多
    func loadMoreIfNeeded(_ article: InfoModel) async {
        guard let index = articles.firstIndex(where: { $0.id == article.id }),
              index >= articles.count - 3,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadMore()
    }

    // MARK: - 私有方法

    private func loadArticles(isRefresh: Bool) async {
        if isRefresh {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil

        do {
            currentPage = isRefresh ? 0 : currentPage + 1
            let pageResult = try await apiService.fetchArticleList(tagId: tagId, page: currentPage)

            await MainActor.run {
                if isRefresh {
                    self.articles = pageResult.datas ?? []
                } else {
                    if let newArticles = pageResult.datas {
                        self.articles.append(contentsOf: newArticles)
                    }
                }
                self.hasMoreData = pageResult.hasMore
                self.cleanupOldDataIfNeeded()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                if isRefresh {
                    self.currentPage = 0
                } else {
                    self.currentPage -= 1
                }
            }
        }

        await MainActor.run {
            if isRefresh {
                isLoading = false
            } else {
                isLoadingMore = false
            }
        }
    }

    private func cleanupOldDataIfNeeded() {
        guard articles.count > dataCleanupThreshold else { return }

        let excessCount = articles.count - maxDataSourceCount
        articles.removeFirst(excessCount)

        print("🧹 内存优化: 已移除 \(excessCount) 条旧数据，当前数据量: \(articles.count)")
    }
}
