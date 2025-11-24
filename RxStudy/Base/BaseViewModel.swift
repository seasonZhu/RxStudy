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
import NSObject_Rx
import Moya

class BaseViewModel {
    /// inputs修饰前缀,这里没有使用rx这种命名空间的思路,并不是我不会,而是不想增加编写和理解成本
    var inputs: Self { self }

    /// outputs修饰前缀
    var outputs: Self { self }
    
    /// 网络请求的Moya错误,为空说明走到success里面了,有值的话,并不在乎值是什么,直接显示error画面
    let networkError = PublishSubject<MoyaError?>()
    
    /// 网络状态展示相关
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    /// 模型名称
    var className: String { String(describing: self) }
    
    /// 重试次数设置
    let maxRetryCount = 3
        
    /// 是否正在重试
    private var isRetrying = false
    
    deinit {
        debugLog("\(classNameWithoutNamespace)被销毁了")
    }
}

extension BaseViewModel: HasDisposeBag {}

extension BaseViewModel: TypeNameProtocol {}

extension BaseViewModel {
    
    /// 在ViewModel的基类中封装针对网络请求错误的方法,避免在子类中写重复代码
    /// - Parameter event: SingleEvent
    func processRxMoyaRequestEvent(event: SingleEvent<some Codable>) {
        networkError.onNext(event.moyaError)
    }
}

extension BaseViewModel {
    /// 重试逻辑
    /// - Parameter errorObservable: 错误序列
    /// - Returns: 重试触发序列
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

extension SingleEvent {
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
