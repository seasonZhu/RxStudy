//
//  ExBehaviorRelay.swift
//  RxStudy
//
//  Created by dy on 2023/2/1.
//  Copyright © 2023 season. All rights reserved.
//

import RxSwift

/// 其实忽略BehaviorRelay的初始value,使用skip(1)就可以了
public final class ExBehaviorRelay<Element>: ObservableType {
    
    /// 忽略初始值的订阅
    public var isIgnoreInitValue: Bool
    
    /// 忽略第一次accept
    private(set) var isIgnoreFirstAccept: Bool
    
    private let subject: BehaviorSubject<Element>

    public func accept(_ event: Element) {
        /// 如果是第一次accept
        if isIgnoreFirstAccept == true {
            isIgnoreFirstAccept = false
        } else {
            subject.onNext(event)
        }
    }

    public var value: Element {
        return try! subject.value()
    }

    public init(value: Element,
                isIgnoreInitValue: Bool = false,
                isIgnoreFirstAccept: Bool = false) {
        self.subject = BehaviorSubject(value: value)
        self.isIgnoreInitValue = isIgnoreInitValue
        self.isIgnoreFirstAccept = isIgnoreFirstAccept
    }

    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        /// 需要在observer中的具体实现中,将ExBehaviorRelay的isIgnoreInitValue进行判断与重新赋值
        subject.subscribe(observer)
    }
    
    public func asObservable() -> Observable<Element> {
        subject.asObservable()
    }
    
    func exSubscribe(onNext: ((Element) -> Void)? = nil) -> Disposable {
        subscribe(onNext: { [weak self] element in
            guard let self else { return }
            if self.isIgnoreInitValue {
                self.isIgnoreInitValue = false
                return
            }
            onNext?(element)
        })
    }
}

extension ObservableType {

    public func bind(to relays: ExBehaviorRelay<Element>...) -> Disposable {
        self.bind(to: relays)
    }


    public func bind(to relays: ExBehaviorRelay<Element?>...) -> Disposable {
        self.map { $0 as Element? }.bind(to: relays)
    }

    private func bind(to relays: [ExBehaviorRelay<Element>]) -> Disposable {
        subscribe { e in
            switch e {
            case let .next(element):
                relays.forEach {
                    $0.accept(element)
                }
            case .error:
                break
            case .completed:
                break
            }
        }
    }
}
