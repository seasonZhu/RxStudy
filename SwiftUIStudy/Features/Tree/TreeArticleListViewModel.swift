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
    private let pagination = PaginationState<InfoModel, Void>(firstPage: 0)
    private let apiService = TreeAPIService.shared
    private let tagId: Int
    private(set) var tagName: String

    var articles: [InfoModel] { pagination.items }
    var isLoading: Bool { pagination.isLoading }
    var isLoadingMore: Bool { pagination.isLoadingMore }
    var hasMoreData: Bool { pagination.hasMoreData }
    var errorMessage: String? { pagination.errorMessage }

    init(tagId: Int, tagName: String) {
        self.tagId = tagId
        self.tagName = tagName
    }

    func loadData() async {
        await pagination.refresh(load: fetchPage)
    }

    func loadMore() async {
        await pagination.loadMore(load: fetchPage)
    }

    func loadMoreIfNeeded(_ item: InfoModel) async {
        await pagination.loadMoreIfNeeded(item, identifiedBy: \.id, load: fetchPage)
    }

    private func fetchPage(_ page: Int) async throws -> PaginationPage<InfoModel, Void> {
        PaginationPage(page: try await apiService.fetchArticleList(tagId: tagId, page: page))
    }
}
