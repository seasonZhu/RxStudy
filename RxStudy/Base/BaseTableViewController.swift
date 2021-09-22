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
    
    /// BehaviorRelay 就是 BehaviorSubject 去掉终止事件 onError 或 onCompleted
    /// 当观察者对 BehaviorSubject 进行订阅时，它会将源 Observable 中最新的元素发送出来（如果不存在最新的元素，就发出默认元素）。然后将随后产生的元素发送出来。
    /// 所以下面的代码对其订阅,首先会发出默认值false,表名一开始是有值的,所以被拦住,当变为true时,就走到if noContent的逻辑中
    let isEmpty: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        
        /// 设置tableFooterView
        tableView.tableFooterView = UIView()
        
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        /// 获取indexPath 基类中取消点击cell的动画效果
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                debugLog(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        /// 简单布局
        gcdMainAsyncLayout()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
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
                
                /// isEmpty中的value为true才调用下面的方法
                if noContent {
                    debugLog("监听没有内容")
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            default:
                break
            }
        }.disposed(by: rx.disposeBag)
    }

    @discardableResult
    override func pushToWebViewController(webLoadInfo: WebLoadInfo, isFromBanner: Bool = false) -> WebViewController {
        let vc = super.pushToWebViewController(webLoadInfo: webLoadInfo, isFromBanner: isFromBanner)
        /// 其实这个地方使用callback或者是用Rx的subscribe感觉差不了太多,都是作为回调来看待
        vc.hasCollectAction.subscribe { [weak self] _ in
            self?.tableView.mj_header?.beginRefreshing()
        }.disposed(by: rx.disposeBag)
        
        /// 上面这个操作其实和这个操作是同一个功能,但是你看这代码量,所以说还是回调好啊
        //vc.delegate = self
        vc.rx.setDelegate(self).disposed(by: rx.disposeBag)
        vc.rx.actionSuccess.subscribe { _ in
            print("操作成功了")
        }.disposed(by: rx.disposeBag)
        return vc
    }
    
    /// 会报错Warning once only: UITableView was told to layout its visible cells and other contents without being in the view hierarchy
    /// 用GCD就不会报错了,也不知道为什么
    private func gcdMainAsyncLayout() {
        DispatchQueue.main.async {
            self.addTableViewAndLayout()
        }
    }
    
    /// 添加tableView并layout
    private func addTableViewAndLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
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

extension BaseTableViewController: WebViewControllerDelegate {}
