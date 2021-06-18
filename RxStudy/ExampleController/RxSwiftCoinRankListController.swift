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
    lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    /// 初始化page为1
    var page: Int = 1
    
    /// 单页的最大条数,这个是需要和后台规定好的
    var onePageMaxSize = 30
    
    /// 既是可监听序列也是观察者的数据源
    var dataSource: BehaviorRelay<[CoinRank]> = BehaviorRelay(value: [])
    
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
        
        tableView.mj_header?.beginRefreshing { [weak self] in
            self?.refreshAction()
        }
        
        /// 设置尾部刷新控件
        tableView.mj_footer = MJRefreshBackNormalFooter()
        
        tableView.mj_footer?.beginRefreshing { [weak self] in
            self?.loadMoreAction()
            
        }
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
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
    }

}

extension RxSwiftCoinRankListController {
    func refreshAction() {
        resetCurrentPageAndMjFooter()
        getCoinRank(page: page)
    }
    
    func  loadMoreAction() {
        page = page + 1
        getCoinRank(page: page)
    }
    
    func resetCurrentPageAndMjFooter() {
        page = 1
        self.tableView.mj_footer?.isHidden = false
        self.tableView.mj_footer?.resetNoMoreData()
    }
    
    func getCoinRank(page: Int) {
        myProvider.rx.request(MyService.coinRank(page))
            .map(BaseModel<Page<CoinRank>>.self)
            .map{ $0.data }
            .compactMap { $0 }
            .asObservable()
            .asSingle()
            .subscribe { event in
                
                self.tableView.mj_header?.endRefreshing()
                
                switch event {
                case .success(let pageModel):
                    guard let datas = pageModel.datas else {
                        return
                    }
                    if page == 1 {
                        self.dataSource.accept(datas)
                        if datas.count < self.onePageMaxSize {
                            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        }
                    }else {
                        self.dataSource.accept(self.dataSource.value + datas)
                        guard let curPage = pageModel.curPage, let pageCount = pageModel.pageCount else {
                            return
                        }
                        
                        if curPage == pageCount {
                            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        } else {
                            self.tableView.mj_footer?.endRefreshing()
                        }
                    }
                case .error(_):
                    break
                }
            }.disposed(by: rx.disposeBag)
    }
}

extension RxSwiftCoinRankListController: UITableViewDelegate {}
