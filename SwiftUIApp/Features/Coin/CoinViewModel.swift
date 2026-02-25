//
//  CoinViewModel.swift
//  RxStudy - SwiftUIApp
//
//  我的积分页面 ViewModel
//  使用 @Observable + async/await
//

import Foundation
import Moya

// MARK: - 积分 ViewModel

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

    // MARK: - 内存优化

    private let maxDataSourceCount = 200
    private let dataCleanupThreshold = 250

    // MARK: - 私有属性

    private let apiService = CoinAPIService.shared
    private let accountService = AccountAPIService.shared
    private var currentPage = 0

    // MARK: - 计算属性

    /// 是否已登录（引用全局状态）
    var isLoggedIn: Bool {
        return accountService.isLoggedIn
    }

    // MARK: - 初始化

    init() {
        // 不在 init 中检查登录状态，由 View 处理
    }

    // MARK: - 公共方法

    /// 加载积分信息和记录
    func loadData() async {
        currentPage = 0
        hasMoreData = true
        await loadRecords(isRefresh: true)
    }

    /// 加载更多记录
    func loadMore() async {
        guard !isLoadingMore && hasMoreData else { return }
        await loadRecords(isRefresh: false)
    }

    /// 检查是否需要加载更多
    func loadMoreIfNeeded(_ coin: MyHistoryCoin) async {
        guard let index = coins.firstIndex(where: { $0.id == coin.id }),
              index >= coins.count - 3,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadMore()
    }

    // MARK: - 私有方法

    private func loadRecords(isRefresh: Bool) async {
        if isRefresh {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil

        do {
            if isRefresh && currentPage == 0 {
                // 首次加载：同时请求用户信息和记录列表
                async let userInfo = apiService.fetchUserInfo()
                async let coins = apiService.fetchMyCoinList(page: 1)

                let (user, pageResult) = try await (userInfo, coins)

                await MainActor.run {
                    self.userInfo = user
                    self.coins = pageResult.datas ?? []
                    self.currentPage = 1
                    self.hasMoreData = pageResult.hasMore
                    self.cleanupOldDataIfNeeded()
                }
            } else {
                currentPage = isRefresh ? 1 : currentPage + 1
                let pageResult = try await apiService.fetchMyCoinList(page: currentPage)

                await MainActor.run {
                    if isRefresh {
                        self.coins = pageResult.datas ?? []
                    } else {
                        if let newCoins = pageResult.datas {
                            self.coins.append(contentsOf: newCoins)
                        }
                    }
                    self.hasMoreData = pageResult.hasMore
                    self.cleanupOldDataIfNeeded()
                }
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
        guard coins.count > dataCleanupThreshold else { return }

        let excessCount = coins.count - maxDataSourceCount
        coins.removeFirst(excessCount)

        print("🧹 内存优化: 已移除 \(excessCount) 条旧数据，当前数据量: \(coins.count)")
    }
}
