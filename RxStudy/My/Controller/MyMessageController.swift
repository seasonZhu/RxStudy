//
//  MyMessageController.swift
//  RxStudy
//
//  Created by dy on 2022/6/27.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

import HttpRequest

class MyMessageController: BaseTableViewController {
    
    let status: MessageReadyStatus
    
    init(status: MessageReadyStatus) {
        self.status = status
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}

extension MyMessageController {
    private func setupUI() {
        
        title = status.title
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Message.self)
            .subscribe(onNext: { [weak self] model in
                guard let self else { return }
                let info = MessageLoadInfo(id: model.id, originId: model.id, title: model.title, link: model.fullLink)
                self.pushToWebViewController(webLoadInfo: info, isNeedShowCollection: false)
                debugLog("模型为:\(model)")
            })
            .disposed(by: rx.disposeBag)
        
        let viewModel = MessageViewModel(status: status)
        
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
            .drive(tableView.rx.items) { (tableView, row, message) in
                
                let cell = tableView.dequeueReusableCell(withIdentifier: MessageContentCell.className) as! MessageContentCell
                cell.message = message
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.dataSource
            .map { $0.isEmpty }
            .bind(to: isEmptyRelay)
            .disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)
    }
}
