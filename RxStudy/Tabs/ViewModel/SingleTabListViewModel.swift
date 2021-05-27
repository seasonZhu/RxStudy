//
//  SingleTabListViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class SingleTabListViewModel: BaseViewModel, ViemModelInputs, ViemModelOutputs {

    private var pageNum: Int
    
    private let disposeBag: DisposeBag
        
    private let type: TagType
    
    private let tab: Tab
    
    init(type: TagType, tab: Tab, disposeBag: DisposeBag) {
        self.pageNum = type.pageNum
        self.type = type
        self.tab = tab
        self.disposeBag = disposeBag
    }
    
    /// outputs
    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    // inputs
    func loadData(actionType: ScrollViewActionType) {
        let refreshData: Driver<BaseModel<Page<Info>>>
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

private extension SingleTabListViewModel {
    func outputsRefreshStauts(actionType: ScrollViewActionType, baseModel: BaseModel<Page<Info>>) {
        var status: RefreshStatus
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
    
    
    func outputsDataSourceMerge(actionType: ScrollViewActionType, items: [Info]) {
        switch actionType {
        case .refresh:
            self.outputs.dataSource.accept(items)
        case .loadMore:
            self.outputs.dataSource.accept(self.outputs.dataSource.value + items)
        }
    }
}

//MARK:- 网络请求,普通列表数据
private extension SingleTabListViewModel {
    
    func refresh() -> Driver<BaseModel<Page<Info>>> {
        pageNum = type.pageNum
        return requestData(page: pageNum)
    }
  
    
    func loadMore() -> Driver<BaseModel<Page<Info>>> {
        pageNum = pageNum + 1
        return requestData(page: pageNum)
    }
    
    func requestData(page: Int) -> Driver<BaseModel<Page<Info>>> {
        guard let id = tab.id else {
            return Driver.empty()
        }
        let result: Driver<BaseModel<Page<Info>>>
        switch type {
        case .project:
            result = projectProvider.rx.request(ProjectService.tagList(id, page))
                .map(BaseModel<Page<Info>>.self)
                /// 转为Observable
                .asDriver(onErrorDriveWith: Driver.empty())
        case .publicNumber:
            result = publicNumberProvider.rx.request(PublicNumberService.tagList(id, page))
                .map(BaseModel<Page<Info>>.self)
                /// 转为Observable
                .asDriver(onErrorDriveWith: Driver.empty())
        case .tree:
            result = treeProvider.rx.request(TreeService.tagList(id, page))
                .map(BaseModel<Page<Info>>.self)
                /// 转为Observable
                .asDriver(onErrorDriveWith: Driver.empty())
        }
        
        return result
    }
}

