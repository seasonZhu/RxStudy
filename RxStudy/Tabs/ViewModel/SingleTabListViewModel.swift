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

class SingleTabListViewModel: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {

    var pageNum: Int
        
    private let type: TagType
    
    private let tab: Tab
    
    init(type: TagType, tab: Tab) {
        self.pageNum = type.pageNum
        self.type = type
        self.tab = tab
        super.init()
    }
    
    /// outputs    
    let dataSource = BehaviorRelay<[Info]>(value: [])
    
    let refreshSubject: BehaviorSubject<MJRefreshAction> = BehaviorSubject(value: .stopRefresh)
    
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

//MARK:- 网络请求,普通列表数据
private extension SingleTabListViewModel {
    
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }
  
    
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum)
    }
    
    func requestData(page: Int) {
        guard let id = tab.id else {
            return
        }
        let result: Single<BaseModel<Page<Info>>>
        switch type {
        case .project:
            print("请求:\(id)")
            result = projectProvider.rx.request(ProjectService.tagList(id, page))
                .map(BaseModel<Page<Info>>.self)
        case .publicNumber:
            result = publicNumberProvider.rx.request(PublicNumberService.tagList(id, page))
                .map(BaseModel<Page<Info>>.self)
        case .tree:
            result = treeProvider.rx.request(TreeService.tagList(id, page))
                .map(BaseModel<Page<Info>>.self)
        }
        
        result
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
                self.pageNum == self.type.pageNum ? self.refreshSubject.onNext(.stopRefresh) : self.refreshSubject.onNext(.stopLoadmore)
                
                switch event {
                case .success(let pageModel):
                    self.networkError.onNext(nil)
                    /// 解包数据
                    if let datas = pageModel.datas {
                        /// 通过page的值判断是下拉还是上拉,做数据处理,这里为了方便写注释,没有使用三目运算符
                        if self.pageNum == self.type.pageNum {
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

extension SingleTabListViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = type.pageNum
        refreshSubject.onNext(.resetNomoreData)
    }
}

extension Optional: Error {
    static var wrappedError: String?  { return nil }
}
