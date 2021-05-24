//
//  CoinRankListController.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit
import MJRefresh

class CoinRankListController: BaseViewController {
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    var pageNum = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "积分排名"
        view.backgroundColor = .white
        setupUI()
    }
}

extension CoinRankListController {
    private func setupUI() {
        /*
         由于viewDidLoad()中调用了registerClass: forCellReuseIdentifier: 。

         所以，tableView: cellForRowAtIndexPath中的[tableView dequeueReusableCellWithIdentifier:］返回的都不是nil。并且，cell的style一直是UITableViewCellStyleDefault，所以detailTextLabel无法显示。
         */
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        /// 获取indexPath
        tableView.rx.itemSelected
            .bind { (indexPath) in
                print(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(CoinRank.self)
            .subscribe { model in
            print("模型为:\(model)")
            }
            .disposed(by: rx.disposeBag)
        
        /// 同时获取indexPath和模型
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(CoinRank.self))
            .bind { indexPath, model in
                
            }
            .disposed(by: rx.disposeBag)

        /// 设置头部刷新控件
        self.tableView.mj_header = MJRefreshNormalHeader()
        /// 设置尾部刷新控件
        self.tableView.mj_footer = MJRefreshBackNormalFooter()

        /// 初始化ViewModel
        let viewModel = CoinRankListViewModel(
            input: (
                headerRefresh: self.tableView.mj_header!.rx.headerRefreshing.asDriver(),
                footerRefresh: self.tableView.mj_footer!.rx.footerRefreshing(self.pageNum).asDriver()
                ),
            disposeBag: rx.disposeBag)
        
        /// 单元格数据的绑定
        viewModel.tableData
            .asDriver()
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
        
        /// 下拉刷新状态的绑定 需要对header与footer都做绑定
        viewModel.headerRefreshStatus
            .drive(self.tableView.mj_header!.rx.refreshValue)
            .disposed(by: rx.disposeBag)
        
        viewModel.headerRefreshStatus
            .drive(self.tableView.mj_footer!.rx.refreshValue)
            .disposed(by: rx.disposeBag)
         
        /// 上拉刷新状态的绑定 需要对header与footer都做绑定
        viewModel.footerRefreshStatus
            .drive(self.tableView.mj_header!.rx.refreshValue)
            .disposed(by: rx.disposeBag)
        

        viewModel.footerRefreshStatus
            .drive(self.tableView.mj_footer!.rx.refreshValue)
            .disposed(by: rx.disposeBag)
    }
}

extension CoinRankListController: UITableViewDelegate {
    
}
