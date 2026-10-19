//
//  CoinViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  我的积分页面 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 积分 ViewModel

@MainActor
@Observable
final class CoinViewModel {
    private let pagination = PaginationState<MyHistoryCoin, CoinRankModel>(firstPage: 1)
    private let apiService = CoinAPIService.shared

    var userInfo: CoinRankModel? { pagination.refreshData }
    var coins: [MyHistoryCoin] { pagination.items }
    var isLoading: Bool { pagination.isLoading }
    var isLoadingMore: Bool { pagination.isLoadingMore }
    var errorMessage: String? { pagination.errorMessage }
    var hasMoreData: Bool { pagination.hasMoreData }

    func loadData() async {
        await pagination.refresh { page in
            async let user = apiService.fetchUserInfo()
            async let records = apiService.fetchMyCoinList(page: page)
            let (userInfo, pageResult) = try await (user, records)
            return PaginationPage(page: pageResult, refreshData: userInfo)
        }
    }

    func loadMore() async {
        await pagination.loadMore(load: fetchPage)
    }

    func loadMoreIfNeeded(_ coin: MyHistoryCoin) async {
        await pagination.loadMoreIfNeeded(coin, identifiedBy: \.id, load: fetchPage)
    }

    private func fetchPage(_ page: Int) async throws -> PaginationPage<MyHistoryCoin, CoinRankModel> {
        PaginationPage(page: try await apiService.fetchMyCoinList(page: page))
    }
}
