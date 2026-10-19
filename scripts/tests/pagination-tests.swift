//
//  pagination-tests.swift
//  RxStudy - SwiftUI 分页测试
//
//  Created by Codex on 2026/10/19.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import Observation

private enum RequestFailure: LocalizedError {
    case expected
    var errorDescription: String? { "测试请求失败" }
}

private struct Item: Codable { let id: Int }
private final class ObservationFlag { var changed = false }

/// 仅替换请求，所有分页状态和七个 ViewModel 均编译真实应用源码。
@MainActor
private enum Fixture {
    static var calls: [(String, Int?)] = []
    static var pageCount = 1
    static var beforeResponse: ((String) async throws -> Void)?

    static func request(_ name: String, page: Int? = nil) async throws {
        calls.append((name, page))
        try await beforeResponse?(name)
    }

    static func decode<T: Decodable>(_ type: T.Type, _ object: Any) throws -> T {
        try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: object))
    }

    static func page<T: Codable>(_ type: T.Type, page: Int, idKey: String = "id") throws -> Page<T> {
        try decode(Page<T>.self, ["curPage": 1, "pageCount": pageCount, "over": false, "datas": [[idKey: page]]])
    }
}

final class HomeAPIService {
    static let shared = HomeAPIService()
    func fetchBanners() async throws -> [Banner] {
        try await Fixture.request("banners")
        return try await Fixture.decode([Banner].self, [["id": 100]])
    }
    func fetchTopArticles() async throws -> [InfoModel] {
        try await Fixture.request("top")
        return try await Fixture.decode([InfoModel].self, [["id": 99]])
    }
    func fetchArticleList(page: Int) async throws -> Page<InfoModel> {
        try await Fixture.request("home", page: page)
        return try await Fixture.page(InfoModel.self, page: page)
    }
    func searchArticles(keyword: String, page: Int) async throws -> Page<InfoModel> {
        precondition(keyword == "关键词")
        try await Fixture.request("search", page: page)
        return try await Fixture.page(InfoModel.self, page: page)
    }
}

final class CoinAPIService {
    static let shared = CoinAPIService()
    func fetchUserInfo() async throws -> CoinRankModel {
        try await Fixture.request("user")
        return try await Fixture.decode(CoinRankModel.self, ["userId": 88])
    }
    func fetchMyCoinList(page: Int) async throws -> Page<MyHistoryCoin> {
        try await Fixture.request("coins", page: page)
        return try await Fixture.page(MyHistoryCoin.self, page: page)
    }
    func fetchCoinRank(page: Int) async throws -> Page<CoinRankModel> {
        try await Fixture.request("ranks", page: page)
        return try await Fixture.page(CoinRankModel.self, page: page, idKey: "userId")
    }
}

final class CollectAPIService {
    static let shared = CollectAPIService()
    func fetchCollectList(page: Int) async throws -> Page<InfoModel> {
        try await Fixture.request("collect", page: page)
        return try await Fixture.page(InfoModel.self, page: page)
    }
}

final class ProjectAPIService {
    static let shared = ProjectAPIService()
    func fetchTags() async throws -> [ProjectTagModel] { [] }
    func fetchProjectList(tagId: Int, page: Int) async throws -> Page<InfoModel> {
        precondition(tagId == 42)
        try await Fixture.request("category", page: page)
        return try await Fixture.page(InfoModel.self, page: page)
    }
}
final class PublicNumberAPIService {
    static let shared = PublicNumberAPIService()
    func fetchTags() async throws -> [PublicNumberTagModel] { [] }
    func fetchArticleList(accountId: Int, page: Int) async throws -> Page<InfoModel> {
        try await Fixture.page(InfoModel.self, page: page)
    }
}
final class TreeAPIService {
    static let shared = TreeAPIService()
    func fetchTags() async throws -> [TreeTagModel] { [] }
    func fetchArticleList(tagId: Int, page: Int) async throws -> Page<InfoModel> {
        precondition(tagId == 43)
        try await Fixture.request("tree", page: page)
        return try await Fixture.page(InfoModel.self, page: page)
    }
}

@main
struct PaginationTests {
    @MainActor
    static func main() async throws {
        await testPaginationRules()
        await testSupersededAndCancelledRequests()
        await testViewModels()
        print("分页测试通过：互斥、页码重试、预加载阈值、末页、取消、旧响应与附加数据隔离、七个页面接入及 Observation 通知")
    }

