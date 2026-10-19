//
//  CoinRankListViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  积分排名列表 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 积分排名 ViewModel

@MainActor
@Observable
final class CoinRankListViewModel {
    private let pagination = PaginationState<CoinRankModel, Void>(firstPage: 1)
    private let apiService = CoinAPIService.shared

    var ranks: [CoinRankModel] { pagination.items }
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

    func loadMoreIfNeeded(_ item: CoinRankModel) async {
        await pagination.loadMoreIfNeeded(item, identifiedBy: \.userId, load: fetchPage)
    }

    private func fetchPage(_ page: Int) async throws -> PaginationPage<CoinRankModel, Void> {
        PaginationPage(page: try await apiService.fetchCoinRank(page: page))
    }
}
