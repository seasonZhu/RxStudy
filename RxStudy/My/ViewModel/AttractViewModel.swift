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

enum ScrollViewActionType {
    case refresh
    case loadMore
}

protocol ViemModelInputs {
    /// 加载数据
    /// - Parameter actionType: 操作行为
    func loadData(actionType: ScrollViewActionType)
}

protocol ViemModelOutputs {
        
    /// 数据源数组
    var dataSource: BehaviorRelay<[CoinRank]> { get }
}

protocol ViemModelType: ViemModelInputs {
    
    var inputs: ViemModelInputs { get }
    
    var outputs: ViemModelOutputs { get }
}

class AttractViewModel: ViemModelInputs, ViemModelOutputs, Refreshable {

    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    private var pageNum: Int
    
    private let disposeBag: DisposeBag
    
    init(pageNum: Int = 1, disposeBag: DisposeBag) {
        self.pageNum = pageNum
        self.disposeBag = disposeBag
    }
    
    /// outputs
    var dataSource = BehaviorRelay<[CoinRank]>(value: [])
    
    // inputs
    func loadData(actionType: ScrollViewActionType) {
        if actionType == .refresh {
            let headerRefreshData = refresh()
                        
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
            let footerRefreshData = loadMore()
            
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
                    self.outputs.dataSource.accept(self.outputs.dataSource.value + items )
                })
                .disposed(by: disposeBag)
        }
        
    }

}


// MARK: 真实网路请求
private extension AttractViewModel {
    func refresh() -> Driver<BaseModel<Page<CoinRank>>> {
        pageNum = 0
        return requestData(page: pageNum)
    }
  
    
    func loadMore() -> Driver<BaseModel<Page<CoinRank>>> {
        pageNum = pageNum + 1
        return requestData(page: pageNum)
    }
    
    func requestData(page: Int) -> Driver<BaseModel<Page<CoinRank>>> {
        let result = myProvider.rx.request(MyService.coinRank(page))
            .map(BaseModel<Page<CoinRank>>.self)
            /// 转为Observable
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return result
    }
}

extension AttractViewModel: ViemModelType {
    /// 协议
    var inputs: ViemModelInputs { return self }

    var outputs: ViemModelOutputs { return self }
}
