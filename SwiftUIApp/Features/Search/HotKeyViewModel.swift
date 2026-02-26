//
//  HotKeyViewModel.swift
//  RxStudy - SwiftUIApp
//
//  搜索热词 ViewModel
//

import Foundation

@Observable
class HotKeyViewModel {
    // MARK: - 状态

    /// 热词列表
    private(set) var hotKeys: [HotKeyModel] = []

    /// 是否正在加载
    private(set) var isLoading = false

    /// 错误信息
    private(set) var errorMessage: String?

    // MARK: - 依赖

    private let apiService: HomeAPIService

    // MARK: - 初始化

    init(apiService: HomeAPIService = .shared) {
        self.apiService = apiService
    }

    // MARK: - 方法

    /// 加载热词数据
    func loadHotKeys() {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil

            print("🔍 开始加载热词...")

            do {
                let keys = try await apiService.getHotKeys()
                print("✅ 成功加载 \(keys.count) 个热词")
                hotKeys = keys
            } catch {
                print("❌ 加载热词失败: \(error)")
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
