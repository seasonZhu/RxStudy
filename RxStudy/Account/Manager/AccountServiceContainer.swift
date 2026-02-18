//
//  AccountServiceContainer.swift
//  RxStudy
//
//  Created by code optimization on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation

/// 账户服务容器，用于依赖注入
///
/// 使用示例：
/// ```swift
/// // 获取当前实例（默认返回 AccountManager.shared）
/// let accountManager = AccountServiceContainer.current
///
/// // 单元测试时注入 Mock
/// AccountServiceContainer.set(mockAccountManager)
/// ```
final class AccountServiceContainer {

    // MARK: - Type Alias

    typealias AccountManagerType = AccountManageable & HasDisposeBag

    // MARK: - Properties

    /// 当前账户管理器实例
    private static var _current: AccountManagerType?

    /// 获取当前账户管理器
    /// 默认返回 AccountManager.shared，也可以通过 set() 方法替换为其他实现
    static var current: AccountManagerType {
        if let current = _current {
            return current
        }
        return AccountManager.shared
    }

    // MARK: - Public Methods

    /// 设置自定义账户管理器（用于测试）
    /// - Parameter manager: 自定义的账户管理器实现
    static func set(_ manager: AccountManagerType?) {
        _current = manager
    }

    /// 重置为默认实现
    static func reset() {
        _current = nil
    }

    // MARK: - Private

    private init() {}
}
