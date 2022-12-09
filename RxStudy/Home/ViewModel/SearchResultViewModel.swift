//
//  SearchResultViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class SearchResultViewModel: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {
    /// 搜索结果的首页是从0开始的
    var pageNum: Int
    
    private let keyword: String
    
    init(pageNum: Int = 0, keyword: String) {
        self.pageNum = pageNum
        self.keyword = keyword
        super.init()
    }
    
    /// outputs
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
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

//MARK: - 网络请求,普通列表数据
private extension SearchResultViewModel {
    
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }
  
    
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum) {
            self.loadMoreFailureResetCurrentPage()
        }
    }
    
    func requestData(page: Int, resetCurrentPageNumCallback: (() -> Void)? = nil) {
        homeProvider.rx.request(HomeService.queryKeyword(keyword, page))
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
                    /// 解包数据
                    if let datas = pageModel.datas {
                        /// 通过page的值判断是下拉还是上拉,做数据处理,这里为了方便写注释,没有使用三目运算符
                        if self.pageNum == 0 {
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
                    resetCurrentPageNumCallback?()
                }
                self.processRxMoyaRequestEvent(event: event)
            }.disposed(by: disposeBag)
    }
}

extension SearchResultViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = 0
        refreshSubject.onNext(.resetNomoreData)
    }
    
    /// loadMore失败,回退pageNum
    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}
