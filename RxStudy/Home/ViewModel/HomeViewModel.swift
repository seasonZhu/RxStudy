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
            
    init(pageNum: Int = 1, disposeBag: DisposeBag) {
        self.pageNum = pageNum
        self.disposeBag = disposeBag
        super.init()
    }
    
    /// outputs    
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    let banners = BehaviorRelay<[Banner]>(value: [])
    
    let refreshSubject: BehaviorSubject<MJRefreshAction> = BehaviorSubject(value: .begainRefresh)
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {        
        switch actionType {
        case .refresh:
            /// 合并请求
            Single.zip(topArticleData(), refresh(), bannerData())
                .subscribe { event in
                    /// 订阅事件
                    self.refreshSubject.onNext(.stopRefresh)
                    switch event {
                    case .success(let tuple):
                        let topInfos = tuple.0
                        let noramlPageModel = tuple.1
                        let items = tuple.2
                        
                        /// 合并数组并赋值
                        if let normalInfos = noramlPageModel.data?.datas {
                            self.dataSource.accept(topInfos + normalInfos)
                        }

                        if let curPage = noramlPageModel.data?.curPage, let pageCount = noramlPageModel.data?.pageCount  {
                            /// 如果发现它们相等,说明是最后一个,改变foot而状态
                            if curPage == pageCount {
                                self.refreshSubject.onNext(.showNomoreData)
                            }
                        }
                        
                        self.banners.accept(items)
                    case .error(_):
                        break
                    }
                }
                .disposed(by: disposeBag)
        case .loadMore:
            loadMore()
                /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
                .map{ $0.data }
                /// 解包
                .compactMap { $0 }
                /// 转换操作
                .asObservable()
                .asSingle()/// 订阅
                .subscribe { event in
                    
                    /// 订阅事件
                    self.refreshSubject.onNext(.stopLoadmore)
                    
                    switch event {
                    case .success(let pageModel):
                        /// 解包数据
                        if let datas = pageModel.datas {
                            self.dataSource.accept(self.dataSource.value + datas)
                        }
                        
                        /// 解包curPage与pageCount
                        if let curPage = pageModel.curPage, let pageCount = pageModel.pageCount  {
                            /// 如果发现它们相等,说明是最后一个,改变foot而状态
                            if curPage == pageCount {
                                self.refreshSubject.onNext(.showNomoreData)
                            }
                        }
                    case .error(_):
                        /// error占时不做处理
                        break
                    }
                }.disposed(by: disposeBag)
        }
    }

}

//MARK:- 网络请求,普通列表数据
private extension HomeViewModel {
    
    func refresh() -> Single<BaseModel<Page<Info>>> {
        resetCurrentPageAndMjFooter()
        return requestData(page: pageNum)
    }
  
    
    func loadMore() -> Single<BaseModel<Page<Info>>> {
        pageNum = pageNum + 1
        return requestData(page: pageNum)
    }
    
    /// 普通列表数据
    /// - Parameter page: 页码
    /// - Returns: Single<BaseModel<Page<Info>>>
    func requestData(page: Int) -> Single<BaseModel<Page<Info>>> {
        let result = homeProvider.rx.request(HomeService.normalArticle(page))
            .map(BaseModel<Page<Info>>.self)
        
        return result
    }
    
    
    /// 置顶文章
    /// - Returns: Single<[Info]>
    func topArticleData() -> Single<[Info]> {
        let result = homeProvider.rx.request(HomeService.topArticle)
            .map(BaseModel<[Info]>.self)
            .map{ $0.data }
            .compactMap { $0 }
            .asObservable()
            .asSingle()
        
        return result
    }
    
    /// 轮播图
    /// - Returns: Single<BaseModel<[Banner]>>
    func bannerData() -> Single<[Banner]> {
        let result = homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
            .map{ $0.data }
            .compactMap { $0 }
            .asObservable()
            .asSingle()

        return result
    }
}

private extension HomeViewModel {
    private func resetCurrentPageAndMjFooter() {
        pageNum = 0
        refreshSubject.onNext(.resetNomoreData)
    }
}
