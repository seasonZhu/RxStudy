//
//  RxSwiftCoinRankListController.swift
//  RxStudy
//
//  Created by season on 2021/6/17.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import Moya
import MJRefresh

class RxSwiftCoinRankListController: BaseViewController {
    
    /// 懒加载tableView
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        
        /// 设置tableFooterView
        tableView.tableFooterView = UIView()
        
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        /// 创建vm
        let vm = RxSwiftCoinRankListViewModel()
        
        /// 设置头部刷新控件
        tableView.mj_header = MJRefreshNormalHeader()
        
        tableView.mj_header?.rx.refresh
            .subscribe(onNext:vm.refreshAction)
            .disposed(by: rx.disposeBag)
        
        /// 设置尾部刷新控件
        tableView.mj_footer = MJRefreshBackNormalFooter()
        
        tableView.mj_footer?.rx.refresh
            .subscribe(onNext:vm.loadMoreAction)
            .disposed(by: rx.disposeBag)
        
        /// cell删除
        tableView.rx.itemDeleted
            .subscribe(onNext: { indexPath in
                print("删除操作:\(indexPath.section)\(indexPath.row)")
            })
            .disposed(by: rx.disposeBag)
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        /// 数据源驱动
        vm.$dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, coinRank) in
            if let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className) {
                cell.textLabel?.text = coinRank.username
                cell.detailTextLabel?.text = coinRank.coinCount?.toString
                return cell
            } else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.className)
                cell.textLabel?.text = coinRank.username
                cell.detailTextLabel?.text = coinRank.coinCount?.toString
                return cell
            }
        }
        .disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        vm.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
    }

}

extension RxSwiftCoinRankListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}


class RxSwiftCoinRankListViewModel {
    /// 初始化page为1
    private var page: Int = 1
    
    @AFunction(input: "这是一个input")
    var aCallback: ((String) -> String) = { $0 + "season" }
    
    @FunctionFactory(function: { (num: Int) in num * 10 })
    var aaa = 1000
    
    @B @A
    var ba = 1
    
    /// 既是可监听序列也是观察者的数据源,里面封装的其实是BehaviorSubject
    /// RxBehaviorRelay是对BehaviorRelay通过@propertyWrapper的再封装,可以简化代码
    @RxBehaviorRelay<[CoinRank]>
    var dataSource = []
    
