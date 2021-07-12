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
    
    /// 作为一个可选类型的枚举,其实有个三个状态的nil true false
    /// 订阅的时候为nil,说明根本就没有执行过accept()这个函数,或者执行了还是给的nil,没有意义,不给予理会即可
    let isEmpty: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)

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
        /// 设置尾部刷新控件,更新为无感知加载更多
        let footer = MJRefreshAutoFooter()
        /// 越负越早提前加载
        footer.triggerAutomaticallyRefreshPercent = -2
        tableView.mj_footer = footer
        
        /// 设置DZNEmptyDataSet的数据源和代理
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        /// 订阅点击了数据为空，请重试的行为，里面没有用状态去绑定tableView是因为没有ViewModel
        emptyDataSetButtonTap.subscribe { [weak self] _ in
            self?.tableView.mj_header?.beginRefreshing()
        }.disposed(by: rx.disposeBag)
        
        /// 数据为空的订阅
        isEmpty.subscribe { [weak self] event in
            ///有的时候你发现所有页面都循环引用了,而且就算继承的这个类写不写代码都循环引用,这个时候你要回头看看基类,是不是基类写的东西导致了循环引用
            
            switch event {
            case .next(let noContent):
                guard let reallyNoContent = noContent else {
                    return
                }

                if reallyNoContent {
                    print("监听没有内容")
                    /// 这个地方有问题
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
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
        return isEmpty.value ?? false
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        emptyDataSetButtonTap.onNext(())
    }
}
