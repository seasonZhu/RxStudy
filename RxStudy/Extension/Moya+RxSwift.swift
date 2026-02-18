//
//  Moya+RxSwift.swift
//  RxStudy
//
//  Created for Moya 15.0 + RxSwift 6.x compatibility
//  纯 RxSwift 实现，不依赖 ReactiveSwift
//

import Foundation
import Moya
import RxSwift
import RxCocoa

// MARK: - RxMoyaProxy - RxSwift 风格的请求代理
public struct RxMoyaProxy<Base: MoyaProviderType> {
    fileprivate let provider: Base

    public func request(_ target: Base.Target) -> Single<Moya.Response> {
        return Single.create { single in
            // 创建 CancellableToken
            let cancellableToken = self.provider.request(target, callbackQueue: .main, progress: nil) { result in
                switch result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    single(.failure(error))
                }
            }

            return Disposables.create {
                cancellableToken.cancel()
            }
        }
    }
}

// MARK: - MoyaProviderType RxSwift Extension
// 为所有遵循 MoyaProviderType 的类型添加 .rx 属性
extension MoyaProviderType {
    public var rx: RxMoyaProxy<Self> {
        return RxMoyaProxy(provider: self)
    }
}
