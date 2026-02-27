//
//  AccountAPIService.swift
//  RxStudy - SwiftUIApp
//
//  账号 API 服务 + 全局登录状态管理
//  使用 @Observable 实现全局状态管理
//

import Foundation
import Moya

// MARK: - 账号 API 定义

enum AccountAPI {
    case login(username: String, password: String)
    case register(username: String, password: String, repassword: String)
    case logout
}

extension AccountAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://www.wanandroid.com")!
    }

    var path: String {
        switch self {
        case .login:
            return "/user/login"
        case .register:
            return "/user/register"
        case .logout:
            return "/user/logout/json"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login, .register:
            return .post
        case .logout:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .login(let username, let password):
            return .requestParameters(parameters: ["username": username, "password": password], encoding: URLEncoding.default)
        case .register(let username, let password, let repassword):
            return .requestParameters(parameters: [
                "username": username,
                "password": password,
                "repassword": repassword
            ], encoding: URLEncoding.default)
        case .logout:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return nil
    }
}

// MARK: - 全局账号管理器（@Observable 单例）

@Observable
final class AccountAPIService {
    static let shared = AccountAPIService()

    private let provider = MoyaProvider<AccountAPI>()

    // MARK: - 状态

    /// 是否已登录
    private(set) var isLoggedIn = false

    /// 用户信息
    private(set) var userInfo: UserInfoModel?

    /// 用户名（用于自动登录）
    private var username: String? {
        didSet {
            UserDefaults.standard.set(username, forKey: "swiftyuiapp_username")
        }
    }

    /// 密码（用于自动登录）
    private var password: String? {
        didSet {
            UserDefaults.standard.set(password, forKey: "swiftyuiapp_password")
        }
    }

    // MARK: - 初始化

    private init() {
        // 从 UserDefaults 加载保存的用户名密码
        self.username = UserDefaults.standard.string(forKey: "swiftyuiapp_username")
        self.password = UserDefaults.standard.string(forKey: "swiftyuiapp_password")

        // 如果有保存的用户名密码，标记为已登录状态
        if let username = self.username, let password = self.password, !username.isEmpty, !password.isEmpty {
            self.isLoggedIn = true
        }
    }

    // MARK: - 自动加载用户信息

    /// 尝试自动加载用户信息（由 View 调用）
    func autoLoadUserInfo() async {
        guard isLoggedIn,
              let username = self.username,
              let password = self.password else {
            return
        }

        do {
            let userInfo = try await provider.requestDecoded(
                .login(username: username, password: password),
                responseType: StandardResponse<UserInfoModel>.self
            )

            await MainActor.run {
                self.userInfo = userInfo
            }
        } catch {
            // 自动登录失败，清除凭证
            await MainActor.run {
                self.isLoggedIn = false
                self.username = nil
                self.password = nil
                UserDefaults.standard.removeObject(forKey: "swiftyuiapp_username")
                UserDefaults.standard.removeObject(forKey: "swiftyuiapp_password")
            }
        }
    }

    // MARK: - Cookie 获取

    /// 获取 Cookie 请求头（格式：loginUserName=xxx;loginUserPassword=xxx）
    var cookieHeaderValue: String {
        guard let username = self.username, let password = self.password else {
            return ""
        }
        return "loginUserName=\(username);loginUserPassword=\(password)"
    }

    // MARK: - 公共 API

    /// 登录
    func login(username: String, password: String) async throws {
        let userInfo = try await provider.requestDecoded(
            .login(username: username, password: password),
            responseType: StandardResponse<UserInfoModel>.self
        )

        // 保存登录信息
        await MainActor.run {
            self.userInfo = userInfo
            self.username = username
            self.password = password
            self.isLoggedIn = true
        }
    }

    /// 注册
    func register(username: String, password: String, repassword: String) async throws {
        let userInfo = try await provider.requestDecoded(
            .register(username: username, password: password, repassword: repassword),
            responseType: StandardResponse<UserInfoModel>.self
        )

        // 保存登录信息
        await MainActor.run {
            self.userInfo = userInfo
            self.username = username
            self.password = password
            self.isLoggedIn = true
        }
    }

    /// 退出登录
    func logout() async {
        // 调用退出接口（忽略返回值）
        let _ = try? await provider.requestDecoded(.logout, responseType: StandardResponse<EmptyResponse>.self)

        // 清除本地状态
        await MainActor.run {
            self.userInfo = nil
            self.username = nil
            self.password = nil
            self.isLoggedIn = false

            // 清除 UserDefaults
            UserDefaults.standard.removeObject(forKey: "swiftyuiapp_username")
            UserDefaults.standard.removeObject(forKey: "swiftyuiapp_password")
        }
    }
}
