//
//  AccountAPIService.swift
//  RxStudy - SwiftUIStudy
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
        return URL(string: Api.baseUrl)!
    }

    var path: String {
        switch self {
        case .login:
            return "/" + Api.Account.login
        case .register:
            return "/" + Api.Account.register
        case .logout:
            return "/" + Api.Account.logout
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

    // HTTP 故障属于请求失败，不能按凭证拒绝处理。
    var validationType: ValidationType { .successCodes }

    var headers: [String: String]? {
        return nil
    }
}

// MARK: - 登录会话的 Observation 接入

@Observable
final class AccountAPIService {
    static let shared = AccountAPIService()

    @ObservationIgnored private let provider: MoyaProvider<AccountAPI>
    @ObservationIgnored private let session: AccountSession<UserInfoModel>
    private(set) var state: AccountSessionState<UserInfoModel> = .signedOut
    private(set) var errorMessage: String?

    var isLoggedIn: Bool { state.isAuthenticated }
    var isAuthenticating: Bool { state.isAuthenticating }
    var canRetryAutoLogin: Bool { !isLoggedIn && !isAuthenticating && session.savedCredentials != nil }
    var userInfo: UserInfoModel? { state.user }
    var cookieHeaderValue: String { session.cookieHeaderValue }

    init(provider: MoyaProvider<AccountAPI> = MoyaProvider<AccountAPI>(), defaults: UserDefaults = .standard) {
        self.provider = provider
        session = AccountSession(store: AccountCredentialStore(
            defaults: defaults, usernameKey: "swiftyuiapp_username", passwordKey: "swiftyuiapp_password"
        ))
    }

    /// 无凭证、已认证或已有认证请求时不重复发起自动登录；暂时失败可再次尝试。
    @MainActor
    func autoLoadUserInfo() async {
        guard !isLoggedIn, !isAuthenticating, let credentials = session.savedCredentials else { return }
        do {
            try await authenticate(credentials: credentials, target: .login(
                username: credentials.username, password: credentials.password
            ))
        } catch {
            // 当前请求的错误已由 authenticate 发布；旧请求和取消不覆盖新状态。
        }
    }

    @MainActor
    func login(username: String, password: String) async throws {
        try await authenticate(credentials: AccountCredentials(username: username, password: password),
                               target: .login(username: username, password: password))
    }

    @MainActor
    func register(username: String, password: String, repassword: String) async throws {
        try await authenticate(credentials: AccountCredentials(username: username, password: password),
                               target: .register(username: username, password: password, repassword: repassword))
    }

    @MainActor
    private func authenticate(credentials: AccountCredentials, target: AccountAPI) async throws {
        try _Concurrency.Task.checkCancellation()
        let revision = session.beginAuthentication()
        state = session.state
        errorMessage = nil
        do {
            let user = try await provider.requestDecoded(target, responseType: BaseModel<UserInfoModel>.self)
            try _Concurrency.Task.checkCancellation()
            guard session.authenticate(user: user, credentials: credentials, revision: revision) else {
                throw AccountAuthenticationError.superseded
            }
            state = session.state
        } catch {
            // 仅登录接口明确的凭证拒绝才删除同一组旧凭证，注册失败不删除。
            var rejected = false
            if case .login = target, case APIError.businessError(let code, _) = error {
                rejected = AccountAuthenticationError.credentialsRejected(code: code)
            }
            if session.failAuthentication(credentials: credentials, rejected: rejected, revision: revision) {
                state = session.state
                if !(error is CancellationError) { errorMessage = error.localizedDescription }
            }
            throw error
        }
    }

    @MainActor
    func logout() async {
        // 用户确认退出后立即清理本地会话；服务端请求失败也不恢复登录。
        session.signOut()
        let revision = session.revision
        state = session.state
        errorMessage = nil
        _ = try? await provider.requestDecoded(.logout, responseType: BaseModel<EmptyModel>.self)
        guard session.isCurrent(revision) else { return }
        state = session.state
    }
}
