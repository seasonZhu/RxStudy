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
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    /// 既是可监听序列也是观察者的状态枚举
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)
    
    /// inputs
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            refresh()
        case .loadMore:
            /// 目前解决的方法是在这里做拦截保存不进行操作,还没有找到好的方法
            if let value = try? refreshSubject.value(),
               value == .showNomoreData {
                return
            }
            loadMore()
        }
    }

}

//MARK: - 网络请求
private extension MyCollectionViewModel {
    
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
    
    func requestData(page: Int, loadMoreFailureResetCurrentPageCallback: (() -> Void)? = nil) {
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
                    break
                }
                
                /// 数据源为空才展示错误页面
                if self.dataSource.value.isEmpty {
                    self.processRxMoyaRequestEvent(event: event)
                }
                
            }.disposed(by: disposeBag)
    }
}

extension MyCollectionViewModel {
    func unCollectAction(indexPath: IndexPath) {
        let index = indexPath.row
        var datas = dataSource.value
        
        guard datas.count >= index else {
            return
        }
        
        let model = datas[index]
        
        guard let collectId = model.originId else {
            return
        }
        
        myProvider.rx.request(MyService.unCollectArticle(collectId))
            .map(BaseModel<String>.self)
            .map { $0.isSuccess }
            .subscribe { event in
                switch event {
                case .success(let isSuccess):
                    
                    guard isSuccess else {
                        return
                    }
                    
                    datas.remove(at: index)
                    self.dataSource.accept(datas)
                    
                    guard var collectIds = AccountManager.shared.accountInfo?.collectIds else {
                        return
                    }
                    
                    if collectIds.contains(collectId), let index = collectIds.firstIndex(of: collectId) {
                        collectIds.remove(at: index)
                    }
                    
                    AccountManager.shared.updateCollectIds(collectIds)
                case .failure:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}

extension MyCollectionViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = 0
        refreshSubject.onNext(.resetNomoreData)
    }
    
    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}

