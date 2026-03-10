//
//  LoginViewModel.swift
//  RxStudy - SwiftUIApp
//
//  登录/注册 ViewModel
//  处理登录注册业务逻辑
//

import Foundation

// MARK: - 登录表单模型

@Observable
class LoginFormData {
    var username: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isRegisterMode: Bool = false

    var isValid: Bool {
        if isRegisterMode {
            return !username.isEmpty && !password.isEmpty && password == confirmPassword
        } else {
            return !username.isEmpty && !password.isEmpty
        }
    }

    /// 重置表单
    func reset() {
        username = ""
        password = ""
        confirmPassword = ""
        isRegisterMode = false
    }
}

// MARK: - 登录状态

enum LoginState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

// MARK: - 登录 ViewModel

@Observable
final class LoginViewModel {
    // MARK: - 公开属性

    var formData = LoginFormData()
    private(set) var state: LoginState = .idle

    // MARK: - 私有属性

    private let accountService: AccountAPIService

    // MARK: - 初始化

    init(accountService: AccountAPIService = .shared) {
        self.accountService = accountService
    }

    // MARK: - 公开方法

    /// 提交登录/注册
    @MainActor
    func submit() async -> Bool {
        state = .loading

        do {
            if formData.isRegisterMode {
                // 注册
                _ = try await accountService.register(
                    username: formData.username,
                    password: formData.password,
                    repassword: formData.confirmPassword
                )
            } else {
                // 登录
                _ = try await accountService.login(
                    username: formData.username,
                    password: formData.password
                )
            }

            state = .success
            return true
        } catch {
            state = .error(error.localizedDescription)
            return false
        }
    }

    /// 重置状态
    func resetState() {
        state = .idle
        formData.reset()
    }
}
