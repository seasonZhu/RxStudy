//
//  AccountSession.swift
//  RxStudy - SwiftUIStudy
//
//  Created by Codex on 2026/10/19.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation

struct AccountCredentials: Equatable {
    let username: String
    let password: String
}

/// 保留 SwiftUI 原有的 UserDefaults 键，凭证存在不代表认证成功。
struct AccountCredentialStore {
    let defaults: UserDefaults
    let usernameKey: String
    let passwordKey: String

    func load() -> AccountCredentials? {
        guard let username = defaults.string(forKey: usernameKey), !username.isEmpty,
              let password = defaults.string(forKey: passwordKey), !password.isEmpty else { return nil }
        return AccountCredentials(username: username, password: password)
    }

    func save(_ credentials: AccountCredentials) {
        defaults.set(credentials.username, forKey: usernameKey)
        defaults.set(credentials.password, forKey: passwordKey)
    }

    func clear() {
        defaults.removeObject(forKey: usernameKey)
        defaults.removeObject(forKey: passwordKey)
    }
}

enum AccountSessionState<User> {
    case signedOut
    case authenticating
    case authenticated(User, AccountCredentials)

    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }

    var isAuthenticating: Bool {
        if case .authenticating = self { return true }
        return false
    }

    var user: User? {
        if case .authenticated(let user, _) = self { return user }
        return nil
    }
}

/// 集中维护 SwiftUI 认证状态和请求代次；界面由 Observation 更新。
/// 锁同时保护后台请求读取 Cookie 和主线程更新会话的场景。
final class AccountSession<User> {
    private let store: AccountCredentialStore
    private let lock = NSLock()
    private var currentState: AccountSessionState<User> = .signedOut
    private var generation = 0

    init(store: AccountCredentialStore) {
        self.store = store
    }

    var state: AccountSessionState<User> { locked { currentState } }
    var revision: Int { locked { generation } }
    var savedCredentials: AccountCredentials? { locked { store.load() } }

    var cookieHeaderValue: String {
        locked {
            guard case .authenticated(_, let credentials) = currentState else { return "" }
            return AccountCookie.header(username: credentials.username, password: credentials.password)
        }
    }

    func isCurrent(_ revision: Int) -> Bool { locked { generation == revision } }

    @discardableResult
    func beginAuthentication() -> Int {
        locked {
            generation += 1
            currentState = .authenticating
            return generation
        }
    }

    @discardableResult
    func authenticate(user: User, credentials: AccountCredentials, revision: Int) -> Bool {
        locked {
            guard generation == revision, currentState.isAuthenticating else { return false }
            store.save(credentials)
            currentState = .authenticated(user, credentials)
            return true
        }
    }

    @discardableResult
    func failAuthentication(credentials: AccountCredentials, rejected: Bool, revision: Int) -> Bool {
        locked {
            guard generation == revision, currentState.isAuthenticating else { return false }
            // 新输入的错误密码不能删除以前保存的另一组凭证。
            if rejected, store.load() == credentials { store.clear() }
            currentState = .signedOut
            return true
        }
    }

    func signOut() {
        locked {
            generation += 1
            store.clear()
            currentState = .signedOut
        }
    }

    private func locked<Value>(_ action: () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        return action()
    }
}

/// 登录接口明确拒绝凭证与网络、解析失败分开处理。
enum AccountAuthenticationError: LocalizedError {
    case superseded

    /// 此编码仅在登录响应中表示凭证被拒绝，其他请求不能据此清除会话。
    static func credentialsRejected(code: Int?) -> Bool { code == -1 }

    var errorDescription: String? {
        switch self {
        case .superseded: return "登录请求已被新的会话操作替代"
        }
    }
}
