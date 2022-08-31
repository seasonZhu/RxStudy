//
//  MJRefresh+RxSwift.swift
//  Demo
//
//  Created by Yuri on 2020/6/17.
//  Copyright © 2020 WSJC. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import MJRefresh

class Target: NSObject, Disposable {
    private var retainSelf: Target?
    
    override init() {
        super.init()
        self.retainSelf = self
    }
    
    func dispose() {
        self.retainSelf = nil
    }
}

private final class MJRefreshTarget<Component: MJRefreshComponent>: Target {
    typealias CallBack = (MJRefreshState) -> Void
    /// 组件
    weak var component: Component?
    /// 回调
    let callBack: CallBack
    
    init(_ component: Component, callBack: @escaping CallBack) {
        self.callBack = callBack
        self.component = component
        super.init()
        component.addObserver(self, forKeyPath: "state", options: [.new], context: nil)
    }
    
    override func dispose() {
        super.dispose()
        self.component?.removeObserver(self, forKeyPath: "state")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "state",
            let new = change?[NSKeyValueChangeKey.newKey] as? Int ,
            let state = MJRefreshState.init(rawValue: new) {
            self.callBack(state)
        }
    }
    
    deinit {
        debugLog("\(className) deinit")
    }
}

extension Reactive where Base: MJRefreshComponent {
    
    /// 刷新
    var refresh:ControlEvent<Void> {
        let source = state.filter({$0 == .refreshing})
            .map({_ in ()}).asObservable()
        return ControlEvent.init(events: source)
    }
    
    /// 刷新状态
    var state: ControlProperty<MJRefreshState> {
        let source: Observable<MJRefreshState> = Observable.create { [weak component = base] observer  in
            MainScheduler.ensureExecutingOnScheduler()
            guard let component = component else {
                observer.on(.completed)
                return Disposables.create()
            }
            observer.on(.next(component.state))
            let target = MJRefreshTarget(component) { (state) in
                observer.onNext(state)
            }
            return target
        }.take(until: deallocated)
        
        let bindingObserver = Binder<MJRefreshState>(base) { (component, state) in
            component.state = state
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
