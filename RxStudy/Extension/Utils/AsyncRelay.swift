//
//  AsyncRelay.swift
//  RxStudy
//
//  Created by dy on 2024/4/29.
//  Copyright © 2024 season. All rights reserved.
//

import RxSwift

/// 其实就是对AsyncSubject的封装
final public class AsyncRelay<Element>: ObservableType {
    private let subject: AsyncSubject<Element>
    
    // Accepts `event` and emits it to subscribers
    public func accept(_ event: Element) {
        self.subject.onNext(event)
    }
    
    /// Initializes with internal empty subject.
    public init() {
        self.subject = AsyncSubject()
    }

    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        self.subject.subscribe(observer)
    }
    
    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        self.subject.asObservable()
    }
    
    /// Convert to an `Infallible`
    ///
    /// - returns: `Infallible<Element>`
    public func asInfallible() -> Infallible<Element> {
        asInfallible(onErrorFallbackTo: .empty())
    }
}
