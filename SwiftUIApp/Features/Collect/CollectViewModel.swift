//
//  CollectViewModel.swift
//  RxStudy - SwiftUIApp
//
//  我的收藏页面 ViewModel
//  使用 @Observable + async/await
//

import Foundation
import Moya

// MARK: - 收藏 ViewModel

@Observable
final class CollectViewModel {
    // MARK: - 状态

    /// 收藏列表
    private(set) var articles: [CollectArticleModel] = []

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

    private let apiService = CollectAPIService.shared
    private var currentPage = 0

    // MARK: - 初始化

    init() {
        // 不在 init 中检查登录状态，由 View 处理
    }

    // MARK: - 公共方法

    /// 加载收藏列表
    func loadData() async {
        currentPage = 0
        hasMoreData = true
        await loadArticles(isRefresh: true)
    }

    /// 加载更多
    func loadMore() async {
        guard !isLoadingMore && hasMoreData else { return }
        await loadArticles(isRefresh: false)
    }

    /// 检查是否需要加载更多
    func loadMoreIfNeeded(_ article: CollectArticleModel) async {
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
            let pageResult = try await apiService.fetchCollectList(page: currentPage)

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
