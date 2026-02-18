//
//  MyCoinController.swift
//  RxStudy
//
//  Created by season on 2021/6/17.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

class MyCoinController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension MyCoinController {
    private func setupUI() {
        title = "我的积分"
    }
    
    private func binding() {
        let viewModel = MyCoinViewModel()

        tableView.mj_header?.rx.refresh
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        tableView.mj_footer?.rx.refresh
            .map { ScrollViewActionType.loadMore }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        errorRetry
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        /// 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, _, myHistoryCoin) in

                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = myHistoryCoin.desc?.replacingOccurrences(of: " , ", with: "\n\n")
                cell.textLabel?.numberOfLines = 0
                /// detailTextLabel不会显示出来,因为UITableViewCell的样式不对
                cell.detailTextLabel?.text = myHistoryCoin.reason
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.dataSource
            .map { $0.isEmpty }
            .bind(to: isEmptyRelay)
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
    }
}
