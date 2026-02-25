//
//  ProjectViewModel.swift
//  RxStudy - SwiftUIApp
//
//  项目页面 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 项目 ViewModel

@Observable
final class ProjectViewModel {
    // MARK: - 状态

    /// 项目分类列表
    private(set) var tags: [ProjectTagModel] = []

    /// 当前选中的分类
    private(set) var selectedTag: ProjectTagModel?

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

    private let apiService = ProjectAPIService.shared
    private var currentPage = 0

    // MARK: - 初始化

    init() {
        // 初始加载分类
        Task {
            await loadTags()
        }
    }

    // MARK: - 公共方法

    /// 加载项目分类
    func loadTags() async {
        isLoading = true
        errorMessage = nil

        do {
            let tags = try await apiService.fetchTags()

            await MainActor.run {
                self.tags = tags
                // 默认选中第一个分类
                if let firstTag = tags.first {
                    self.selectedTag = firstTag
                    // 自动加载第一页
                    Task {
                        await refresh()
                    }
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// 选择分类
    func selectTag(_ tag: ProjectTagModel) {
        selectedTag = tag
        Task {
            await refresh()
        }
    }

    /// 刷新当前分类的文章列表
    func refresh() async {
        guard let tag = selectedTag else { return }

        currentPage = 0
        hasMoreData = true
        await loadArticles(tagId: tag.id ?? 0, isRefresh: true)
    }

    /// 加载更多文章
    func loadMore() async {
        guard let tag = selectedTag,
              !isLoadingMore && hasMoreData else { return }
        await loadArticles(tagId: tag.id ?? 0, isRefresh: false)
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

    private func loadArticles(tagId: Int, isRefresh: Bool) async {
        if isRefresh {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil

        do {
            currentPage = isRefresh ? 1 : currentPage + 1
            let pageResult = try await apiService.fetchProjectList(tagId: tagId, page: currentPage)

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
