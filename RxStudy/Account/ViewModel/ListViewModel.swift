//
//  ListViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/12/12.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

//MARK: -  列表服务
enum ListService {
    case coinRank(_ page: Int)
    case myCoinList(_ page: Int)
}

extension ListService: TargetType {
    var baseURL: URL {
        return URL(string: Api.baseUrl)!
    }
    
    var path: String {
        switch self {
        case .coinRank(let page):
            return Api.My.coinRank + page.toString + "/json"
        case .myCoinList(let page):
            return Api.My.myCoinList + page.toString + "/json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestParameters(parameters: Dictionary.empty, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? { loginHeader }
}

//MARK: -  Page协议
protocol PageProtocol {
    var page: Int? { get set }
}

//MARK: -  包含Page协议与Moya.TargetType协议的数据类
struct ListModel {
    var page: Int?
    var listService: ListService
}

extension ListModel: PageProtocol {}

extension ListModel: TargetType {
    var baseURL: URL {
        listService.baseURL
    }
    
    var path: String {
        if let page {
            switch listService {
            case .coinRank:
                return Api.My.coinRank + page.toString + "/json"
            case .myCoinList:
                return Api.My.myCoinList + page.toString + "/json"
            }
        } else {
            return listService.path
        }
    }
    
    var method: Moya.Method {
        listService.method
    }
    
    var task: Moya.Task {
        listService.task
    }
    
    var headers: [String : String]? {
        listService.headers
    }
    
    
}

//MARK: - 通用型的ListViewModel
class ListViewModel<M: Codable, T: PageProtocol&TargetType>: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {

    var pageNum: Int
    
    var target: T
    
    init(pageNum: Int = 1, target: T) {
        self.pageNum = pageNum
        self.target = target
        super.init()
    }
    
    /// outputs
    /// 既是可监听序列也是观察者的数据源,里面封装的其实是BehaviorSubject
    let dataSource = BehaviorRelay<[M]>(value: [])
    
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
private extension ListViewModel {
    
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
        target.page = page
        provider.rx.request(MultiTarget(target))
            .map(BaseModel<Page<M>>.self)
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

extension ListViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = 1
        refreshSubject.onNext(.resetNomoreData)
    }
    
    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}
