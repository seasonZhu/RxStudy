//
//  ObservableType+Extension.swift
//  RxStudy
//
//  Created by dy on 2022/11/10.
//  Copyright © 2022 season. All rights reserved.
//

import RxSwift
import RxSwiftExt

extension ObservableType {
    
    /// 仅订阅onNext
    /// - Parameter onNext: onNext
    /// - Returns: Disposable
    public func subscribeOnlyOnNext(_ onNext: ((Element) -> Void)? = nil) -> Disposable {
        subscribe(onNext: onNext, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
    /// weak修饰仅订阅onNext
    /// - Parameters:
    ///   - weak: 持有对象
    ///   - onNext: onNext
    /// - Returns: Disposable
    public func subscribeWeakifyOnNext<Object: AnyObject>(_ weak: Object, _ onNext: @escaping (Object) -> (Element) -> Void) -> Disposable {
        subscribeNext(weak: weak, onNext)
    }
}