    /// 既是可监听序列也是观察者的状态枚举
    /// 当观察者对 BehaviorSubject 进行订阅时，它会将源 Observable 中最新的元素发送出来（如果不存在最新的元素，就发出默认元素）。然后将随后产生的元素发送出来
    /// 所以这里最先发出来的是默认操作,下拉刷新
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)
    
    /// 下拉刷新行为
    func refreshAction() {
        resetCurrentPageAndMjFooter()
        getCoinRank(page: page)
        
        let some = $aCallback
        print(some)
        
        print($aaa)
        aaa = 1110
        print($aaa)
        
        /// dataSource: [CoinRank]
        
        /// $dataSource: BehaviorRelay<[CoinRank]>
        
        /// _dataSource: RxBehaviorRelay<[CoinRank]>
        
        /// _dataSource.projectedValue 等价 $dataSource
        
        /// _dataSource.wrappedValue 等价 dataSource
        
        /// 未加工的原始值 other
        let origin = ba
        /// 类型StringFactory
        let type = _ba
        /// 加工后的值 100 * other的字符串
        let value = $ba
        
        /// 解包出A<T>类型
        let aType = _ba.wrappedValue
        
        /// 拿出A的wrappedValue
        let _ = aType.wrappedValue
        
        /// 拿出A的projectedValue
        let _ = aType.projectedValue
        
        print("origin:\(origin) type:\(type) value:\(value)")
    }
    
    /// 上拉加载更多行为
    func loadMoreAction() {
        page = page + 1
        getCoinRank(page: page)
    }
    
    /// 下拉的参数与状态重置行为
    private func resetCurrentPageAndMjFooter() {
        page = 1
        refreshSubject.onNext(.resetNomoreData)
    }
    
    /// 网络请求
    private func getCoinRank(page: Int) {
        provider.rx.request(MultiTarget(MyService.coinRank(page)))
            /// 转Model
            .map(BaseModel<Page<CoinRank>>.self)
            /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
            .map{ $0.data }
            /// 解包,这一步Single变成了Maybe
            .compactMap { $0 }
            /// 转换操作, Maybe要先转成Observable
            .asObservable()
            /// 才能再转成Single
            .asSingle()
            /// 订阅
            .subscribe { event in
                
                /// 订阅事件
                /// 通过page的值判断是下拉还是上拉(可以用枚举),不管成功还是失败都结束刷新状态
                page == 1 ? self.refreshSubject.onNext(.stopRefresh) : self.refreshSubject.onNext(.stopLoadmore)
                
                switch event {
                case .success(let pageModel):
                    /// 解包数据
                    if let datas = pageModel.datas {
                        /// 通过page的值判断是下拉还是上拉,做数据处理,这里为了方便写注释,没有使用三目运算符
                        if page == 1 {
                            /// 下拉做赋值运算
                            self.$dataSource.accept(datas)
                        } else {
                            /// 上拉做合并运算
                            self.$dataSource.accept(self.$dataSource.value + datas)
                        }
                    }
                    
                    if pageModel.isNoMoreData {
                        self.refreshSubject.onNext(.showNomoreData)
                    }
                case .failure:
                    /// error暂时不做处理
                    break
                }
            }.disposed(by: disposeBag)
    }
}

extension RxSwiftCoinRankListViewModel: HasDisposeBag {}

//MARK: -  Moya + Combine进行网络请求

import Combine
import CombineExt

class CombineCoinRankListViewModel {
    var cancellable: AnyCancellable?
    
    func getMyCoinList(page: Int) {
        cancellable = provider.requestPublisher(MultiTarget(MyService.coinRank((page))))
            .map(BaseModel<Page<CoinRank>>.self)
            .map{ $0.data }
            .compactMap { $0 }
            /// 将事件从 Publisher<Output, MoyaError> 转换为 Publisher<Event<Output, MoyaError>, Never> 从而避免了错误发生,进而整个订阅会被结束掉，后续新的通知并不会被转化为请求。
            //.materialize()
            .sink { completion in
                print(completion)
                guard case let .failure(error) = completion else { return }
                print(error)
            } receiveValue: { pageModel in
                print(pageModel)
            }

    }
    
    deinit {
        cancellable?.cancel()
    }
}

/// Future的简单实战
extension CombineCoinRankListViewModel {
    func requestMyCoinList(page: Int) -> Future<Page<CoinRank>, MoyaError> {
        
        Future { promise in
            self.cancellable = provider.requestPublisher(MultiTarget(MyService.coinRank((page))))
                .map(BaseModel<Page<CoinRank>>.self)
                .map{ $0.data }
                .compactMap { $0 }
                /// 将事件从 Publisher<Output, MoyaError> 转换为 Publisher<Event<Output, MoyaError>, Never> 从而避免了错误发生,进而整个订阅会被结束掉，后续新的通知并不会被转化为请求。
                //.materialize()
                .sink { completion in
                    print(completion)
                    guard case let .failure(error) = completion else { return }
                    promise(.failure(error))
                } receiveValue: { pageModel in
                    print(pageModel)
                    promise(.success(pageModel))
                }
        }
        
    }
    
    func futureTest() async {
        let vm = CombineCoinRankListViewModel()
        let response = vm.requestMyCoinList(page: 1)
        if #available(iOS 15.0, *) {
            do {
                let value = try await response.value
            } catch let moyaError {
                print(moyaError)
            }
        } else {
            
        }
    }
}
