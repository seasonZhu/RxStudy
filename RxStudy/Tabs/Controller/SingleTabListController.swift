//
//  SingleTabListController.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit
import MJRefresh

class SingleTabListController: BaseTableViewController {
    
    private let type: TagType
    
    private let tab: Tab
    
    var cellSelected: ((WebLoadInfo) -> Void)?
    
    init(type: TagType, tab: Tab, cellSelected: ((WebLoadInfo) -> Void)? = nil) {
        self.type = type
        self.tab = tab
        self.cellSelected = cellSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func requestData(isFirstVC: Bool = false) {
        if isFirstVC {
            tableView.contentInset = UIEdgeInsets(top: -54, left: 0, bottom: 0, right: 0)
        }
        tableView.mj_header?.beginRefreshing()
    }
}

extension SingleTabListController {
    private func setupUI() {
        
        title = tab.name

        /// 获取indexPath
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
            }
            .disposed(by: rx.disposeBag)
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Info.self)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                if self.type == .tree {
                    self.pushToWebViewController(webLoadInfo: model)
                }else {
                    /// 嵌套页面无法push,回调到主控制器再push
                    self.cellSelected?(model)
                }
                print("模型为:\(model)")
            })
            .disposed(by: rx.disposeBag)
                
        let viewModel = SingleTabListViewModel(type: type, tab: tab)

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

        /// 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, info) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? InfoViewCell {
                    cell.info = info
                    return cell
                }else {
                    let cell = InfoViewCell(style: .subtitle, reuseIdentifier: "Cell")
                    cell.info = info
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
        
        if type == .tree {
            tableView.contentInset = UIEdgeInsets(top: -54, left: 0, bottom: 0, right: 0)
            tableView.mj_header?.beginRefreshing()
        }
    }
}

