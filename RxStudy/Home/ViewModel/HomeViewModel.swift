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

class HomeViewModel: BaseViewModel, ViemModelInputs, ViemModelOutputs, Refreshable {

    private var pageNum: Int
    
    private let disposeBag: DisposeBag
            
    init(pageNum: Int = 1, disposeBag: DisposeBag) {
        self.pageNum = pageNum
        self.disposeBag = disposeBag
        super.init()
    }
    
    /// outputs
    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    let banners = BehaviorRelay<[Banner]>(value: [])
    
    // inputs
    func loadData(actionType: ScrollViewActionType) {        
        switch actionType {
        case .refresh:
            /// 合并请求
            Single.zip(topArticleData(), refresh()).do(onSuccess: { _, normalPage in
                self.outputsRefreshStauts(actionType: actionType, baseModel: normalPage)
            }, onError: { error in
                self.refreshStauts.accept(.footer(.endFooterRefresh))
            }).map { top, normalPage -> [Info]? in
                guard let topInfos = top.data, let normalInfos = normalPage.data?.datas else {
                    return nil
                }
                return topInfos + normalInfos
            }.compactMap{ $0 }
            .subscribe(onSuccess: { items in
                self.outputsDataSourceMerge(actionType: actionType, items: items)
            }, onError: { error in
                
            })
            .disposed(by: disposeBag)
            
            /// 轮播图数据请求
            bannerData()
                .map{ $0.data }
                .compactMap{ $0 }
                .subscribe(onSuccess: { items in
                    self.banners.accept(items)
                }, onError: { error in
                    
                })
                .disposed(by: disposeBag)

            
        case .loadMore:
            loadMore().do(onSuccess: { baseModel in
                self.outputsRefreshStauts(actionType: actionType, baseModel: baseModel)
            }, onError: { error in
                self.refreshStauts.accept(.footer(.endFooterRefresh))
            }).map{ $0.data?.datas?.map{ $0 }}
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            .subscribe(onSuccess: { items in
                self.outputsDataSourceMerge(actionType: actionType, items: items)
            }, onError: { error in
                
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
    
    func refresh() -> Single<BaseModel<Page<Info>>> {
        pageNum = 0
        return requestData(page: pageNum)
    }
  
    
    func loadMore() -> Single<BaseModel<Page<Info>>> {
        pageNum = pageNum + 1
        return requestData(page: pageNum)
    }
    
    func requestData(page: Int) -> Single<BaseModel<Page<Info>>> {
        let result = homeProvider.rx.request(HomeService.normalArticle(page))
            .map(BaseModel<Page<Info>>.self)
        
        return result
    }
}

//MARK:- 网络请求,top列表数据
extension HomeViewModel {
    func topArticleData() -> Single<BaseModel<[Info]>> {
        let result = homeProvider.rx.request(HomeService.topArticle)
            .map(BaseModel<[Info]>.self)
        
        return result
    }
    
    
    func bannerData() -> Single<BaseModel<[Banner]>> {
        let result = homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
        
        return result
    }
}