    @MainActor
    private static func testPaginationRules() async {
        let state = PaginationState<Item, String>(firstPage: 0)
        var requests: [Int] = []
        await state.refresh { page in
            requests.append(page)
            return PaginationPage(items: (0..<5).map(Item.init), hasMoreData: true, refreshData: "附加数据")
        }
        precondition(requests == [0] && state.isInitialized)
        let load: (Int) async throws -> PaginationPage<Item, String> = { page in
            requests.append(page)
            return PaginationPage(items: [Item(id: 5)], hasMoreData: false)
        }
        await state.loadMoreIfNeeded(Item(id: 0), identifiedBy: \.id, load: load)
        await state.loadMoreIfNeeded(Item(id: 999), identifiedBy: \.id, load: load)
        precondition(requests == [0])
        await state.loadMore { page in requests.append(page); throw RequestFailure.expected }
        precondition(requests == [0, 1] && state.items.count == 5 && state.errorMessage != nil)
        await state.loadMoreIfNeeded(Item(id: 2), identifiedBy: \.id, load: load)
        precondition(requests == [0, 1, 1] && state.items.count == 6 && !state.hasMoreData)
        precondition(state.refreshData == "附加数据" && state.errorMessage == nil)
        await state.loadMore(load: load)
        precondition(requests.count == 3)
        await state.refresh { _ in throw RequestFailure.expected }
        precondition(state.items.count == 6 && state.refreshData == "附加数据" && !state.hasMoreData)
        await state.refresh { page in
            precondition(page == 0)
            return PaginationPage(items: [], hasMoreData: false, refreshData: "空列表")
        }
        precondition(state.items.isEmpty && state.refreshData == "空列表" && !state.isLoading)
    }

