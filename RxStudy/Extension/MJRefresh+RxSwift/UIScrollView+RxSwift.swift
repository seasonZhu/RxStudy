//
//  UIScrollView+RxSwift.swift
//  WS-Designated_Driver
//
//  Created by Yuri on 2020/6/18.
//  Copyright © 2020 WSJC. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import MJRefresh

/// 供ViewModel使用
enum MJRefreshAction {
    /// 开始刷新
    case begainRefresh
    /// 停止刷新
    case stopRefresh
    /// 开始加载更多
    case begainLoadmore
    /// 停止加载更多
    case stopLoadmore
    /// 显示无更多数据
    case showNomoreData
    /// 重置无更多数据
    case resetNomoreData
}

//MARK: - Refresh
extension Reactive where Base: UIScrollView {
    
    /// 执行的操作类型
    var refreshAction: Binder<MJRefreshAction> {
        
        return Binder(base) { (target, action) in
            
            switch action {
            case .begainRefresh:
                if let header =  target.mj_header {
                    header.beginRefreshing()
                }
            case .stopRefresh:
                if let header =  target.mj_header {
                    header.endRefreshing()
                }
            case .begainLoadmore:
                if let footer =  target.mj_footer {
                    footer.beginRefreshing()
                }
            case .stopLoadmore:
                if let footer =  target.mj_footer {
                    footer.endRefreshing()
                }
            case .showNomoreData:
                if let footer =  target.mj_footer {
                    footer.endRefreshingWithNoMoreData()
                }
            case .resetNomoreData:
                if let footer =  target.mj_footer {
                    footer.resetNoMoreData()
                }
            }
        }
    }
}
