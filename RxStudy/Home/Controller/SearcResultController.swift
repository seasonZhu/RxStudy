//
//  SearcResultController.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit
import MJRefresh

class SearcResultController: BaseTableViewController {
    
    private let keyword: String
    
    init(keyword: String) {
        self.keyword = keyword
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func requestData() {
        tableView.mj_header?.beginRefreshing()
    }
}

extension SearcResultController {
    private func setupUI() {
        
        title = keyword
        
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
                self.pushToWebViewController(webLoadInfo: model)
                print("模型为:\(model)")
            })
            .disposed(by: rx.disposeBag)
                
        let viewModel = SearchResultViewModel(keyword: keyword, disposeBag: rx.disposeBag)

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
            .asDriver()
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
        
        viewModel.outputs.refreshStatusBind(to: tableView)?
            .disposed(by: rx.disposeBag)
        
        tableView.mj_header?.beginRefreshing()
    }
}
