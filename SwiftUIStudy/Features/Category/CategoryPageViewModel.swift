//
//  CategoryPageViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  分类页面 ViewModel
//  分类与文章分页状态按分类 ID 独立保存
//

import Foundation

// MARK: - 分类页面 ViewModel

@MainActor
@Observable
final class CategoryPageViewModel<T: CategoryItem> {
    private(set) var categories: [T] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var currentPage = 0
    private(set) var articleViewModels: [Int: CategoryArticleListViewModel<T>] = [:]

    private let service: UnifiedCategoryService<T>

    init(categoryType: CategoryType) {
        service = UnifiedCategoryService<T>(type: categoryType)
    }

    func loadCategories() async {
        guard !isLoading, !Task.isCancelled else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await service.fetchCategories()
            guard !Task.isCancelled else { return }
            var models: [Int: CategoryArticleListViewModel<T>] = [:]
            for category in result {
                guard let id = category.id, id > 0 else { continue }
                models[id] = articleViewModels[id] ?? CategoryArticleListViewModel(categoryId: id, service: service)
            }
            articleViewModels = models
            categories = result
            if !categories.indices.contains(currentPage) {
                currentPage = 0
            }
        } catch {
            guard !Task.isCancelled, !(error is CancellationError) else { return }
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - 单个分类的文章分页状态

@MainActor
@Observable
final class CategoryArticleListViewModel<T: CategoryItem> {
    private(set) var articles: [InfoModel] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasMoreData = true
    private(set) var errorMessage: String?
    private(set) var isInitialized = false

    private let categoryId: Int
    private let service: UnifiedCategoryService<T>
    private var currentPage = 0
    @ObservationIgnored private var requestGeneration = 0

    init(categoryId: Int, service: UnifiedCategoryService<T>) {
        self.categoryId = categoryId
        self.service = service
    }

    func loadIfNeeded() async {
        guard !isInitialized else { return }
        await refresh()
    }

    func refresh() async {
        await loadArticles(isRefresh: true)
    }

    func loadMoreIfNeeded(_ article: InfoModel) async {
        guard !isLoading, !isLoadingMore, hasMoreData,
              let index = articles.firstIndex(where: { $0.id == article.id }),
              index >= articles.count - 3 else { return }
        await loadArticles(isRefresh: false)
    }

    private func loadArticles(isRefresh: Bool) async {
        guard !Task.isCancelled else { return }
        if isRefresh {
            guard !isLoading else { return }
            requestGeneration += 1
            isLoading = true
            isLoadingMore = false
        } else {
            guard !isLoading, !isLoadingMore, hasMoreData else { return }
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
            let result = try await service.fetchArticleList(id: categoryId, page: requestedPage)
            guard !Task.isCancelled, generation == requestGeneration else { return }
            if isRefresh {
                articles = result.datas ?? []
            } else {
                articles.append(contentsOf: result.datas ?? [])
            }
            currentPage = requestedPage
            hasMoreData = result.hasMore
            isInitialized = true
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), generation == requestGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }
}
