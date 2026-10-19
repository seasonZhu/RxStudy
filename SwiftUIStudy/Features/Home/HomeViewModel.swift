//
//  HomeViewModel.swift
//  RxStudy - SwiftUIStudy
//
//  首页 ViewModel
//  使用 @Observable + async/await
//

import Foundation

/// SwiftUI 最新数据模型完整解析：@Observable、@State、@Bindable（iOS17+ 全新范式）
/// https://juejin.cn/post/7578177007576268854

// MARK: - 首页 ViewModel

@MainActor
@Observable
final class HomeViewModel {
    private let pagination = PaginationState<InfoModel, [Banner]>(firstPage: 1)
    private let apiService = HomeAPIService.shared

    var articles: [InfoModel] { pagination.items }
    var banners: [Banner] { pagination.refreshData ?? [] }
    var isLoading: Bool { pagination.isLoading }
    var isLoadingMore: Bool { pagination.isLoadingMore }
    var errorMessage: String? { pagination.errorMessage }
    var hasMoreData: Bool { pagination.hasMoreData }

    func refresh() async {
        await pagination.refresh { page in
            // 三个请求继续并行，任一失败时保留上次完整数据。
            async let banners = apiService.fetchBanners()
            async let topArticles = apiService.fetchTopArticles()
            async let articles = apiService.fetchArticleList(page: page)
            let (bannerResult, topResult, pageResult) = try await (banners, topArticles, articles)
            return PaginationPage(items: topResult + (pageResult.datas ?? []),
                                  hasMoreData: pageResult.hasMore, refreshData: bannerResult)
        }
    }

    func loadMore() async {
        await pagination.loadMore(load: fetchPage)
    }

    func loadMoreIfNeeded(_ article: InfoModel) async {
        await pagination.loadMoreIfNeeded(article, identifiedBy: \.id, load: fetchPage)
    }

    private func fetchPage(_ page: Int) async throws -> PaginationPage<InfoModel, [Banner]> {
        PaginationPage(page: try await apiService.fetchArticleList(page: page))
    }
}
