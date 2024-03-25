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

class SingleTabListViewModel: BaseViewModel, VMInputs, VMOutputs, PageVM2Setting {

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
    
    /// 这里初始化的值为.stopRefresh的目的是为了节约流量,因为这不是一个单一页面,TabsController上面嵌套了多个SingleTabListController
    /// 如果初始状态是.begainRefresh,那么会在一开始就在初始化后的页面中请求数据,可能用户根本不会看那么多栏目,消耗流量,而且消耗内存
    /// 所以优化的方式是看到哪个专栏,刷新哪个专栏,这个地方把BehaviorSubject换成PublishSubject,可以有更简洁的优化
//    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)
    
    let refreshSubject = PublishSubject<MJRefreshAction>()
    
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

// MARK: - 网络请求,普通列表数据
private extension SingleTabListViewModel {
    
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }
    
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum, loadMoreFailureResetCurrentPageCallback: loadMoreFailureResetCurrentPage)
    }
    
    func requestData(page: Int, loadMoreFailureResetCurrentPageCallback: (() -> Void)? = nil) {
        guard let id = tab.id else {
            return
        }
        let result: Single<Response>
        switch type {
        case .project:
            debugLog("请求:\(id)")
            result = projectProvider.rx.request(ProjectService.tagList(id, page))
        case .publicNumber:
            result = publicNumberProvider.rx.request(PublicNumberService.tagList(id, page))
        case .tree:
            result = treeProvider.rx.request(TreeService.tagList(id, page))
        case .course:
            result = provider.rx.request(MultiTarget(CourseService.tagList(id, page)))
        }
        
        result
            /// Response转Model
            .map(BaseModel<Page<Info>>.self)
            /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
            .compactMap { $0.data }
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
                    /// 解包数据
                    if let datas = pageModel.datas {
                        /// 通过page的值判断是下拉还是上拉,做数据处理,这里为了方便写注释,没有使用三目运算符
                        if self.pageNum == self.type.pageNum {
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

extension SingleTabListViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = type.pageNum
        refreshSubject.onNext(.resetNomoreData)
    }
    
    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}
