//
//  BaseTableViewController.swift
//  RxStudy
//
//  Created by season on 2021/5/31.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import MJRefresh
import DZNEmptyDataSet

class BaseTableViewController: BaseViewController {
    
    lazy var tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        
        /// 设置tableFooterView
        tableView.tableFooterView = UIView()
        
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        /// 设置头部刷新控件
        tableView.mj_header = MJRefreshNormalHeader()
        /// 设置尾部刷新控件
        tableView.mj_footer = MJRefreshBackNormalFooter()
    }

}

extension BaseTableViewController: UITableViewDelegate {}
