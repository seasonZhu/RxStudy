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
    
    
    /// 请求数据
    /// - Parameter isFirstVC: 是否是第一个控制器,这里需要对第一个控制的内容边界做优化,不然它会显示不全,而其他页面不会有这个问题
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
        
        errorRetry.subscribe { _ in
            viewModel.inputs.loadData(actionType: .refresh)
        }.disposed(by: rx.disposeBag)

        /// 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, info) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: InfoViewCell.className) as? InfoViewCell {
                    cell.info = info
                    return cell
                }else {
                    let cell = InfoViewCell(style: .subtitle, reuseIdentifier: InfoViewCell.className)
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
        
        /// 这个地方对于体系列表的cell点击进来是该控制器做了优化,如果不写这句话,页面会有异常,这里这么写和vm中的refreshSubject初始值有关系
        if type == .tree {
            tableView.contentInset = UIEdgeInsets(top: -54, left: 0, bottom: 0, right: 0)
            tableView.mj_header?.beginRefreshing()
            //viewModel.inputs.refreshSubject.onNext(.begainRefresh)
        }
    }
}

