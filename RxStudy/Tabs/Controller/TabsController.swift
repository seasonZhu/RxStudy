//
//  TabsController.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxCocoa

import JXSegmentedView

class TabsController: BaseViewController {
    
    private let type: TagType
    
    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    
    private lazy var segmentedView: JXSegmentedView = JXSegmentedView()
    
    /// 存储点击tag导致的刷新
    private var tagSelectRefreshIndexs: Set<Int> = []
    
    var contentScrollView: UIScrollView!
    
    var listVCArray = [SingleTabListController]()
    
    init(type: TagType) {
        self.type = type
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

extension TabsController {
    private func setupUI() {
        title = type.title
        view.backgroundColor = .playAndroidBg
        
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedDataSource.isTitleColorGradientEnabled = true
        segmentedDataSource.titleNormalColor = .playAndroidTitle
        segmentedDataSource.titleSelectedColor = .systemBlue
        segmentedView.dataSource = segmentedDataSource

        //3、配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        indicator.lineStyle = .lengthen
        indicator.indicatorColor = .systemBlue
        segmentedView.indicators = [indicator]

        //4、配置JXSegmentedView的属性
        segmentedView.delegate = self
        segmentedView.backgroundColor = .playAndroidBg
        view.addSubview(segmentedView)

        //5、初始化contentScrollView
        contentScrollView = UIScrollView()
        contentScrollView.delegate = self
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.scrollsToTop = false
        contentScrollView.bounces = true
        //禁用automaticallyInset
        contentScrollView.contentInsetAdjustmentBehavior = .never
        
        
        view.addSubview(contentScrollView)

        //6、将contentScrollView和segmentedView.contentScrollView进行关联
        segmentedView.contentScrollView = contentScrollView
        
        segmentedView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(kTopMargin)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(44)
        }
        
        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view).offset(-kBottomMargin)
        }

        requestData()
    }
}

extension TabsController {
    func requestData() {
        let viewModel = TabsViewModel(type: type)
        
        viewModel.loadData()
        
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive { [weak self] tabs in
            self?.settingSegmentedDataSource(tabs: tabs)
        }.disposed(by: rx.disposeBag)
        
        viewModel.outputs.networkError.bind(to: rx.networkError).disposed(by: rx.disposeBag)
        
        errorRetry.subscribe { _ in
            viewModel.inputs.loadData()
        }.disposed(by: rx.disposeBag)
    }
    
    func settingSegmentedDataSource(tabs: [Tab]) {
        segmentedDataSource.titles = tabs.map{ $0.name?.replaceHtmlElement }.compactMap{ $0 }
        segmentedView.defaultSelectedIndex = 0
        segmentedView.reloadData()

        for vc in listVCArray {
            vc.view.removeFromSuperview()
        }
        listVCArray.removeAll()
        
        let _ = tabs.map { tab in
            let vc = SingleTabListController(type: type, tab: tab) { webLoadInfo in
                self.pushToWebViewController(webLoadInfo: webLoadInfo)
            }

            contentScrollView.addSubview(vc.view)
            listVCArray.append(vc)
        }
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.bounds.size.width * CGFloat(segmentedDataSource.dataSource.count),
                                               height: contentScrollView.bounds.size.height)
        
        for (index, vc) in listVCArray.enumerated() {
            vc.view.frame = CGRect(x: contentScrollView.bounds.size.width * CGFloat(index),
                                   y: 0,
                                   width: contentScrollView.bounds.size.width,
                                   height: contentScrollView.bounds.size.height)
        }
        
        if let firstVC = listVCArray.first {
            firstVC.requestData(isFirstVC: true)
            tagSelectRefreshIndexs.insert(0)
        }
        view.setNeedsLayout()
    }
}

extension TabsController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if tagSelectRefreshIndexs.contains(index) {
            return
        }
        listVCArray[index].requestData()
        tagSelectRefreshIndexs.insert(index)
    }
}

extension TabsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if #available(iOS 15.0, *) {
            /// 目前测试来看,iOS15的手势滑动有些异常,在iOS15的时候先禁用了
            return
        }
        
        var driver: Driver<ViewController.Direction>?
        
        /// 最左边
        if scrollView.contentOffset.x < 0 {
            debugLog("最左边了")
            driver = Driver.just(.toLeft)
        }
        
        /// 最右边
        if scrollView.contentOffset.x + kScreenWidth > scrollView.contentSize.width {
            debugLog("最右边了")
            driver = Driver.just(.toRight)
        }
        
        guard let d = driver, let vc = tabBarController as? ViewController else {
            return
        }
        
        d.drive(vc.rx.selectedIndexChange)
            .disposed(by: rx.disposeBag)
    }
}
