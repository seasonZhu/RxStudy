//
//  ToolController.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit
import MJRefresh

class ToolController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension ToolController {
    private func setupUI() {
        title = "工具列表"
        
        tableView.mj_footer = nil
        
        tableView.rx.modelSelected(Tool.self)
            .subscribe(onNext: { [weak self] model in
                guard let self else { return }
                self.pushToWebViewController(webLoadInfo: model, isNeedShowCollection: false)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func binding() {
        let viewModel = ToolViewModel<Tool>()

        tableView.mj_header?.rx.refresh
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        errorRetry
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        /// 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, _, tool) in

                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = tool.title
                cell.detailTextLabel?.text = tool.desc
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
        
        viewModel.inputs.refreshSubject.onNext(.begainRefresh)
    }
}