    @MainActor
    private static func testSupersededAndCancelledRequests() async {
        let state = PaginationState<Item, String>(firstPage: 1)
        var first: CheckedContinuation<PaginationPage<Item, String>, Error>?
        let refresh = Task {
            await state.refresh { _ in try await withCheckedThrowingContinuation { first = $0 } }
        }
        while first == nil { await Task.yield() }
        await state.refresh { _ in preconditionFailure("不能并发刷新") }
        await state.loadMore { _ in preconditionFailure("刷新期间不能分页") }
        first!.resume(returning: PaginationPage(items: [Item(id: 1)], hasMoreData: true, refreshData: "旧数据"))
        await refresh.value

        var old: CheckedContinuation<PaginationPage<Item, String>, Error>?
        let more = Task {
            await state.loadMore { page in
                precondition(page == 2)
                return try await withCheckedThrowingContinuation { old = $0 }
            }
        }
        while old == nil { await Task.yield() }
        await state.loadMore { _ in preconditionFailure("不能并发分页") }
        var fresh: CheckedContinuation<PaginationPage<Item, String>, Error>?
        let replacement = Task {
            await state.refresh { page in
                precondition(page == 1)
                return try await withCheckedThrowingContinuation { fresh = $0 }
            }
        }
        while fresh == nil { await Task.yield() }
        old!.resume(throwing: RequestFailure.expected)
        await more.value
        precondition(state.isLoading && !state.isLoadingMore && state.errorMessage == nil)
        fresh!.resume(returning: PaginationPage(items: [Item(id: 2)], hasMoreData: true, refreshData: "新数据"))
        await replacement.value
        precondition(state.items[0].id == 2 && state.refreshData == "新数据")

        var stale: CheckedContinuation<PaginationPage<Item, String>, Error>?
        let staleSuccess = Task {
            await state.loadMore { _ in try await withCheckedThrowingContinuation { stale = $0 } }
        }
        while stale == nil { await Task.yield() }
        await state.refresh { _ in
            PaginationPage(items: [Item(id: 3)], hasMoreData: true, refreshData: "最新数据")
        }
        stale!.resume(returning: PaginationPage(items: [Item(id: 777)], hasMoreData: false, refreshData: "过期数据"))
        await staleSuccess.value
        precondition(state.items.map(\.id) == [3] && state.refreshData == "最新数据" && state.hasMoreData)

        var cancelled: CheckedContinuation<PaginationPage<Item, String>, Error>?
        let task = Task {
            await state.refresh { _ in try await withCheckedThrowingContinuation { cancelled = $0 } }
        }
        while cancelled == nil { await Task.yield() }
        task.cancel()
        cancelled!.resume(returning: PaginationPage(items: [Item(id: 999)], hasMoreData: false, refreshData: "不能写入"))
        await task.value
        precondition(state.items[0].id == 3 && state.refreshData == "最新数据" && !state.isLoading)
        let alreadyCancelled = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            await state.refresh { _ in preconditionFailure("已取消的任务不能请求") }
        }
        await alreadyCancelled.value
    }

    @MainActor
    private static func testViewModels() async {
        Fixture.calls = []
        Fixture.pageCount = 3
        var barriers: [String: CheckedContinuation<Void, Error>] = [:]
        Fixture.beforeResponse = { name in try await withCheckedThrowingContinuation { barriers[name] = $0 } }
        let home = HomeViewModel()
        let homeChanges = ObservationFlag()
        withObservationTracking { _ = home.articles; _ = home.banners } onChange: { homeChanges.changed = true }
        let homeTask = Task { await home.refresh() }
        while barriers.count < 3 { await Task.yield() }
        precondition(Set(Fixture.calls.map(\.0)) == ["home", "banners", "top"], "首页必须并行启动三个请求")
        precondition(home.articles.isEmpty && home.banners.isEmpty)
        barriers.values.forEach { $0.resume() }
        await homeTask.value
        precondition(home.articles.map(\.id) == [99, 1] && home.banners.first?.id == 100 && homeChanges.changed)
        precondition(Fixture.calls.first(where: { $0.0 == "home" })?.1 == 1)

        Fixture.beforeResponse = nil
        Fixture.calls = []
        await home.loadMore()
        precondition(Fixture.calls.map(\.0) == ["home"] && home.articles.map(\.id) == [99, 1, 2])
        precondition(home.banners.first?.id == 100)
        Fixture.beforeResponse = { if $0 == "top" { throw RequestFailure.expected } }
        await home.refresh()
        precondition(home.errorMessage != nil && home.articles.map(\.id) == [99, 1, 2] && home.banners.first?.id == 100)

        Fixture.calls = []
        barriers.removeAll()
        Fixture.beforeResponse = { name in try await withCheckedThrowingContinuation { barriers[name] = $0 } }
        let coin = CoinViewModel()
        let coinTask = Task { await coin.loadData() }
        while barriers.count < 2 { await Task.yield() }
        precondition(Set(Fixture.calls.map(\.0)) == ["user", "coins"], "积分信息与记录必须并行")
        barriers.values.forEach { $0.resume() }
        await coinTask.value
        precondition(coin.coins.first?.id == 1 && coin.userInfo?.userId == 88)
        Fixture.beforeResponse = nil
        Fixture.calls = []
        await coin.loadMore()
        precondition(Fixture.calls.map(\.0) == ["coins"] && coin.coins.count == 2 && coin.userInfo?.userId == 88)
        Fixture.beforeResponse = { if $0 == "user" { throw RequestFailure.expected } }
        await coin.loadData()
        precondition(coin.errorMessage != nil && coin.coins.count == 2 && coin.userInfo?.userId == 88)
        Fixture.beforeResponse = nil
        Fixture.pageCount = 1

        Fixture.calls = []
        let collect = CollectViewModel()
        await collect.loadData()
        let rank = CoinRankListViewModel()
        await rank.loadData()
        let tree = TreeArticleListViewModel(tagId: 43, tagName: "体系")
        await tree.loadData()
        let search = SearchResultViewModel(keyword: "关键词")
        await search.refresh()
        let category = CategoryArticleListViewModel(categoryId: 42, source: ProjectAPIService.shared)
        await category.loadIfNeeded()
        await category.loadIfNeeded()
        precondition(Fixture.calls.map(\.0) == ["collect", "ranks", "tree", "search", "category"])
        precondition(Fixture.calls.map { $0.1! } == [0, 1, 0, 0, 1])
        precondition(!search.hasNoMoreData, "搜索继续遵循 over，不用 pageCount 推断末页")
        precondition(!collect.hasMoreData && !rank.hasMoreData && !tree.hasMoreData && !category.hasMoreData)
        precondition(category.isInitialized && tree.tagName == "体系")
        await search.loadMore()
        precondition(Fixture.calls.last?.0 == "search" && Fixture.calls.last?.1 == 1)
    }
}
