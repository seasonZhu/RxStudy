//
//  HomeViewModel.swift
//  RxStudy - SwiftUIApp
//
//  首页 ViewModel
//  使用 @Observable + async/await
//

import Foundation

/// SwiftUI 最新数据模型完整解析：@Observable、@State、@Bindable（iOS17+ 全新范式）
/// https://juejin.cn/post/7578177007576268854

// MARK: - 首页 ViewModel

@Observable
final class HomeViewModel {
    // MARK: - 状态

    /// 文章列表
    private(set) var articles: [InfoModel] = []

    /// Banner 列表
    private(set) var banners: [HomeBannerModel] = []

    /// 加载状态
    private(set) var isLoading = false

    /// 加载更多状态
    private(set) var isLoadingMore = false

    /// 错误信息
    private(set) var errorMessage: String?

    /// 是否还有更多数据
    private(set) var hasMoreData = true

    // MARK: - 内存优化

    /// 最大数据条数限制
    private let maxDataSourceCount = 200

    /// 数据清理阈值
    private let dataCleanupThreshold = 250

    // MARK: - 私有属性

    private let apiService = HomeAPIService.shared
    private var currentPage = 0

    // MARK: - 初始化

    init() {
        // 初始状态
    }

    // MARK: - 公共方法

    /// 刷新数据
    func refresh() async {
        currentPage = 0
        hasMoreData = true
        await loadData(isRefresh: true)
    }

    /// 加载更多数据
    func loadMore() async {
        guard !isLoadingMore && hasMoreData else { return }
        await loadData(isRefresh: false)
    }

    /// 检查是否需要加载更多（由 View 调用）
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

    private func loadData(isRefresh: Bool) async {
        // 更新加载状态
        if isRefresh {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil

        do {
            if isRefresh && currentPage == 0 {
                // 首次刷新：同时请求 Banner 和文章
                async let banners = apiService.fetchBanners()
                async let topArticles = apiService.fetchTopArticles()
                async let articles = apiService.fetchArticleList(page: 1)

                let (bannersResult, topArticlesResult, pageResult) = try await (banners, topArticles, articles)

                await MainActor.run {
                    self.banners = bannersResult
                    self.articles = topArticlesResult + (pageResult.datas ?? [])
                    self.currentPage = 1
                    self.hasMoreData = pageResult.hasMore
                    self.cleanupOldDataIfNeeded()
                }
            } else {
                // 加载更多
                currentPage += 1
                let pageResult = try await apiService.fetchArticleList(page: currentPage)

                await MainActor.run {
                    if let newArticles = pageResult.datas {
                        self.articles.append(contentsOf: newArticles)
                    }
                    self.hasMoreData = pageResult.hasMore
                    self.cleanupOldDataIfNeeded()
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                if isRefresh {
                    currentPage = 0
                } else {
                    currentPage -= 1
                }
            }
        }

        // 重置加载状态
        await MainActor.run {
            if isRefresh {
                isLoading = false
            } else {
                isLoadingMore = false
            }
        }
    }

    /// 清理旧数据以控制内存使用
    private func cleanupOldDataIfNeeded() {
        guard articles.count > dataCleanupThreshold else { return }

        let excessCount = articles.count - maxDataSourceCount
        articles.removeFirst(excessCount)

        print("🧹 内存优化: 已移除 \(excessCount) 条旧数据，当前数据量: \(articles.count)")
    }
}
