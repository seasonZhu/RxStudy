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
        
        /// 获取indexPath
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                print(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Info.self)
            .subscribe(onNext: { [weak self] model in
                self?.pushToWebViewController(webLoadInfo: model)
                print("模型为:\(model)")
            })
            .disposed(by: rx.disposeBag)
        
        /// 同时获取indexPath和模型
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Info.self))
            .bind { indexPath, model in
                
            }
            .disposed(by: rx.disposeBag)
                
        let viewModel = HomeViewModel(disposeBag: rx.disposeBag)

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
            .asDriver(onErrorJustReturn: [])
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
        
        //MARK:- 轮播图的设置,这一段基本上就典型的Cocoa代码了
        
        let pagerView = FSPagerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width / 16.0 * 9))
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
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
        
        viewModel.outputs.banners.asDriver(onErrorJustReturn: []).drive { [weak self] models in
            self?.itmes = models
            pageControl.numberOfPages = models.count
            pagerView.reloadData()
        }.disposed(by: rx.disposeBag)


        tableView.mj_header?.beginRefreshing()
    }
}

extension HomeController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return itmes.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        if let imagePath = itmes[index].imagePath, let url = URL(string: imagePath) {
            cell.imageView?.kf.setImage(with: url)
        }
        return cell
    }
}

extension HomeController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        let item = itmes[index]
        print("点击了轮播图的\(item)")
        pushToWebViewController(webLoadInfo: item, isFromBanner: true)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        guard let pageControl = pagerView.subviews.last as? FSPageControl else {
            return
        }
        pageControl.currentPage = index
    }
}
