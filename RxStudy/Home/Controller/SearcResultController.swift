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

class SearcResultController: BaseViewController {
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
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
        title = keyword
        view.backgroundColor = .white
        setupUI()
    }
    
    func requestData() {
        tableView.mj_header?.beginRefreshing()
    }
}

extension SearcResultController {
    private func setupUI() {
        tableView.tableFooterView = UIView()
        
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
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
        
        /// 设置头部刷新控件
        tableView.mj_header = MJRefreshNormalHeader()
        /// 设置尾部刷新控件
        tableView.mj_footer = MJRefreshBackNormalFooter()
                
        let viewModel = SearchResultViewModel(keyword: keyword, disposeBag: rx.disposeBag)

        tableView.mj_header?.rx.refreshAction
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .refresh)
                
            })
            .disposed(by: disposeBag)

        tableView.mj_footer?.rx.refreshAction
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .loadMore)
                
            })
            .disposed(by: disposeBag)

        // 绑定数据
        viewModel.outputs.dataSource
            .asDriver()
            .drive(tableView.rx.items) { [weak self] (tableView, row, info) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
                    self?.cellSetting(cell: cell, info: info)
                    return cell
                }else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                    self?.cellSetting(cell: cell, info: info)
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
        
        
        viewModel.outputs.refreshStatusBind(to: tableView)?
            .disposed(by: disposeBag)
        
        tableView.mj_header?.beginRefreshing()
    }
    
    private func cellSetting(cell: UITableViewCell, info: Info) {
        var title = info.title
        cell.textLabel?.text = title?.filterHTML()
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = info.author
        cell.detailTextLabel?.textColor = .gray
    }
}

extension SearcResultController: UITableViewDelegate {}
