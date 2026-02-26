//
//  SearchResultViewModel.swift
//  RxStudy - SwiftUIApp
//
//  搜索结果 ViewModel
//

import Foundation

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
    private let pageSize = 20

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

    /// 刷新数据
    func refresh() {
        print("🔄 开始刷新搜索结果，关键词: \(keyword)")
        currentPage = 0
        hasNoMoreData = false
        loadArticles()
    }

    /// 加载更多
    func loadMore() {
        guard !isLoadingMore && !hasNoMoreData else { return }
        print("⬇️ 加载更多，页码: \(currentPage + 1)")
        currentPage += 1
        loadArticles()
    }

    /// 根据文章判断是否需要加载更多
    func loadMoreIfNeeded(article: InfoModel) -> Bool {
        guard !isLoadingMore && !hasNoMoreData else { return false }

        // 当滚动到倒数第 3 个时开始加载
        if let index = articles.firstIndex(where: { $0.id == article.id }),
           index >= articles.count - 3 {
            loadMore()
            return true
        }
        return false
    }

    // MARK: - 私有方法

    private func loadArticles() {
        if currentPage == 0 {
            isLoading = true
        } else {
            isLoadingMore = true
        }

        print("🌐 开始请求第 \(currentPage) 页数据...")

        Task { @MainActor in
            do {
                let page = try await apiService.searchArticles(keyword: keyword, page: currentPage)

                print("✅ 请求成功，收到 \(page.datas?.count ?? 0) 条数据")

                if currentPage == 0 {
                    articles = page.datas ?? []
                } else {
                    articles.append(contentsOf: page.datas ?? [])
                }

                // 判断是否还有更多数据
                hasNoMoreData = page.over ?? false
                errorMessage = nil

                print("📊 当前总共 \(articles.count) 条数据，是否还有更多: \(hasNoMoreData)")

            } catch {
                print("❌ 请求失败: \(error)")
                if currentPage == 0 {
                    errorMessage = error.localizedDescription
                } else {
                    // 加载更多失败，回退页码
                    currentPage -= 1
                }
            }

            isLoading = false
            isLoadingMore = false
        }
    }
}
