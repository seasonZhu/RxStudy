//
//  CollectViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  我的收藏页面 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 收藏 ViewModel

@MainActor
@Observable
final class CollectViewModel {
    private let pagination = PaginationState<InfoModel, Void>(firstPage: 0)
    private let apiService = CollectAPIService.shared

    var articles: [InfoModel] { pagination.items }
    var isLoading: Bool { pagination.isLoading }
    var isLoadingMore: Bool { pagination.isLoadingMore }
    var hasMoreData: Bool { pagination.hasMoreData }
    var errorMessage: String? { pagination.errorMessage }

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
        PaginationPage(page: try await apiService.fetchCollectList(page: page))
    }
}
