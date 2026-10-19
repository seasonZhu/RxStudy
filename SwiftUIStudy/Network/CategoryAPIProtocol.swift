//
//  CategoryAPIProtocol.swift
//  RxStudy - SwiftUIStudy
//
//  分类 API 协议
//  统一不同分类页面（项目、公众号、体系）的 API 调用
//

import Foundation

// MARK: - 分类项协议

protocol CategoryItem: Identifiable & Hashable {
    var id: Int? { get }
    var name: String? { get }
}

// MARK: - 类型安全的分类数据来源

/// 分类模型、标题与请求由同一个来源绑定，调用者无需维护额外的分类枚举。
protocol CategorySource {
    associatedtype Item: CategoryItem

    var title: String { get }
    func fetchCategories() async throws -> [Item]
    func fetchArticleList(id: Int, page: Int) async throws -> Page<InfoModel>
}

extension ProjectAPIService: CategorySource {
    var title: String { "项目" }

    func fetchCategories() async throws -> [ProjectTagModel] {
        try await fetchTags()
    }

    func fetchArticleList(id: Int, page: Int) async throws -> Page<InfoModel> {
        try await fetchProjectList(tagId: id, page: page)
    }
}

extension PublicNumberAPIService: CategorySource {
    var title: String { "公众号" }

    func fetchCategories() async throws -> [PublicNumberTagModel] {
        try await fetchTags()
    }

    func fetchArticleList(id: Int, page: Int) async throws -> Page<InfoModel> {
        try await fetchArticleList(accountId: id, page: page)
    }
}

extension TreeAPIService: CategorySource {
    var title: String { "体系" }

    func fetchCategories() async throws -> [TreeTagModel] {
        try await fetchTags()
    }

    func fetchArticleList(id: Int, page: Int) async throws -> Page<InfoModel> {
        try await fetchArticleList(tagId: id, page: page)
    }
}

// MARK: - 让现有模型支持 CategoryItem

extension ProjectTagModel: CategoryItem {}
extension PublicNumberTagModel: CategoryItem {}
extension TreeTagModel: CategoryItem {}
