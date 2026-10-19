//
//  account-session-tests.swift
//  RxStudy - 登录会话隔离测试
//
//  Created by Codex on 2026/10/19.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import Moya

/// 只替换网络传输，使用真实 SwiftUI 会话、响应解码和账号实现。
@MainActor
final class PendingAccountRequests {
    struct Request {
        let target: AccountAPI
        var completion: ((Result<Response, MoyaError>) -> Void)?
    }
    var requests: [Request] = []

    func makeProvider() -> MoyaProvider<AccountAPI> {
        MoyaProvider(handler: { target, completion in
            DispatchQueue.main.async { self.requests.append(Request(target: target, completion: completion)) }
        })
    }

    func waitForCount(_ count: Int) async {
        while requests.count < count { await _Concurrency.Task.yield() }
    }

    func complete(_ index: Int, body: String) {
        let completion = requests[index].completion!
        requests[index].completion = nil
        completion(.success(Response(data: Data(body.utf8))))
    }

    func disconnect(_ index: Int) {
        let completion = requests[index].completion!
        requests[index].completion = nil
        completion(.failure(.underlying(URLError(.notConnectedToInternet))))
    }
}

@main
struct AccountSessionTests {
    static let credentials = AccountCredentials(username: "测试用户", password: "测试密码")
    static let success = "{\"errorCode\":0,\"data\":{\"id\":1,\"nickname\":\"用户甲\"}}"

    @MainActor
    static func main() async throws {
        let suite = "RxStudy.AccountSessionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        testSessionRules(defaults: defaults)
        try await testSwiftUISession(defaults: defaults)
        print("登录会话测试通过：凭证隔离、认证状态、业务拒绝、断网重试、退出与切号竞态、取消和注册")
    }

    static func testSessionRules(defaults: UserDefaults) {
        let store = AccountCredentialStore(defaults: defaults, usernameKey: "test_username", passwordKey: "test_password")
        store.save(credentials)
        let session = AccountSession<String>(store: store)
        precondition(!session.state.isAuthenticated && session.cookieHeaderValue.isEmpty)
        precondition(session.savedCredentials == credentials)
        let first = session.beginAuthentication()
        precondition(session.state.isAuthenticating && session.cookieHeaderValue.isEmpty)
        precondition(session.authenticate(user: "用户甲", credentials: credentials, revision: first))
        precondition(session.state.user == "用户甲" && !session.cookieHeaderValue.isEmpty)
        // 已完成的认证不能再次提交失败或成功。
        precondition(!session.failAuthentication(credentials: credentials, rejected: true, revision: first))
        precondition(!session.authenticate(user: "重复结果", credentials: credentials, revision: first))

        let transient = session.beginAuthentication()
        precondition(session.failAuthentication(credentials: credentials, rejected: false, revision: transient))
        precondition(session.savedCredentials == credentials && !session.state.isAuthenticated)
        let wrong = AccountCredentials(username: credentials.username, password: "另一个错误密码")
        let wrongRevision = session.beginAuthentication()
        precondition(session.failAuthentication(credentials: wrong, rejected: true, revision: wrongRevision))
        precondition(session.savedCredentials == credentials)
        let rejected = session.beginAuthentication()
        precondition(session.failAuthentication(credentials: credentials, rejected: true, revision: rejected))
        precondition(session.savedCredentials == nil)

        let old = session.beginAuthentication()
        session.signOut()
        precondition(!session.authenticate(user: "退出后晚到", credentials: credentials, revision: old))
        let oldAccount = session.beginAuthentication()
        let newAccount = session.beginAuthentication()
        precondition(session.authenticate(user: "用户乙", credentials: wrong, revision: newAccount))
        precondition(!session.failAuthentication(credentials: wrong, rejected: true, revision: oldAccount))
        precondition(session.state.user == "用户乙" && session.savedCredentials == wrong)
        precondition(!session.isCurrent(oldAccount), "旧积分响应必须被拒绝")
        session.signOut()
        precondition(session.cookieHeaderValue.isEmpty && session.state.user == nil)
    }

