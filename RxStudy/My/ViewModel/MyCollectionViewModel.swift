//
//  MyCollectionViewModel.swift
//  RxStudy
//
//  Created by season on 2021/6/22.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class MyCollectionViewModel: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {

    var pageNum: Int

    init(pageNum: Int = 0) {
        self.pageNum = pageNum
        super.init()
    }
    
    /// outputs
    /// 既是可监听序列也是观察者的数据源,里面封装的其实是BehaviorSubject
    let dataSource: BehaviorRelay<[Info]> = BehaviorRelay(value: [])
    
    /// 既是可监听序列也是观察者的状态枚举
    let refreshSubject: BehaviorSubject<MJRefreshAction> = BehaviorSubject(value: .begainRefresh)
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            refresh()
        case .loadMore:
            loadMore()
        }
    }

}

//MARK:- 网络请求
private extension MyCollectionViewModel {
    
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }
  
    
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum)
    }
    
    func requestData(page: Int) {
        myProvider.rx.request(MyService.collectArticleList(page))
            .map(BaseModel<Page<Info>>.self)
            /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
            .map{ $0.data }
            /// 解包
            .compactMap { $0 }
            /// 转换操作
            .asObservable()
            .asSingle()
            /// 订阅
            .subscribe { event in
                
                /// 订阅事件
                /// 通过page的值判断是下拉还是上拉(可以用枚举),不管成功还是失败都结束刷新状态
                self.pageNum == 0 ? self.refreshSubject.onNext(.stopRefresh) : self.refreshSubject.onNext(.stopLoadmore)
                
                switch event {
                case .success(let pageModel):
                    self.networkError.onNext(nil)
                    /// 解包数据
                    if let datas = pageModel.datas {
                        /// 通过page的值判断是下拉还是上拉,做数据处理,这里为了方便写注释,没有使用三目运算符
                        if self.pageNum == 0 {
                            /// 下拉做赋值运算
                            self.dataSource.accept(datas)
                        }else {
                            /// 上拉做合并运算
                            self.dataSource.accept(self.dataSource.value + datas)
                        }
                    }
                    
                    if pageModel.isNoMoreData {
                        self.refreshSubject.onNext(.showNomoreData)
                    }
                case .error(let error):
                    guard let moyarror = error as? MoyaError else { return }
                    self.networkError.onNext(moyarror)
                }
            }.disposed(by: disposeBag)
    }
}

extension MyCollectionViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = 0
        refreshSubject.onNext(.resetNomoreData)
    }
}

