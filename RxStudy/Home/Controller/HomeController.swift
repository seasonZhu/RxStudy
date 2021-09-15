//
//  HomeController.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit
import MJRefresh
import Kingfisher
import FSPagerView

/// 需要非常小心循环引用
class HomeController: BaseTableViewController {
        
    var itmes: [Banner] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension HomeController {
    private func setupUI() {
        
        title = "首页"
        
        tableView.estimatedRowHeight = 88
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Info.self)
            .subscribe(onNext: { [weak self] model in
                self?.pushToWebViewController(webLoadInfo: model)
                debugLog("模型为:\(model)")
            })
            .disposed(by: rx.disposeBag)
        
        /// 同时获取indexPath和模型
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Info.self))
            .bind { indexPath, model in
                
            }
            .disposed(by: rx.disposeBag)
                
        let viewModel = HomeViewModel()

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
                if let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.className) as? InfoCell {
                    cell.info = info
                    return cell
                }else {
                    let cell = InfoCell(style: .subtitle, reuseIdentifier: InfoCell.className)
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
        
        //MARK:- 轮播图的设置,这一段基本上就典型的Cocoa代码了
        
        let pagerView = FSPagerView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth_9_16))
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.className)
        pagerView.automaticSlidingInterval = 3.0
        pagerView.isInfinite = true
        tableView.tableHeaderView = pagerView
        
        let pageControl = FSPageControl(frame: CGRect.zero)
        pageControl.numberOfPages = itmes.count
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        pagerView.addSubview(pageControl)
        pagerView.bringSubviewToFront(pageControl)
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(pagerView)
            make.height.equalTo(40)
        }
        
        /// 轮播图数据驱动
        /// 我尝试给FSPagerView做rx扩展,当我写到第300行的时候,发现我引用的越来越多的时候,放弃了
        viewModel.outputs.banners.asDriver(onErrorJustReturn: []).drive { [weak self] models in
            self?.itmes = models
            pageControl.numberOfPages = models.count
            pagerView.reloadData()
        }.disposed(by: rx.disposeBag)
    }
}

//MARK:- FSPagerViewDataSource
extension HomeController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return itmes.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.className, at: index)
        if let imagePath = itmes[index].imagePath, let url = URL(string: imagePath) {
            cell.imageView?.kf.setImage(with: url)
        }
        return cell
    }
}

//MARK:- FSPagerViewDelegate
extension HomeController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        let item = itmes[index]
        debugLog("点击了轮播图的\(item)")
        pushToWebViewController(webLoadInfo: item, isFromBanner: true)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        guard let pageControl = pagerView.subviews.last as? FSPageControl else {
            return
        }
        pageControl.currentPage = index
    }
}

/**
 pagerView.rx.setDelegate(self).disposed(by: rx.disposeBag)
 pagerView.rx.didSelectItemAtIndex.subscribe { [weak self, weak pagerView] event in
     guard let self = self, let pg = pagerView else {
         return
     }
     
     switch event {
     case .next(let index):
         pg.deselectItem(at: index, animated: false)
         let item = self.itmes[index]
         debugLog("点击了轮播图的\(item)")
         self.pushToWebViewController(webLoadInfo: item, isFromBanner: true)
     default:
         break
     }
 }.disposed(by: rx.disposeBag)
 */
