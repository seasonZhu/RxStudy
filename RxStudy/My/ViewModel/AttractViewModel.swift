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
}

protocol ViemModelType {
    var inputs: ViemModelInputs { get }
    
    var outputs: ViemModelOutPuts { get }
}

class AttractViewModel: ViemModelType, ViemModelInputs, ViemModelOutPuts, Refreshable {
    
    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    var pageNum: Int
    
    /// 协议
    var inputs: ViemModelInputs { return self }
    
    var outputs: ViemModelOutPuts { return self }
    
    /// outputs
    var dataSource = BehaviorRelay<[CoinRank]>(value: [])
    
    let disposeBag: DisposeBag
    
    init(pageNum: Int = 1, disposeBag: DisposeBag) {
        self.pageNum = pageNum
        self.disposeBag = disposeBag
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
                    self.refreshStauts.accept(status)
                    return
                }
                
                if curPage < totalPage {
                    status = .header(.endHeaderRefresh)
                }else if curPage == totalPage {
                    status = .footer(.endFooterRefreshWithNoData)
                }else {
                    status = .header(.endHeaderRefresh)
                }
                
                self.refreshStauts.accept(status)
                
            }).map{ $0.data?.datas?.map{ $0 }}
                /// 去掉其中为nil的值
                .compactMap{ $0 }
                .drive(onNext: { items in
                    self.outputs.dataSource.accept(items)
                })
                .disposed(by: disposeBag)
        }else {
            pageNum = pageNum + 1
            
            let footerRefreshData = queryNewData(page: pageNum)
            
            footerRefreshData.do(onNext: { baseModel in
                
            }, afterNext: { baseModel in
                
                let status: RefreshStatus
                guard let curPage = baseModel.data?.curPage, let totalPage = baseModel.data?.total else {
                    status = .footer(.endFooterRefresh)
                    self.refreshStauts.accept(status)
                    return
                }
                
                if curPage < totalPage {
                    status = .footer(.showFooter)
                }else if curPage == totalPage {
                    status = .footer(.endFooterRefreshWithNoData)
                }else {
                    status = .footer(.hiddenFooter)
                }
                
                self.refreshStauts.accept(status)
                
            })
                .map{ $0.data?.datas?.map{ $0 }}
                .compactMap{ $0 }
                .drive(onNext: { items in
                    self.outputs.dataSource.accept(self.self.outputs.dataSource.value + items )
                })
                .disposed(by: disposeBag)
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
