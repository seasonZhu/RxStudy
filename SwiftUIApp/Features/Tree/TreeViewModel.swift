//
//  TreeViewModel.swift
//  RxStudy - SwiftUIApp
//
//  体系页面 ViewModel
//  使用 @Observable + async/await
//

import Foundation

// MARK: - 体系 ViewModel

@Observable
final class TreeViewModel {
    // MARK: - 状态

    /// 体系分类列表
    private(set) var tags: [TreeTagModel] = []

    /// 加载状态
    private(set) var isLoading = false

    /// 错误信息
    private(set) var errorMessage: String?

    // MARK: - 私有属性

    private let apiService = TreeAPIService.shared

    // MARK: - 初始化

    init() {
        Task {
            await loadTags()
        }
    }

    // MARK: - 公共方法

    /// 加载体系分类
    func loadTags() async {
        isLoading = true
        errorMessage = nil

        do {
            let tags = try await apiService.fetchTags()

            await MainActor.run {
                self.tags = tags
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
