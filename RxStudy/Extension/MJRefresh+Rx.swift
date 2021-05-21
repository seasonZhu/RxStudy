//
//  MJRefresh+Rx.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import MJRefresh
import RxSwift
import RxCocoa
 
/// 对MJRefreshComponent增加rx扩展
extension Reactive where Base: MJRefreshComponent {

    //正在刷新事件
    var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak control = self.base] observer  in
            if let control = control {
                control.refreshingBlock = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }

    //停止刷新
    var endRefreshing: Binder<Bool> {
        return Binder(base) { refresh, isEnd in
            if isEnd {
                refresh.endRefreshing()
            }
        }
    }
}

/*
private var kRxRefreshCommentKey: UInt8 = 0

public extension Reactive where Base: MJRefreshComponent {
      var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = lazyInstanceObservable(&kRxRefreshCommentKey) { () -> Observable<()> in
          Observable.create { [weak control = self.base] observer in
            if let control = control {
              control.refreshingBlock = {
                observer.on(.next(()))
              }
            } else {
              observer.on(.completed)
            }
            return Disposables.create()
          }
          .takeUntil(self.deallocated)
          .share(replay: 1)
        }
        return ControlEvent(events: source)
      }
      
      private func lazyInstanceObservable<T: AnyObject>(_ key: UnsafeRawPointer, createCachedObservable: () -> T) -> T {
        if let value = objc_getAssociatedObject(self.base, key) as? T {
          return value
        }
        let observable = createCachedObservable()
        objc_setAssociatedObject(self.base, key, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return observable
      }
}
*/

public enum RefreshStatus {
    case none, begainHeaderRefresh, endHeaderRefresh
    case hiddendFooter, showFooter, endFooterRefresh, endFooterRefreshWithNoData
}

public protocol Refreshable {
    var refreshStauts: BehaviorRelay<RefreshStatus> { get }
}

public extension Refreshable {
      func refreshStatusBind(to scrollView: UIScrollView) -> Disposable {
        return refreshStauts.subscribe(onNext: { [weak scrollV = scrollView] status in
          switch status {
              case .none:
                break
              case .begainHeaderRefresh:
                scrollV?.mj_header?.beginRefreshing()
              case .endHeaderRefresh:
                scrollV?.mj_header?.endRefreshing()
              case .hiddendFooter:
                scrollV?.mj_footer?.isHidden = true
              case .showFooter:
                scrollV?.mj_footer?.isHidden = false
              case .endFooterRefresh:
                scrollV?.mj_footer?.endRefreshing()
              case .endFooterRefreshWithNoData:
                scrollV?.mj_footer?.endRefreshingWithNoMoreData()
          }
        })
      }
}
