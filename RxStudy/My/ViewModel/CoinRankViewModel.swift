//
//  CoinRankViewModel.swift
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
class CoinRankViewModel: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {

    var pageNum: Int
    
    init(pageNum: Int = 1) {
        self.pageNum = pageNum
        super.init()
    }
    
    /// outputs
    /// 既是可监听序列也是观察者的数据源,里面封装的其实是BehaviorSubject
    let dataSource = BehaviorRelay<[CoinRank]>(value: [])
    
    /// 既是可监听序列也是观察者的状态枚举
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)
    
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

//MARK: - 网络请求
private extension CoinRankViewModel {
    
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }
  
    
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum, loadMoreFailureResetCurrentPageCallback: loadMoreFailureResetCurrentPage)
    }
    
    func requestData(page: Int, loadMoreFailureResetCurrentPageCallback: (() -> Void)? = nil) {
        myProvider.rx.request(MyService.coinRank(page))
            .map(BaseModel<Page<CoinRank>>.self)
            /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
            .compactMap{ $0.data }
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
                        } else {
                            /// 上拉做合并运算
                            self.dataSource.accept(self.dataSource.value + datas)
                        }
                    }
                    
                    if pageModel.isNoMoreData {
                        self.refreshSubject.onNext(.showNomoreData)
                    }
                case .failure:
                    loadMoreFailureResetCurrentPageCallback?()
                }
                
                /// 数据源为空才展示错误页面
                if self.dataSource.value.isEmpty {
                    self.processRxMoyaRequestEvent(event: event)
                }
                
            }
            .disposed(by: disposeBag)
    }
}

extension CoinRankViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = 1
        refreshSubject.onNext(.resetNomoreData)
    }
    
    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}
