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

import FBRetainCycleDetector

class CoinRankListController: BaseTableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension CoinRankListController {
    private func setupUI() {
        /*
         由于viewDidLoad()中调用了registerClass: forCellReuseIdentifier: 。

         所以，tableView: cellForRowAtIndexPath中的[tableView dequeueReusableCellWithIdentifier:］返回的都不是nil。并且，cell的style一直是UITableViewCellStyleDefault，所以detailTextLabel无法显示。
         */
        // tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        
        title = "积分排名"
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(CoinRank.self)
            .subscribe { model in
                debugLog("模型为:\(model)")
                // self.test()
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func binding() {
        let viewModel = CoinRankViewModel()
        
        // let viewModel = ListViewModel<CoinRank, ListModel>(target: ListModel(page: nil, listService: .coinRank(0)))

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
            .drive(tableView.rx.items) { (tableView, _, coinRank) in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.numberOfLines = 3
                cell.textLabel?.text = coinRank.rankInfo
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
    
    /// 此方法用于验证MLeaksFinder发现循环引用的问题
    func test() {

    }
    
    /// 使用FBRetainCycleDetector寻找循环引用的环节,但是在这里例子中并没有发现
    private func findRetainCycles() {
        let detector = FBRetainCycleDetector()
        detector.addCandidate(self)
        let retainCycles = detector.findRetainCycles()
        print(retainCycles)
    }
}
