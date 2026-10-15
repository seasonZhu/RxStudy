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
    // MARK: - 状态

    /// 积分信息
    private(set) var userInfo: CoinRankModel?

    /// 积分记录列表
    private(set) var coins: [MyHistoryCoin] = []

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

    // MARK: - 初始化

    init() {
        // 不在 init 中检查登录状态，由 View 处理
    }

    // MARK: - 公共方法

    /// 加载积分信息和记录
    func loadData() async {
        await loadRecords(isRefresh: true)
    }

    /// 加载更多记录
    func loadMore() async {
        guard !isLoading && !isLoadingMore && hasMoreData else { return }
        await loadRecords(isRefresh: false)
    }

    /// 检查是否需要加载更多
    func loadMoreIfNeeded(_ coin: MyHistoryCoin) async {
        guard let index = coins.firstIndex(where: { $0.id == coin.id }),
              index >= coins.count - 3,
              !isLoading,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadMore()
    }

    // MARK: - 私有方法

    private func loadRecords(isRefresh: Bool) async {
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
            if isRefresh {
                async let userInfo = apiService.fetchUserInfo()
                async let coins = apiService.fetchMyCoinList(page: requestedPage)
                let (user, pageResult) = try await (userInfo, coins)

                guard !Task.isCancelled, generation == requestGeneration else { return }
                self.userInfo = user
                self.coins = pageResult.datas ?? []
                currentPage = requestedPage
                hasMoreData = pageResult.hasMore
            } else {
                let pageResult = try await apiService.fetchMyCoinList(page: requestedPage)
                guard !Task.isCancelled, generation == requestGeneration else { return }
                coins.append(contentsOf: pageResult.datas ?? [])
                currentPage = requestedPage
                hasMoreData = pageResult.hasMore
            }
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), generation == requestGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }
}
