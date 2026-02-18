//
//  AccountManageable.swift
//  RxStudy
//
//  Created by dy on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// 账户管理协议
///
/// 定义了应用中所有账户管理相关的接口，支持依赖注入和单元测试。
///
/// # 讨论
/// 这个协议从 `AccountManager` 中抽离出来，与 GLM-4.7 进行了多轮对话后，
/// 发现优化效果可能并不理想，目前主要考虑作为接口抽象存在。
///
/// # 使用方式
/// ```swift
/// // 方式一：直接使用单例
/// AccountManager.shared.autoLogin()
///
/// // 方式二：通过协议访问
/// let manager: AccountManageable = AccountServiceContainer.current
/// manager.autoLogin()
///
/// // 方式三：依赖注入（便于测试）
/// class MyViewModel {
///     private let accountManager: AccountManageable
///     init(accountManager: AccountManageable = AccountServiceContainer.current) {
///         self.accountManager = accountManager
///     }
/// }
/// ```
protocol AccountManageable {

    // MARK: - Reactive Properties

    /// 网络可达状态
    ///
    /// `true` 表示网络可用，`false` 表示网络不可用
    var networkIsReachableRelay: BehaviorRelay<Bool> { get }

    /// 用户登录状态
    ///
    /// `true` 表示已登录，`false` 表示未登录
    var isLoginRelay: BehaviorRelay<Bool> { get }

    /// 用户积分信息
    ///
    /// 登录成功后会获取用户的积分信息
    var myCoinRelay: BehaviorRelay<CoinRank?> { get }

    /// 未读消息数量
    ///
    /// 表示用户当前的未读消息数量
    var myUnreadMessageCountRelay: BehaviorRelay<Int> { get }

    /// 灰色悼念模式
    ///
    /// `true` 表示启用灰色模式，`false` 表示正常模式
    var isGrayModeRelay: BehaviorRelay<Bool> { get }

    /// 列表布局模式
    ///
    /// 控制列表 Cell 的布局方式（如折行、列表等）
    var layoutType: LayoutType { get set }

    // MARK: - User Properties

    /// 用户名
    ///
    /// 存储在 UserDefaults 中，用于自动登录
    var username: String? { get set }

    /// 密码
    ///
    /// ⚠️ **安全警告**：密码以明文形式存储在 UserDefaults 中
    ///
    /// TODO: 考虑使用 Keychain 存储敏感信息，或使用 KeychainAccess 等安全库
    var password: String? { get set }

    /// 账户信息模型
    ///
    /// 包含用户的详细信息，如用户 ID、昵称、收藏 ID 等
    var accountInfo: AccountInfo? { get }

    /// Cookie 请求头字符串
    ///
    /// 格式：`loginUserName=xxx;loginUserPassword=xxx`
    ///
    /// 用于需要登录状态的 API 请求
    var cookieHeaderValue: String { get }

    // MARK: - Login/Logout Methods

    /// 自动登录
    ///
    /// 如果本地存储了用户名和密码，会自动调用登录接口
    ///
    /// # 流程
    /// 1. 检查本地存储的用户名和密码
    /// 2. 如果存在，调用 `optimizeLogin` 进行登录
    /// 3. 登录成功后更新登录状态
    func autoLogin()

    /// 登录
    ///
    /// 调用登录接口进行用户认证
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - showLoading: 是否显示加载提示，默认为 `true`
    func login(username: String, password: String, showLoading: Bool)

    /// 优化登录（串行请求）
    ///
    /// 先调用登录接口，成功后再串行调用获取积分和未读消息接口
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - showLoading: 是否显示加载提示，默认为 `true`
    ///   - completion: 完成回调，在所有请求完成后执行
    ///
    /// # 请求流程
    /// 1. 调用登录接口（会自动重试 2 次）
    /// 2. 登录成功后，并行请求：
    ///    - 用户积分接口
    ///    - 未读消息数量接口
    /// 3. 所有请求完成后执行 `completion`
    func optimizeLogin(
        username: String,
        password: String,
        showLoading: Bool,
        completion: (() -> Void)?
    )

    /// 保存登录信息
    ///
    /// 登录成功后保存用户信息和凭证
    ///
    /// - Parameters:
    ///   - info: 账户信息模型
    ///   - username: 用户名
    ///   - password: 密码
    ///
    /// # 保存内容
    /// - 更新 `accountInfo`
    /// - 更新 `username` 和 `password`（存入 UserDefaults）
    /// - 更新 `isLoginRelay` 为 `true`
    /// - 如果使用 Flutter，会通知 Flutter 侧
    func saveLoginUsernameAndPassword(
        info: AccountInfo?,
        username: String,
        password: String
    )

    /// 保存 Flutter 登录信息
    ///
    /// 从 Flutter 侧登录成功后保存登录信息
    ///
    /// - Parameters:
    ///   - info: 账户信息模型
    ///   - username: 用户名
    ///   - password: 密码
    func saveFlutterLoginUsernameAndPassword(
        info: AccountInfo?,
        username: String,
        password: String
    )

    /// 登出
    ///
    /// 清除所有登录信息并重置状态
    ///
    /// # 清理内容
    /// - 重置 `isLoginRelay` 为 `false`
    /// - 清空 `accountInfo`
    /// - 清空 `myCoinRelay`
    /// - 重置 `myUnreadMessageCountRelay` 为 `0`
    /// - 删除 UserDefaults 中的用户名和密码
    func clearAccountInfo()

    /// 更新收藏的 ID 列表
    ///
    /// 当用户收藏或取消收藏文章时，更新收藏 ID 列表
    ///
    /// - Parameter collectIds: 收藏的文章 ID 数组
    func updateCollectIds(_ collectIds: [Int])
}
