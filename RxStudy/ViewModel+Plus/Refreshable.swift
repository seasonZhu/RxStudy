//
//  Refreshable.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import MJRefresh

protocol Refreshable {
    var refreshStauts: BehaviorRelay<RefreshStatus> { set get }
}

extension Refreshable {
    func headerRefreshStatusBind(to scrollView: UIScrollView) -> Disposable? {
        guard let header = scrollView.mj_header else {
            return nil
        }
        return refreshStauts.asDriver().drive(header.rx.refreshValue)
    }
    
    func footerRefreshStatusBind(to scrollView: UIScrollView) -> Disposable? {
        guard let footer = scrollView.mj_footer else {
            return nil
        }
        return refreshStauts.asDriver().drive(footer.rx.refreshValue)
    }
    
    func refreshStatusBind(to scrollView: UIScrollView) -> Disposable? {
        let d1 = headerRefreshStatusBind(to: scrollView)
        let d2 = footerRefreshStatusBind(to: scrollView)
        guard let D1 = d1, let D2 = d2 else {
            return nil
        }
        return Disposables.create(D1, D2)
        
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
                scrollView.mj_header?.endRefreshing()
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
                    scrollView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        })
      }
}
