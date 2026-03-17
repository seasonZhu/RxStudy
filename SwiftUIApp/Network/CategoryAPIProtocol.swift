//
//  CategoryAPIProtocol.swift
//  RxStudy - SwiftUIApp
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

// MARK: - 统一分类服务

/// 分类类型
enum CategoryType: CaseIterable {
    case project
    case publicNumber
    case tree

    var title: String {
        switch self {
        case .project: return "项目"
        case .publicNumber: return "公众号"
        case .tree: return "体系"
        }
    }
}

/// 统一分类服务
final class UnifiedCategoryService<T: CategoryItem> {
    private let type: CategoryType

    init(type: CategoryType) {
        self.type = type
    }

    /// 获取分类列表
    func fetchCategories() async throws -> [T] {
        switch type {
        case .project:
            let result = try await ProjectAPIService.shared.fetchTags()
            return result as! [T]
        case .publicNumber:
            let result = try await PublicNumberAPIService.shared.fetchTags()
            return result as! [T]
        case .tree:
            let result = try await TreeAPIService.shared.fetchTags()
            return result as! [T]
        }
    }

    /// 获取分类下的文章列表
    func fetchArticleList(id: Int, page: Int) async throws -> Page<InfoModel> {
        switch type {
        case .project:
            return try await ProjectAPIService.shared.fetchProjectList(tagId: id, page: page)
        case .publicNumber:
            return try await PublicNumberAPIService.shared.fetchArticleList(accountId: id, page: page)
        case .tree:
          return try await TreeAPIService.shared.fetchArticleList(tagId: id, page: page)
        }
    }
}

// MARK: - 让现有模型支持 CategoryItem

extension ProjectTagModel: CategoryItem {}
extension PublicNumberTagModel: CategoryItem {}
extension TreeTagModel: CategoryItem {}
