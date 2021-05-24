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


protocol Refreshable {
  var refreshStauts: BehaviorRelay<RefreshStatus> { get }
}

extension Refreshable {
  func refreshStatusBind(to scrollView: UIScrollView) -> Disposable {
    return refreshStauts.subscribe(onNext: { status in
        switch status {
        case .header(let headerStatus):
            switch headerStatus {
            case .none:
                scrollView.mj_header?.endRefreshing()
            case .begainHeaderRefresh:
                scrollView.mj_header?.beginRefreshing()
            case .endHeaderRefresh:
                scrollView.mj_header?.endRefreshing()
            }
        case .footer(let footerStatus):
            switch footerStatus {
            case .hiddenFooter:
                scrollView.mj_footer?.isHidden = true
                scrollView.mj_footer?.endRefreshing()
            case .showFooter:
                scrollView.mj_footer?.isHidden = false
                scrollView.mj_footer?.endRefreshing()
            case .endFooterRefresh:
                scrollView.mj_footer?.endRefreshing()
            case .endFooterRefreshWithNoData:
                scrollView.mj_header?.endRefreshing()
                scrollView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    })
  }
}
