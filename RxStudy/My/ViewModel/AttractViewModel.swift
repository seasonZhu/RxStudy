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
import Moya

/// 进击的ViewModel
class AttractViewModel: BaseViewModel, ViemModelInputs, ViemModelOutputs {

    private var pageNum: Int
    
    private let disposeBag: DisposeBag
    
    private let provider: MoyaProvider<MyService>
    
    init(pageNum: Int = 1, disposeBag: DisposeBag) {
        self.pageNum = pageNum
        self.disposeBag = disposeBag
        provider = {
                let stubClosure = { (target: MyService) -> StubBehavior in
                    return .never
                }
                return MoyaProvider<MyService>(stubClosure: stubClosure)
        }()
    }
    
    /// outputs
    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    var dataSource = BehaviorRelay<[CoinRank]>(value: [])
    
    // inputs
    func loadData(actionType: ScrollViewActionType) {
        let refreshData: Driver<BaseModel<Page<CoinRank>>>
        switch actionType {
        case .refresh:
            refreshData = refresh()
        case .loadMore:
            refreshData = loadMore()
        }
        
        refreshData.do { baseModel in
            self.outputsRefreshStauts(actionType: actionType, baseModel: baseModel)
        }.map{ $0.data?.datas?.map{ $0 }}
        /// 去掉其中为nil的值
        .compactMap{ $0 }
        .drive(onNext: { items in
            self.outputsDataSourceMerge(actionType: actionType, items: items)
        })
        .disposed(by: disposeBag)
    }

}

private extension AttractViewModel {
    func outputsRefreshStauts(actionType: ScrollViewActionType, baseModel: BaseModel<Page<CoinRank>>) {
        let status: RefreshStatus
        guard let curPage = baseModel.data?.curPage, let totalPage = baseModel.data?.total else {
            status = .footer(.endFooterRefresh)
            self.refreshStauts.accept(status)
            return
        }
        
        switch actionType {
        case .refresh:
            if curPage < totalPage {
                status = .header(.endHeaderRefresh)
            }else if curPage == totalPage {
                status = .footer(.endFooterRefreshWithNoData)
            }else {
                status = .header(.endHeaderRefresh)
            }
        case .loadMore:
            if curPage < totalPage {
                status = .footer(.showFooter)
            }else if curPage == totalPage {
                status = .footer(.endFooterRefreshWithNoData)
            }else {
                status = .footer(.hiddenFooter)
            }
        }
        self.refreshStauts.accept(status)
    }
    
    
    func outputsDataSourceMerge(actionType: ScrollViewActionType, items: [CoinRank]) {
        switch actionType {
        case .refresh:
            self.outputs.dataSource.accept(items)
        case .loadMore:
            self.outputs.dataSource.accept(self.outputs.dataSource.value + items)
        }
    }
}

//MARK:- 网络请求
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
        let result = provider.rx.request(MyService.coinRank(page))
            .map(BaseModel<Page<CoinRank>>.self)
            /// 转为Observable
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return result
    }
}
