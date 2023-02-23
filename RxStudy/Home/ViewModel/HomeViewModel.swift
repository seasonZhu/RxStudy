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

class HomeViewModel: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {

    var pageNum: Int
    
    init(pageNum: Int = 1) {
        self.pageNum = pageNum
        super.init()
        mock()
    }
    
    /// outputs    
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    let banners = BehaviorRelay<[Banner]>(value: [])
    
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {        
        switch actionType {
        case .refresh:
            /// 合并请求
            Single.zip(bannerData(), topArticleData(), refresh())
                .subscribe { event in
                    /// 订阅事件
                    self.refreshSubject.onNext(.stopRefresh)
                    switch event {
                    case .success(let tuple):
                        /// 这里networkError我选用的是PublishSubject
                        /// 先说PublishSubject的功能,将对观察者发送订阅后产生的元素，而在订阅前发出的元素将不会发送给观察者。
                        /// 其实我的时候在想使用AsyncSubject是不是会更好一点
                        /// 为什么不管成功或者失败的时候都要对networkError进行onNext操作
                        /// 因为errorImage是和networkError进行绑定,比如先网络错误,然后网络好了,没有下面这句话,errorImage依旧盖在最上层,数据和列表虽然都好了,但是看不见
                        /// 这是我目前的处理方式,欢迎考虑是不是有更好的方式,其实通知当然是可以的
                        self.networkError.onNext(nil)
                        let items = tuple.0
                        let topInfos = tuple.1
                        let noramlPageModel = tuple.2
                        
                        /// 合并数组并赋值
                        if let normalInfos = noramlPageModel.data?.datas {
                            self.dataSource.accept(topInfos + normalInfos)
                        }

                        if let curPage = noramlPageModel.data?.curPage,
                           let pageCount = noramlPageModel.data?.pageCount {
                            /// 如果发现它们相等,说明是最后一个,改变foot而状态
                            if curPage == pageCount {
                                self.refreshSubject.onNext(.showNomoreData)
                            }
                        }
                        
                        self.banners.accept(items)
                    case .failure(let error):
                        guard let moyarror = error as? MoyaError else { return }
                        if self.dataSource.value.isEmpty {
                            self.networkError.onNext(moyarror)
                        }
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
                        
                        if pageModel.isNoMoreData {
                            self.refreshSubject.onNext(.showNomoreData)
                        }
                    case .failure:
                        self.loadMoreFailureResetCurrentPage()
                    }
                }
                .disposed(by: disposeBag)
        }
    }

}

//MARK: - 网络请求 
private extension HomeViewModel {
    
    /// 下拉刷新操作
    func refresh() -> Single<BaseModel<Page<Info>>> {
        resetCurrentPageAndMjFooter()
        return requestData(page: pageNum)
    }
  
    /// 上拉加载操作
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
    /// - Returns: Single<[Banner]>
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

extension HomeViewModel {
    /// 重置PageNum与上拉组件
    func resetCurrentPageAndMjFooter() {
        pageNum = 0
        refreshSubject.onNext(.resetNomoreData)
    }
    
    /// loadMore失败,回退pageNum
    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}

extension HomeViewModel {
    private func mock() {
        mockProvider.rx.request(.mourn)
            .map(BaseModel<Bool>.self)
            .map { $0.data }
            .compactMap { $0 }
            .asObservable()
            .asSingle()
            .subscribe { event in
                switch event {
                case .success(let value):
                    AccountManager.shared.isGrayModeRelay.accept(value)
                case .failure(_):
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}
