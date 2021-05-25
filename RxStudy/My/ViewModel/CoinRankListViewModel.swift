//
//  CoinRankListViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import MJRefresh

class CoinRankListViewModel {
        
    /// 表格数据序列
    let tableData = BehaviorRelay<[CoinRank]>(value: [])

    /// 头部刷新状态
    let headerRefreshStatus: Driver<RefreshStatus>

    /// 尾部刷新状态
    let footerRefreshStatus: Driver<RefreshStatus>

    /// ViewModel初始化（根据输入实现对应的输出）
    init(input: (headerRefresh: Driver<Void>, footerRefresh: Driver<Int>), disposeBag: DisposeBag) {
        
        /// 下拉结果序列
        let headerRefreshData = input.headerRefresh
            /// 初始化时会先自动加载一次数据
            .startWith(())
            /// 也可考虑使用flatMapFirst
            .flatMapLatest { _ in
                return myProvider.rx.request(MyService.coinRank(1))
                    .map(BaseModel<Page<CoinRank>>.self)
                    /// 转为Observable
                    .asDriver(onErrorDriveWith: Driver.empty())

            }
        
        /// 上拉结果序列
        let footerRefreshData = input.footerRefresh
            .flatMapLatest { pageNum in
                return myProvider.rx.request(MyService.coinRank(pageNum))
                    .map(BaseModel<Page<CoinRank>>.self)
                    /// 转为Observable
                    .asDriver(onErrorDriveWith: Driver.empty())
            }
         
        headerRefreshStatus = headerRefreshData.map{ $0.data }.compactMap{ $0 }.map({ page in
            guard let curPage = page.curPage, let totalPage = page.total else {
                return .header(.endHeaderRefresh)
            }
            
            if curPage < totalPage {
                return .header(.endHeaderRefresh)
            }else if curPage == totalPage {
                return .footer(.endFooterRefreshWithNoData)
            }else {
                return .header(.endHeaderRefresh)
            }
        })
        
        footerRefreshStatus = footerRefreshData.map{ $0.data }.compactMap{ $0 }.map({ page in
            guard let curPage = page.curPage, let totalPage = page.total else {
                return .footer(.endFooterRefresh)
            }
            
            if curPage < totalPage {
                return .footer(.showFooter)
            }else if curPage == totalPage {
                return .footer(.endFooterRefreshWithNoData)
            }else {
                return .footer(.hiddenFooter)
            }
        })
         
        /// 下拉刷新时，直接将查询到的结果替换原数据
        headerRefreshData
            /// 将BaseModel<Page<CoinRank>转为[CoinRank]
            .map{ $0.data?.datas?.map{ $0 }}
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            .drive(onNext: { items in
                self.tableData.accept(items)
            })
            .disposed(by: disposeBag)
         
        /// 上拉加载时，将查询到的结果拼接到原数据底部
        footerRefreshData
            .map{ $0.data?.datas?.map{ $0 }}
            .compactMap{ $0 }
            .drive(onNext: { items in
                self.tableData.accept(self.tableData.value + items )
            })
            .disposed(by: disposeBag)
        
    }
}

/// 这个是针对CoinRankListViewModel写的
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
}
