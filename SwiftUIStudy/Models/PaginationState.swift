//
//  PaginationState.swift
//  RxStudy - SwiftUIStudy
//
//  Created by Codex on 2026/10/19.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation

/// 一次请求的列表与刷新附加数据，经过请求代次校验后统一提交。
struct PaginationPage<Item, RefreshData> {
    let items: [Item]
    let hasMoreData: Bool
    let refreshData: RefreshData?

    init(items: [Item], hasMoreData: Bool, refreshData: RefreshData? = nil) {
        self.items = items
        self.hasMoreData = hasMoreData
        self.refreshData = refreshData
    }

    init(page: Page<Item>, refreshData: RefreshData? = nil) where Item: Codable {
        self.init(items: page.datas ?? [], hasMoreData: page.hasMore, refreshData: refreshData)
    }
}

/// 页面只提供数据加载；分页状态、旧响应隔离与提交顺序集中在这里。
@MainActor
@Observable
final class PaginationState<Item, RefreshData> {
    private(set) var items: [Item] = []
    private(set) var refreshData: RefreshData?
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasMoreData = true
    private(set) var errorMessage: String?
    private(set) var isInitialized = false

    private let firstPage: Int
    private var currentPage = 0
    @ObservationIgnored private var requestGeneration = 0

    init(firstPage: Int) {
        self.firstPage = firstPage
    }

    func refresh(load: (Int) async throws -> PaginationPage<Item, RefreshData>) async {
        await request(isRefresh: true, load: load)
    }

    func loadMore(load: (Int) async throws -> PaginationPage<Item, RefreshData>) async {
        await request(isRefresh: false, load: load)
    }

    func loadMoreIfNeeded<ID: Equatable>(
        _ item: Item,
        identifiedBy keyPath: KeyPath<Item, ID>,
        load: (Int) async throws -> PaginationPage<Item, RefreshData>
    ) async {
        guard !isLoading, !isLoadingMore, hasMoreData,
              let index = items.firstIndex(where: { $0[keyPath: keyPath] == item[keyPath: keyPath] }),
              index >= items.count - 3 else { return }
        await loadMore(load: load)
    }

    private func request(isRefresh: Bool, load: (Int) async throws -> PaginationPage<Item, RefreshData>) async {
        guard !Task.isCancelled else { return }
        if isRefresh {
            guard !isLoading else { return }
            requestGeneration += 1
            isLoading = true
            isLoadingMore = false
        } else {
            guard !isLoading, !isLoadingMore, hasMoreData else { return }
            isLoadingMore = true
        }
        let generation = requestGeneration
        let requestedPage = isRefresh ? firstPage : currentPage + 1
        errorMessage = nil
        defer {
            if generation == requestGeneration {
                isLoading = false
                isLoadingMore = false
            }
        }
        do {
            let page = try await load(requestedPage)
            guard !Task.isCancelled, generation == requestGeneration else { return }
            if isRefresh {
                items = page.items
                refreshData = page.refreshData
            } else {
                items.append(contentsOf: page.items)
            }
            currentPage = requestedPage
            hasMoreData = page.hasMoreData
            isInitialized = true
        } catch {
            guard !Task.isCancelled, !(error is CancellationError), generation == requestGeneration else { return }
            errorMessage = error.localizedDescription
        }
    }
}
