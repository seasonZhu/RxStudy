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

class CoinRankListController: BaseTableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        title = "积分排名"

        /// 获取indexPath
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                print(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(CoinRank.self)
            .subscribe { model in
                print("模型为:\(model)")
            }
            .disposed(by: rx.disposeBag)
                
        let viewModel = AttractViewModel(disposeBag: rx.disposeBag)

        tableView.mj_header?.rx.refreshAction
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .refresh)
                
            })
            .disposed(by: rx.disposeBag)

        tableView.mj_footer?.rx.refreshAction
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .loadMore)
                
            })
            .disposed(by: rx.disposeBag)

        /// 绑定数据
        viewModel.outputs.dataSource
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
        
        viewModel.outputs.dataSource.map { $0.count == 0 }.bind(to: isEmpty).disposed(by: rx.disposeBag)
        
        viewModel.outputs.refreshStatusBind(to: tableView)?
            .disposed(by: rx.disposeBag)

        tableView.mj_header?.beginRefreshing()
    }
}

extension CoinRankListController {
    private func coinRankListViewModelBinding() {
        /// 初始化ViewModel
        let viewModel = CoinRankListViewModel(
            input: (
                headerRefresh: self.tableView.mj_header!.rx.headerRefreshing.asDriver(),
                footerRefresh: self.tableView.mj_footer!.rx.footerRefreshing(2).asDriver()
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
