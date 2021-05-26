//
//  HomeViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class HomeViewModel: BaseViewModel, ViemModelInputs, ViemModelOutputs {

    private var pageNum: Int
    
    private let disposeBag: DisposeBag
    
    private let provider: MoyaProvider<HomeService>
        
    init(pageNum: Int = 1, disposeBag: DisposeBag) {
        self.pageNum = pageNum
        self.disposeBag = disposeBag
        provider = {
                let stubClosure = { (target: HomeService) -> StubBehavior in
                    return .never
                }
                return MoyaProvider<HomeService>(stubClosure: stubClosure, plugins: [RequestLoadingPlugin()])
        }()
    }
    
    /// outputs
    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    // inputs
    func loadData(actionType: ScrollViewActionType) {        
        switch actionType {
        case .refresh:
            /// 合并请求
            Driver.zip(topArticleData(), refresh()).do { _, normalPage in
                self.outputsRefreshStauts(actionType: actionType, baseModel: normalPage)
            }.map { top, normalPage -> [Info]? in
                guard let topInfos = top.data, let normalInfos = normalPage.data?.datas else {
                    return nil
                }
                return topInfos + normalInfos
            }.compactMap{ $0 }
            .drive(onNext: { items in
                self.outputsDataSourceMerge(actionType: actionType, items: items)
            })
            .disposed(by: disposeBag)
        case .loadMore:
            loadMore().do { baseModel in
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

}

private extension HomeViewModel {
    func outputsRefreshStauts(actionType: ScrollViewActionType, baseModel: BaseModel<Page<Info>>) {
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
private extension HomeViewModel {
    
    func refresh() -> Driver<BaseModel<Page<Info>>> {
        pageNum = 0
        return requestData(page: pageNum)
    }
  
    
    func loadMore() -> Driver<BaseModel<Page<Info>>> {
        pageNum = pageNum + 1
        return requestData(page: pageNum)
    }
    
    func requestData(page: Int) -> Driver<BaseModel<Page<Info>>> {
        let result = provider.rx.request(HomeService.normalArticle(page))
            .map(BaseModel<Page<Info>>.self)
            /// 转为Observable
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return result
    }
}

//MARK:- 网络请求,top列表数据
extension HomeViewModel {
    func topArticleData() -> Driver<BaseModel<[Info]>> {
        let result = provider.rx.request(HomeService.topArticle)
            .map(BaseModel<[Info]>.self)
            /// 转为Observable
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return result
    }
}
