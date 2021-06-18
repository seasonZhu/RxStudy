//
//  CommonViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class CommonViewModel<M: Codable, S: TargetType>: BaseViewModel, ViemModelInputs, ViemModelOutputs {

    private var pageNum: Int
    
    private let disposeBag: DisposeBag
    
    private let provider: MoyaProvider<S>
        
    init(pageNum: Int = 1, disposeBag: DisposeBag) {
        self.pageNum = pageNum
        self.disposeBag = disposeBag
        provider = {
                let stubClosure = { (target: S) -> StubBehavior in
                    return .never
                }
                return MoyaProvider<S>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
        }()
        super.init()
    }
    
    /// outputs
    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    let dataSource = BehaviorRelay<[M]>(value: [])
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {
        let refreshData: Driver<BaseModel<Page<M>>>
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


    func outputsRefreshStauts(actionType: ScrollViewActionType, baseModel: BaseModel<Page<M>>) {
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
    
    
    func outputsDataSourceMerge(actionType: ScrollViewActionType, items: [M]) {
        switch actionType {
        case .refresh:
            self.outputs.dataSource.accept(items)
        case .loadMore:
            self.outputs.dataSource.accept(self.outputs.dataSource.value + items)
        }
    }
    
    func refresh() -> Driver<BaseModel<Page<M>>> {
        pageNum = 0
        return requestData(page: pageNum)
    }
  
    
    func loadMore() -> Driver<BaseModel<Page<M>>> {
        pageNum = pageNum + 1
        return requestData(page: pageNum)
    }
    
    func requestData(page: Int) -> Driver<BaseModel<Page<M>>> {        
        #warning("这里地方理论上是一个调用S的一个协议Api,但是S是个枚举,所以就跪了,这里需要换个思路,不使用enum?")
        let result = provider.rx.request(HomeService.normalArticle(page) as! S)
            .map(BaseModel<Page<M>>.self)
            /// 转为Observable
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return result
    }
}

