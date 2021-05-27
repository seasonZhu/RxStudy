//
//  TabsController.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import JXSegmentedView

class TabsController: BaseViewController {
    
    private let type: TagType
    
    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = JXSegmentedTitleDataSource()
    
    private lazy var segmentedView: JXSegmentedView = JXSegmentedView()
    
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
        view.backgroundColor = .white
        
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedDataSource.isTitleColorGradientEnabled = true
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
        view.addSubview(segmentedView)

        //5、初始化contentScrollView
        contentScrollView = UIScrollView()
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.scrollsToTop = false
        contentScrollView.bounces = false
        //禁用automaticallyInset
        contentScrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(contentScrollView)

        //6、将contentScrollView和segmentedView.contentScrollView进行关联
        segmentedView.contentScrollView = contentScrollView
        
        segmentedView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(UIApplication.shared.statusBarFrame.height + 44)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(44)
        }
        
        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.leading.trailing.bottom.equalTo(view)
        }

        requestData()
    }
}

extension TabsController {
    func requestData() {
        let viewModel = TabsViewModel(type: type, disposeBag: rx.disposeBag)
        
        viewModel.loadData()
        
        viewModel.outputs.dataSource.asDriver().drive { [weak self] tabs in
            self?.settingSegmentedDataSource(tabs: tabs)
        }.disposed(by: rx.disposeBag)
        
        
    }
    
    func settingSegmentedDataSource(tabs: [Tab]) {
        segmentedDataSource.titles = tabs.map{ $0.name }.compactMap{ $0 }
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
        
        view.setNeedsLayout()
    }
}

extension TabsController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {

    }
}
