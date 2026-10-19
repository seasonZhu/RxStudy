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
final class CategoryPageViewModel<Source: CategorySource> {
    private(set) var categories: [Source.Item] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var currentPage = 0
    private(set) var articleViewModels: [Int: CategoryArticleListViewModel<Source>] = [:]

    private let source: Source

    init(source: Source) {
        self.source = source
    }

    func loadCategories() async {
        guard !isLoading, !Task.isCancelled else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await source.fetchCategories()
            guard !Task.isCancelled else { return }
            var models: [Int: CategoryArticleListViewModel<Source>] = [:]
            for category in result {
                guard let id = category.id, id > 0 else { continue }
                models[id] = articleViewModels[id] ?? CategoryArticleListViewModel(categoryId: id, source: source)
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
final class CategoryArticleListViewModel<Source: CategorySource> {
    private let pagination = PaginationState<InfoModel, Void>(firstPage: 1)
    private let categoryId: Int
    private let source: Source

    var articles: [InfoModel] { pagination.items }
    var isLoading: Bool { pagination.isLoading }
    var isLoadingMore: Bool { pagination.isLoadingMore }
    var hasMoreData: Bool { pagination.hasMoreData }
    var errorMessage: String? { pagination.errorMessage }
    var isInitialized: Bool { pagination.isInitialized }

    init(categoryId: Int, source: Source) {
        self.categoryId = categoryId
        self.source = source
    }

    func loadIfNeeded() async {
        guard !isInitialized else { return }
        await refresh()
    }

    func refresh() async {
        await pagination.refresh(load: fetchPage)
    }

    func loadMoreIfNeeded(_ article: InfoModel) async {
        await pagination.loadMoreIfNeeded(article, identifiedBy: \.id, load: fetchPage)
    }

    private func fetchPage(_ page: Int) async throws -> PaginationPage<InfoModel, Void> {
        PaginationPage(page: try await source.fetchArticleList(id: categoryId, page: page))
    }
}
