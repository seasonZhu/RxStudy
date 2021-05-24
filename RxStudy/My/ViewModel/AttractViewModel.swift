//
//  AttractViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/24.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

protocol ViemModelInputs {

    /// 加载数据
    /// - Parameter isRefreshing: 是否为刷新,**true**就加入到头部,**false**加入尾部
    func loadData(_ isRefreshing: Bool)
}

protocol ViemModelOutPuts {
        
    /// 数据源数组
    var dataSource: BehaviorRelay<[CoinRank]> { get }
    
    /// 头部刷新状态
    var headerRefreshStatus: Driver<RefreshStatus> { set get }

    /// 尾部刷新状态
    var footerRefreshStatus: Driver<RefreshStatus> { set get }
}

protocol ViemModelType {
    var inputs: ViemModelInputs { get }
    
    var outputs: ViemModelOutPuts { get }
}

class AttractViewModel: ViemModelType, ViemModelInputs, ViemModelOutPuts {
    
    /// 协议
    var inputs: ViemModelInputs { return self }
    
    var outputs: ViemModelOutPuts { return self }
    
    /// outputs
    var dataSource = BehaviorRelay<[CoinRank]>(value: [])
    
    var headerRefreshStatus: Driver<RefreshStatus>
    
    var footerRefreshStatus: Driver<RefreshStatus>
        
    var pageNum = 1
    
    let disposeBag: DisposeBag
    
    init(disposeBag: DisposeBag) {
        self.disposeBag = disposeBag
        self.headerRefreshStatus = Driver.just(.header(.begainHeaderRefresh))
        self.footerRefreshStatus = Driver.just(.footer(.showFooter))
    }
    
    // inputs
    func loadData(_ isRefreshing: Bool) {
        if isRefreshing {
            let headerRefreshData = queryNewData()
                        
            headerRefreshData.do(onNext: { baseModel in
                
            }, afterNext: { baseModel in
                
                let status: RefreshStatus
                guard let curPage = baseModel.data?.curPage, let totalPage = baseModel.data?.total else {
                    status = .header(.endHeaderRefresh)
                    self.headerRefreshStatus = Driver.just(status)
                    return
                }
                
                if curPage < totalPage {
                    status = .header(.endHeaderRefresh)
                }else if curPage == totalPage {
                    status = .footer(.endFooterRefreshWithNoData)
                }else {
                    status = .header(.endHeaderRefresh)
                }
                
                self.headerRefreshStatus = Driver.just(status)
            }, onCompleted: {
                
            }, afterCompleted: {
                
            }, onSubscribe: {
                
            }, onSubscribed: {
                
            }, onDispose: {
                
            }).map{ $0.data?.datas?.map{ $0 }}
                /// 去掉其中为nil的值
                .compactMap{ $0 }
                .drive(onNext: { items in
                    self.outputs.dataSource.accept(items)
                })
                .disposed(by: disposeBag)
            
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
        }else {
            pageNum = pageNum + 1
            let footerRefreshData = queryNewData(page: pageNum)
            
            footerRefreshData
                .map{ $0.data?.datas?.map{ $0 }}
                .compactMap{ $0 }
                .drive(onNext: { items in
                    self.outputs.dataSource.accept(self.self.outputs.dataSource.value + items )
                })
                .disposed(by: disposeBag)
            
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
        }
        
    }

}


// MARK: 真实网路请求
private extension AttractViewModel {
    func queryNewData() -> Driver<BaseModel<Page<CoinRank>>> {
        let result = myProvider.rx.request(MyService.coinRank(1))
            .map(BaseModel<Page<CoinRank>>.self)
            /// 转为Observable
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return result
    }
  
    
    func queryNewData(page: Int) -> Driver<BaseModel<Page<CoinRank>>> {
        let result = myProvider.rx.request(MyService.coinRank(page))
            .map(BaseModel<Page<CoinRank>>.self)
            /// 转为Observable
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return result
    }
}
