//
//  SearchResultViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  搜索结果 ViewModel
//

import Foundation

@MainActor
@Observable
class SearchResultViewModel {
    private let pagination = PaginationState<InfoModel, Void>(firstPage: 0)
    private let apiService: HomeAPIService
    private let keyword: String

    var articles: [InfoModel] { pagination.items }
    var isLoading: Bool { pagination.isLoading }
    var isLoadingMore: Bool { pagination.isLoadingMore }
    var hasNoMoreData: Bool { !pagination.hasMoreData }
    var errorMessage: String? { pagination.errorMessage }

    init(keyword: String, apiService: HomeAPIService = .shared) {
        self.keyword = keyword
        self.apiService = apiService
        print("🔍 初始化 SearchResultViewModel，关键词: \(keyword)")
    }

    func refresh() async {
        await pagination.refresh(load: fetchPage)
    }

    func loadMore() async {
        await pagination.loadMore(load: fetchPage)
    }

    func loadMoreIfNeeded(article: InfoModel) async {
        await pagination.loadMoreIfNeeded(article, identifiedBy: \.id, load: fetchPage)
    }

    private func fetchPage(_ page: Int) async throws -> PaginationPage<InfoModel, Void> {
        let result = try await apiService.searchArticles(keyword: keyword, page: page)
        return PaginationPage(items: result.datas ?? [], hasMoreData: !(result.over ?? false))
    }
}
