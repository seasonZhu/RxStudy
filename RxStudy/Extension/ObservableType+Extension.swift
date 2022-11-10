//
//  ObservableType+Extension.swift
//  RxStudy
//
//  Created by dy on 2022/11/10.
//  Copyright © 2022 season. All rights reserved.
//

import RxSwift

extension ObservableType {
    
    /// 仅订阅onNext
    /// - Parameter onNext: 序列
    /// - Returns: Disposable
    public func subscribeOnlyOnNext(onNext: ((Element) -> Void)? = nil) -> Disposable {
        subscribe(onNext: onNext, onError: nil, onCompleted: nil, onDisposed: nil)
    }
}
