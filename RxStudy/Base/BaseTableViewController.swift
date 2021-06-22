//
//  BaseTableViewController.swift
//  RxStudy
//
//  Created by season on 2021/5/31.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import MJRefresh
import DZNEmptyDataSet

class BaseTableViewController: BaseViewController {
    
    lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    let emptyDataSetButtonTap = PublishSubject<Void>()
    
    let isEmpty = BehaviorRelay(value: false)

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
        
        /// 设置DZNEmptyDataSet的数据源和代理
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        /// 订阅点击了数据为空，请重试的行为，里面没有用状态去绑定tableView是因为没有ViewModel
        emptyDataSetButtonTap.subscribe { [weak self] _ in
            self?.tableView.mj_header?.beginRefreshing()
        }.disposed(by: rx.disposeBag)
        
        /// 数据为空的订阅（待用）
        isEmpty.subscribe { event in
            switch event {
            case .next(let noContent):
                if noContent {
                    /// 这个地方有问题
//                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                break
            default:
                break
            }
        }.disposed(by: rx.disposeBag)
    }

    @discardableResult
    override func pushToWebViewController(webLoadInfo: WebLoadInfo, isFromBanner: Bool = false) -> WebViewController {
        let vc = super.pushToWebViewController(webLoadInfo: webLoadInfo, isFromBanner: isFromBanner)
        vc.hasCollectAction.subscribe { [weak self] _ in
            self?.tableView.mj_header?.beginRefreshing()
        }.disposed(by: rx.disposeBag)
        return vc
    }
}

//MARK:- UITableViewDelegate
extension BaseTableViewController: UITableViewDelegate {}

//MARK:- DZNEmptyDataSetSource
extension BaseTableViewController: DZNEmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "暂无数据")
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "尝试点击刷新获取数据")
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -60
    }
}

//MARK:- DZNEmptyDataSetSource
extension BaseTableViewController: DZNEmptyDataSetDelegate {

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return isEmpty.value
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        emptyDataSetButtonTap.onNext(())
    }
}
