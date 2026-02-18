//
//  BaseViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Moya

/// MVVM 架构中的 ViewModel 基类
///
/// 提供通用的 ViewModel 功能，包括：
/// - 输入/输出模式支持
/// - 网络请求错误处理
/// - 加载状态管理
/// - 自动重试机制
class BaseViewModel {

    // MARK: - Public Properties

    /// 输入接口前缀
    ///
    /// 用于 MVVM 模式中区分输入和输出，避免属性命名冲突
    /// 使用方式：`viewModel.inputs.someMethod()`
    var inputs: Self { self }

    /// 输出接口前缀
    ///
    /// 用于 MVVM 模式中区分输入和输出，方便绑定 UI
    /// 使用方式：`viewModel.outputs.someRelay.bind(...)`
    var outputs: Self { self }

    /// 网络请求错误流
    ///
    /// 发送 `nil` 表示请求成功，发送 `MoyaError` 表示请求失败
    /// ViewModel 可以根据此状态显示错误提示或错误页面
    let networkError = PublishSubject<MoyaError?>()

    /// 加载状态
    ///
    /// `true` 表示正在加载，`false` 表示加载完成
    /// 可用于绑定加载指示器的显示/隐藏
    let isLoading = BehaviorRelay<Bool>(value: false)

    /// 当前 ViewModel 的类名
    ///
    /// 用于调试和日志输出
    var className: String { String(describing: self) }

    // MARK: - Private Properties

    /// 网络请求最大重试次数
    let maxRetryCount = 3

    /// 是否正在重试
    private var isRetrying = false

    // MARK: - Lifecycle

    /// 析构函数，输出调试日志
    deinit {
        debugLog("\(classNameWithoutNamespace)被销毁了")
    }
}

// MARK: - HasDisposeBag

extension BaseViewModel: HasDisposeBag {}

// MARK: - TypeNameProtocol

extension BaseViewModel: TypeNameProtocol {}

// MARK: - Network Error Processing

extension BaseViewModel {

    /// 处理 RxSwift 的 Single 事件
    ///
    /// 将网络请求的结果转换为错误流，统一处理错误状态
    ///
    /// - Parameter event: `SingleEvent<Codable>` 事件
    ///
    /// # 示例
    /// ```swift
    /// provider.rx.request(service)
    ///     .subscribe(onSuccess: { model in
    ///         processRxMoyaRequestEvent(event: .success(model))
    ///     }, onError: { error in
    ///         processRxMoyaRequestEvent(event: .failure(error))
    ///     })
    /// ```
    func processRxMoyaRequestEvent(event: SingleEvent<some Codable>) {
        networkError.onNext(event.moyaError)
    }
}

// MARK: - Retry Logic

extension BaseViewModel {

    /// 网络请求重试逻辑
    ///
    /// 当网络请求失败时，自动进行延迟重试，提高请求成功率
    ///
    /// - Parameter errorObservable: 错误序列
    /// - Returns: 重试触发序列，返回重试次数
    ///
    /// # 重试规则
    /// - 只对超时和网络错误进行重试
    /// - 最大重试次数为 `maxRetryCount`（默认 3 次）
    /// - 每次重试之间有延迟（第 1 次延迟 1 秒，第 2 次 2 秒...）
    ///
    /// # 示例
    /// ```swift
    /// provider.rx.request(service)
    ///     .retry { errors in
    ///         return retryLogic(errorObservable: errors)
    ///     }
    /// ```
    func retryLogic(errorObservable: Observable<Error>) -> Observable<Int> {
        return errorObservable.enumerated().flatMap { [weak self] (attempt, error) -> Observable<Int> in
            guard let self = self else { return Observable.error(error) }

            // 超时和网络错误才重试
            if attempt < self.maxRetryCount && !self.isRetrying {
                self.isRetrying = true
                debugLog("第 \(attempt + 1) 次重试...")

                // 延迟重试，避免立即重试
                return Observable.timer(.seconds(attempt + 1), scheduler: MainScheduler.instance)
                    .do(onNext: { _ in
                        self.isRetrying = false
                    })
            }

            // 超过重试次数或不需要重试的错误，直接抛出
            return Observable.error(error)
        }
    }
}

// MARK: - SingleEvent Extension

extension SingleEvent {

    /// 提取 Moya 错误
    ///
    /// - Returns: 如果是 Moya 错误返回错误对象，否则返回 `nil`
    var moyaError: MoyaError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            guard let moyaError = error as? MoyaError else { return nil }
            return moyaError
        }
    }
}
