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
    /// 下拉或者上拉刷新操作
    var refreshAction: ControlEvent<Void> {
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
                
                header?.endRefreshing()
                
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
                    footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
}
