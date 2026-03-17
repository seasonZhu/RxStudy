//
//  CategoryPageViewModel.swift
//  RxStudy - SwiftUIApp
//
//  分类页面 ViewModel
//  负责管理分类数据和文章数据的加载
//

import Foundation

// MARK: - 分类页面 ViewModel

@Observable
final class CategoryPageViewModel<T: CategoryItem> {
    // MARK: - 分类数据

    private(set) var categories: [T] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - 文章数据

    private(set) var articles: [InfoModel] = []
    private(set) var isLoadingMore = false
    private(set) var hasMoreData = true
    var currentPage = 0
    var isInitialized = false

    // MARK: - 私有属性

    private var articlePage = 0
    private let categoryType: CategoryType
    private let service: UnifiedCategoryService<T>

    // MARK: - 初始化

    init(categoryType: CategoryType) {
        self.categoryType = categoryType
        self.service = UnifiedCategoryService<T>(type: categoryType)
    }

    // MARK: - 加载分类

    func loadCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.fetchCategories()
            await MainActor.run {
                self.categories = result
                self.isLoading = false
                // 默认选中第一个
                if let first = result.first {
                    self.selectCategory(first)
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - 选择分类

    func selectCategory(_ category: T) {
        // 重置文章数据
        articles = []
        isInitialized = false
        hasMoreData = true
        articlePage = 0
    }

    // MARK: - 加载文章列表

    func loadArticles(categoryId: Int, isRefresh: Bool) async {
        if isRefresh {
            isLoading = true
            articlePage = 0
            hasMoreData = true
            errorMessage = nil
        } else {
            isLoadingMore = true
        }

        do {
            let result = try await service.fetchArticleList(id: categoryId, page: isRefresh ? 1 : articlePage + 1)

            await MainActor.run {
                if isRefresh {
                    articles = result.datas ?? []
                } else {
                    if let newArticles = result.datas {
                        articles.append(contentsOf: newArticles)
                    }
                }
                hasMoreData = result.hasMore
                articlePage += 1
                isLoading = false
                isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
                isLoadingMore = false
            }
        }
    }

    // MARK: - 加载更多

    func loadMoreIfNeeded(_ article: InfoModel, categoryId: Int) async {
        guard let index = articles.firstIndex(where: { $0.id == article.id }),
              index >= articles.count - 3,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadArticles(categoryId: categoryId, isRefresh: false)
    }
}