    @MainActor
    static func testSwiftUISession(defaults: UserDefaults) async throws {
        let store = AccountCredentialStore(defaults: defaults, usernameKey: "swiftyuiapp_username", passwordKey: "swiftyuiapp_password")
        store.save(credentials)
        // UIKit 仍沿用自己的旧逻辑；SwiftUI 不应触碰它的原有键。
        defaults.set("UIKit用户", forKey: "kUsername")
        defaults.set("UIKit密码", forKey: "kPassword")
        let network = PendingAccountRequests()
        let service = AccountAPIService(provider: network.makeProvider(), defaults: defaults)
        precondition(!service.isLoggedIn && service.userInfo == nil && service.cookieHeaderValue.isEmpty)

        let automatic = _Concurrency.Task { await service.autoLoadUserInfo() }
        await network.waitForCount(1)
        precondition(service.isAuthenticating && !service.isLoggedIn)
        await service.autoLoadUserInfo()
        precondition(network.requests.count == 1, "自动登录不能重复请求")
        network.disconnect(0)
        await automatic.value
        precondition(store.load() == credentials && !service.isLoggedIn && service.canRetryAutoLogin)
        precondition(service.errorMessage != nil)

        let retry = _Concurrency.Task { await service.autoLoadUserInfo() }
        await network.waitForCount(2)
        network.complete(1, body: success)
        await retry.value
        precondition(service.isLoggedIn && service.userInfo?.id == 1 && !service.cookieHeaderValue.isEmpty)
        await service.autoLoadUserInfo()
        precondition(network.requests.count == 2)

        let logout = _Concurrency.Task { await service.logout() }
        await network.waitForCount(3)
        precondition(!service.isLoggedIn && service.userInfo == nil && store.load() == nil)
        network.disconnect(2)
        await logout.value
        precondition(!service.isLoggedIn && store.load() == nil)
        precondition(defaults.string(forKey: "kUsername") == "UIKit用户")
        precondition(defaults.string(forKey: "kPassword") == "UIKit密码")

        let oldLogin = _Concurrency.Task { try await service.login(username: "旧用户", password: "旧密码") }
        await network.waitForCount(4)
        let exit = _Concurrency.Task { await service.logout() }
        await network.waitForCount(5)
        network.complete(3, body: success)
        do { try await oldLogin.value; preconditionFailure("退出后的登录不能成功") } catch {}
        precondition(!service.isLoggedIn && store.load() == nil)
        network.complete(4, body: "{\"errorCode\":0,\"data\":{}}")
        await exit.value

        let oldAccount = _Concurrency.Task { try await service.login(username: "甲", password: "甲密码") }
        await network.waitForCount(6)
        let newAccount = _Concurrency.Task { try await service.login(username: "乙", password: "乙密码") }
        await network.waitForCount(7)
        network.complete(6, body: "{\"errorCode\":0,\"data\":{\"id\":2}}")
        try await newAccount.value
        network.complete(5, body: "{\"errorCode\":-1,\"errorMsg\":\"凭证错误\"}")
        do { try await oldAccount.value; preconditionFailure("旧登录不能成功") } catch {}
        precondition(service.userInfo?.id == 2 && store.load()?.username == "乙" && service.errorMessage == nil)

        // 旧退出请求晚到不得清除新的登录。
        let lateExit = _Concurrency.Task { await service.logout() }
        await network.waitForCount(8)
        let loginAfterExit = _Concurrency.Task { try await service.login(username: "丙", password: "丙密码") }
        await network.waitForCount(9)
        network.complete(8, body: success)
        try await loginAfterExit.value
        network.complete(7, body: "{\"errorCode\":0,\"data\":{}}")
        await lateExit.value
        precondition(service.isLoggedIn && store.load()?.username == "丙")

        // 当前保存的凭证被明确拒绝时才清理。
        let rejected = _Concurrency.Task { try await service.login(username: "丙", password: "丙密码") }
        await network.waitForCount(10)
        network.complete(9, body: "{\"errorCode\":-1,\"errorMsg\":\"凭证错误\"}")
        do { try await rejected.value; preconditionFailure("业务拒绝不能发布成功") } catch {}
        precondition(!service.isLoggedIn && store.load() == nil)

        // 取消不提交认证，也不删除待恢复凭证。
        store.save(credentials)
        let cancelled = _Concurrency.Task { await service.autoLoadUserInfo() }
        await network.waitForCount(11)
        cancelled.cancel()
        network.complete(10, body: success)
        await cancelled.value
        precondition(!service.isLoggedIn && !service.isAuthenticating && store.load() == credentials)

        let invalid = _Concurrency.Task { await service.autoLoadUserInfo() }
        await network.waitForCount(12)
        network.complete(11, body: "{\"errorCode\":0,\"data\":null}")
        await invalid.value
        precondition(!service.isLoggedIn && store.load() == credentials)

        let malformed = _Concurrency.Task { await service.autoLoadUserInfo() }
        await network.waitForCount(13)
        network.complete(12, body: "不是有效 JSON")
        await malformed.value
        precondition(!service.isLoggedIn && store.load() == credentials)

        let failedRegistration = _Concurrency.Task {
            try await service.register(username: credentials.username, password: credentials.password, repassword: credentials.password)
        }
        await network.waitForCount(14)
        network.complete(13, body: "{\"errorCode\":-1,\"errorMsg\":\"用户名已存在\"}")
        do { try await failedRegistration.value; preconditionFailure("注册失败不能认证") } catch {}
        precondition(!service.isLoggedIn && store.load() == credentials, "注册拒绝不能清理登录凭证")

        let registration = _Concurrency.Task { try await service.register(username: "注册用户", password: "密码", repassword: "密码") }
        await network.waitForCount(15)
        network.complete(14, body: success)
        try await registration.value
        precondition(service.isLoggedIn && store.load()?.username == "注册用户")
    }
}
