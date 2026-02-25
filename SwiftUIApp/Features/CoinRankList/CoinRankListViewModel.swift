//
//  CoinRankListViewModel.swift
//  RxStudy - SwiftUIApp
//
//  积分排名列表 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 积分排名 ViewModel

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

    // MARK: - 内存优化

    private let maxDataSourceCount = 200
    private let dataCleanupThreshold = 250

    // MARK: - 私有属性

    private let apiService = CoinAPIService.shared
    private var currentPage = 0

    // MARK: - 公共方法

    /// 加载积分排名
    func loadData() async {
        currentPage = 0
        hasMoreData = true
        await loadRanks(isRefresh: true)
    }

    /// 加载更多排名
    func loadMore() async {
        guard !isLoadingMore && hasMoreData else { return }
        await loadRanks(isRefresh: false)
    }

    /// 检查是否需要加载更多
    func loadMoreIfNeeded(_ rank: CoinRankModel) async {
        guard let index = ranks.firstIndex(where: { $0.userId == rank.userId }),
              index >= ranks.count - 3,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadMore()
    }

    // MARK: - 私有方法

    private func loadRanks(isRefresh: Bool) async {
        if isRefresh {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil

        do {
            currentPage = isRefresh ? 1 : currentPage + 1
            let pageResult = try await apiService.fetchCoinRank(page: currentPage)

            await MainActor.run {
                if isRefresh {
                    self.ranks = pageResult.datas ?? []
                } else {
                    if let newRanks = pageResult.datas {
                        self.ranks.append(contentsOf: newRanks)
                    }
                }
                self.hasMoreData = pageResult.hasMore
                self.cleanupOldDataIfNeeded()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                if isRefresh {
                    self.currentPage = 0
                } else {
                    self.currentPage -= 1
                }
            }
        }

        await MainActor.run {
            if isRefresh {
                isLoading = false
            } else {
                isLoadingMore = false
            }
        }
    }

    private func cleanupOldDataIfNeeded() {
        guard ranks.count > dataCleanupThreshold else { return }

        let excessCount = ranks.count - maxDataSourceCount
        ranks.removeFirst(excessCount)

        print("🧹 内存优化: 已移除 \(excessCount) 条旧数据，当前数据量: \(ranks.count)")
    }
}
