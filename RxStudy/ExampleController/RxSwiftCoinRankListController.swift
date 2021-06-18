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
    
    /// 初始化page为1
    private var page: Int = 1
    
    /// 既是可监听序列也是观察者的数据源,里面封装的其实是BehaviorSubject
    private var dataSource: BehaviorRelay<[CoinRank]> = BehaviorRelay(value: [])
    
    /// 既是可监听序列也是观察者的状态枚举
    private var refreshSubject: BehaviorSubject<MJRefreshAction> = BehaviorSubject(value: .begainRefresh)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        
        /// 设置tableFooterView
        tableView.tableFooterView = UIView()
        
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        /// 设置头部刷新控件
        tableView.mj_header = MJRefreshNormalHeader()
        
        tableView.mj_header?.rx.refresh
            .subscribe { [weak self] _ in
                self?.refreshAction()
        }.disposed(by: rx.disposeBag)
        
        /// 设置尾部刷新控件
        tableView.mj_footer = MJRefreshBackNormalFooter()
        
        tableView.mj_footer?.rx.refresh
            .subscribe { [weak self] _ in
                self?.loadMoreAction()
        }.disposed(by: rx.disposeBag)
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        /// 数据源驱动
        dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, coinRank) in
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
                cell.textLabel?.text = coinRank.username
                cell.detailTextLabel?.text = coinRank.coinCount?.toString
                return cell
            }else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                cell.textLabel?.text = coinRank.username
                cell.detailTextLabel?.text = coinRank.coinCount?.toString
                return cell
            }
        }
        .disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
    }

}

extension RxSwiftCoinRankListController {
    /// 下拉刷新行为
    private func refreshAction() {
        resetCurrentPageAndMjFooter()
        getCoinRank(page: page)
    }
    
    /// 上拉加载更多行为
    private func loadMoreAction() {
        page = page + 1
        getCoinRank(page: page)
    }
    
    /// 下拉的参数与状态重置行为
    private func resetCurrentPageAndMjFooter() {
        page = 1
        tableView.mj_footer?.isHidden = false
        refreshSubject.onNext(.resetNomoreData)
    }
    
    /// 网络请求
    private func getCoinRank(page: Int) {
        myProvider.rx.request(MyService.coinRank(page))
            /// 转Model
            .map(BaseModel<Page<CoinRank>>.self)
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
                page == 1 ? self.refreshSubject.onNext(.stopRefresh) : self.refreshSubject.onNext(.stopLoadmore)
                
                switch event {
                case .success(let pageModel):
                    /// 解包数据
                    if let datas = pageModel.datas {
                        /// 通过page的值判断是下拉还是上拉,做数据处理,这里为了方便写注释,没有使用三目运算符
                        if page == 1 {
                            /// 下拉做赋值运算
                            self.dataSource.accept(datas)
                        }else {
                            /// 上拉做合并运算
                            self.dataSource.accept(self.dataSource.value + datas)
                        }
                    }
                    
                    /// 解包curPage与pageCount
                    if let curPage = pageModel.curPage, let pageCount = pageModel.pageCount  {
                        /// 如果发现它们相等,说明是最后一个,改变foot而状态
                        if curPage == pageCount {
                            self.refreshSubject.onNext(.showNomoreData)
                        }
                    }
                case .error(_):
                    /// error占时不做处理
                    break
                }
            }.disposed(by: rx.disposeBag)
    }
}

extension RxSwiftCoinRankListController: UITableViewDelegate {}
