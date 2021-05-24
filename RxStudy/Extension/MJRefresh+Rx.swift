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

    /// header的刷新事件
    var headerRefreshing: ControlEvent<Void> {
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
    
    /// footer的刷新事件
    var footerRefreshing: (Int) -> ControlEvent<Int> {
        return { page in
            let source: Observable<Int> = Observable.create {
                [weak control = self.base] observer  in
                if let control = control {
                    control.refreshingBlock = {
                        observer.on(.next(page))
                    }
                }
                return Disposables.create()
            }
            return ControlEvent(events: source)
        }
    }

    /// 刷新值
    var refreshValue: Binder<RefreshStatus> {
        return Binder(base) { refresh, status in
            switch status {
            case .header(let headerStatus):
                let header = refresh as? MJRefreshHeader
                switch headerStatus {
                case .none:
                    header?.endRefreshing()
                case .begainHeaderRefresh:
                    header?.beginRefreshing()
                case .endHeaderRefresh:
                    header?.endRefreshing()
                }
            case .footer(let footerStatus):
                let header = refresh as? MJRefreshHeader
                let footer = refresh as? MJRefreshFooter
                switch footerStatus {
                case .hiddenFooter:
                    footer?.isHidden = true
                    footer?.endRefreshing()
                case .showFooter:
                    footer?.isHidden = false
                    footer?.endRefreshing()
                case .endFooterRefresh:
                    footer?.endRefreshing()
                case .endFooterRefreshWithNoData:
                    header?.endRefreshing()
                    footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
}

enum RefreshStatus {
    
    case header(HeaderStatus)
    case footer(FooterStatus)
    
    enum HeaderStatus {
        case none, begainHeaderRefresh, endHeaderRefresh
    }
    
    enum FooterStatus {
        case hiddenFooter, showFooter, endFooterRefresh, endFooterRefreshWithNoData
    }
}
