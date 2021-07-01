//
//  MyCoinViewModel.swift
//  RxStudy
//
//  Created by season on 2021/6/22.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class MyCoinViewModel: BaseViewModel, ViemModelInputs, ViemModelOutputs {

    private var pageNum: Int
    
    init(pageNum: Int = 1) {
        self.pageNum = pageNum
        super.init()
    }
    
    /// outputs
    /// 既是可监听序列也是观察者的数据源,里面封装的其实是BehaviorSubject
    let dataSource: BehaviorRelay<[MyHistoryCoin]> = BehaviorRelay(value: [])
    
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
private extension MyCoinViewModel {
    
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }
  
    
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum)
    }
    
    func requestData(page: Int) {
        myProvider.rx.request(MyService.myCoinList(page))
            .map(BaseModel<Page<MyHistoryCoin>>.self)
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
                self.pageNum == 1 ? self.refreshSubject.onNext(.stopRefresh) : self.refreshSubject.onNext(.stopLoadmore)
                
                switch event {
                case .success(let pageModel):
                    /// 解包数据
                    if let datas = pageModel.datas {
                        /// 通过page的值判断是下拉还是上拉,做数据处理,这里为了方便写注释,没有使用三目运算符
                        if self.pageNum == 1 {
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
                case .error(_):
                    /// error占时不做处理
                    break
                }
            }.disposed(by: disposeBag)
    }
}

private extension MyCoinViewModel {
    private func resetCurrentPageAndMjFooter() {
        pageNum = 1
        refreshSubject.onNext(.resetNomoreData)
    }
}

