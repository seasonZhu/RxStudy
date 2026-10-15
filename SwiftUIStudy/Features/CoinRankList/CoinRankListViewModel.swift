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
    // MARK: - 状态

    /// 积分排名列表
    private(set) var ranks: [CoinRankModel] = []

    /// 加载状态
    private(set) var isLoading = false

    /// 加载更多状态
    private(set) var isLoadingMore = false

    /// 错误信息
    private(set) var errorMessage: String?

    /// 是否还有更多数据
    private(set) var hasMoreData = true

    // MARK: - 私有属性

    private let apiService = CoinAPIService.shared
    private var currentPage = 0
    @ObservationIgnored private var requestGeneration = 0

    // MARK: - 公共方法

    /// 加载积分排名
    func loadData() async {
        await loadRanks(isRefresh: true)
    }

    /// 加载更多排名
    func loadMore() async {
        guard !isLoading && !isLoadingMore && hasMoreData else { return }
        await loadRanks(isRefresh: false)
    }

    /// 检查是否需要加载更多
    func loadMoreIfNeeded(_ rank: CoinRankModel) async {
        guard let index = ranks.firstIndex(where: { $0.userId == rank.userId }),
              index >= ranks.count - 3,
              !isLoading,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadMore()
    }

    // MARK: - 私有方法

    private func loadRanks(isRefresh: Bool) async {
        guard !Task.isCancelled else { return }
        if isRefresh {
            guard !isLoading else { return }
            // 新刷新取代旧分页，旧请求不得再修改数据或加载状态。
            requestGeneration += 1
            isLoading = true
            isLoadingMore = false
        } else {
            guard !isLoading && !isLoadingMore && hasMoreData else { return }
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
            let pageResult = try await apiService.fetchCoinRank(page: requestedPage)
            guard !Task.isCancelled, generation == requestGeneration else { return }
            if isRefresh {
                ranks = pageResult.datas ?? []
            } else {
                ranks.append(contentsOf: pageResult.datas ?? [])
            }
            currentPage = requestedPage
            hasMoreData = pageResult.hasMore
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), generation == requestGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }
}
