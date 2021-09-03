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
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        
        title = "积分排名"
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(CoinRank.self)
            .subscribe { model in
                debugLog("模型为:\(model)")
            }
            .disposed(by: rx.disposeBag)
                
        let viewModel = CoinRankViewModel()

        tableView.mj_header?.rx.refresh
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .refresh)
                
            })
            .disposed(by: rx.disposeBag)

        tableView.mj_footer?.rx.refresh
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .loadMore)
                
            })
            .disposed(by: rx.disposeBag)
        
        errorRetry.subscribe { _ in
            viewModel.inputs.loadData(actionType: .refresh)
        }.disposed(by: rx.disposeBag)

        /// 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, coinRank) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className) {
                    cell.textLabel?.text = coinRank.myInfo
                    cell.detailTextLabel?.text = coinRank.username
                    return cell
                }else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.className)
                    cell.textLabel?.text = coinRank.myInfo
                    cell.detailTextLabel?.text = coinRank.username
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.dataSource.map { $0.count == 0 }.bind(to: isEmpty).disposed(by: rx.disposeBag)
        
        viewModel.outputs.networkError.bind(to: rx.networkError).disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
    }
}
