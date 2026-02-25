//
//  MineViewModel.swift
//  RxStudy - SwiftUIApp
//
//  我的页面 ViewModel
//  使用全局 @Observable AccountAPIService
//

import Foundation

// MARK: - 我的页面 ViewModel

@Observable
final class MineViewModel {
    // MARK: - 状态

    /// 加载状态
    private(set) var isLoading = false

    /// 错误信息
    private(set) var errorMessage: String?

    // MARK: - 私有属性

    private let accountService = AccountAPIService.shared

    // MARK: - 计算属性（直接引用全局状态）

    /// 是否已登录
    var isLoggedIn: Bool {
        return accountService.isLoggedIn
    }

    /// 用户信息
    var userInfo: UserInfoModel? {
        return accountService.userInfo
    }

    // MARK: - 公共方法

    /// 刷新用户信息（通常不需要，因为使用 @Observable 自动观察）
    func refreshUserInfo() {
        // @Observable 会自动通知视图更新
    }

    /// 退出登录
    func logout() async {
        isLoading = true

        do {
            try await accountService.logout()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            return
        }

        await MainActor.run {
            self.isLoading = false
        }
    }
}
