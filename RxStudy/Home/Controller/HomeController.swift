//
//  HomeController.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxSwiftExt
import RxCocoa
import NSObject_Rx
import SnapKit
import MJRefresh
import Kingfisher
import FSPagerView
import SVProgressHUD

/// 需要非常小心循环引用
class HomeController: BaseTableViewController {
        
    private var itmes: [Banner] = [] {
        willSet {
            pageControl.numberOfPages = newValue.count
            pagerView.reloadData()
            //bannerCustomScroll()
        }
    }
    
    private lazy var pagerView: FSPagerView = {
        let pagerView = FSPagerView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth_9_16))
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.className)
        pagerView.automaticSlidingInterval = 3.0
        pagerView.isInfinite = true
        return pagerView
    }()
    
    private lazy var pageControl: FSPageControl = {
        let pageControl = FSPageControl(frame: CGRect.zero)
        pageControl.numberOfPages = itmes.count
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension HomeController {
    private func setupUI() {
        
        title = "首页"
        
        tableView.estimatedRowHeight = 88
        
        tableView.tableHeaderView = pagerView
        
        pagerView.addSubview(pageControl)
        pagerView.bringSubviewToFront(pageControl)
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(pagerView)
            make.height.equalTo(40)
        }
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Info.self)
            .subscribe(onNext: { [weak self] model in
                debugLog("模型为:\(model)")
                if model.id == 24742 {
                    if OtherApp.qq.isCanOpen {
                        /// 这里将https改为mqq,虽然可以直接跳转到QQ,但是没有办法正常添加QQ群了
                        if let urlString = model.link?.replaceHtmlElement,
                           let url = URL(string: urlString),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    } else {
                        SVProgressHUD.showText("请先安装手机QQ")
                    }
                } else {
                    self?.pushToWebViewController(webLoadInfo: model)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func binding() {
        let viewModel = HomeViewModel()

        tableView.mj_header?.rx.refresh
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        tableView.mj_footer?.rx.refresh
            .map { ScrollViewActionType.loadMore }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
        
        errorRetry
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        /// 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, info) in
                /// 其实这里有关Cell的复用可不可只写dequeueReusableCell,然后强转,发现直接崩溃了,和Demo里的很不一样,这里需要思考一下
                /*  保留了一个例子,作为对比
                if let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.className) as? InfoCell {
                    cell.info = info
                    return cell
                } else {
                    let cell = InfoCell(style: .subtitle, reuseIdentifier: InfoCell.className)
                    cell.info = info
                    return cell
                }
                */
                let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.className) as! InfoCell
                cell.info = info
                return cell
                
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.dataSource
            .map { $0.isEmpty }
            .bind(to: isEmptyRelay)
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
    
        /// 轮播图数据驱动
        /// 我尝试给FSPagerView做rx扩展,当我写到第300行的时候,发现我引用的越来越多的时候,放弃了
        viewModel.outputs.banners
            .bind(to: rx.itmes)
            .disposed(by: rx.disposeBag)
    }
    
    private func bannerCustomScroll() {
        for subview in pagerView.subviews {
            for sub in subview.subviews {
                if let collectionView = sub as? UICollectionView {
                    collectionView.isPagingEnabled = false
                    let interval: TimeInterval = 1.0/6.0
                    Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                        let x = collectionView.contentOffset.x
                        
                        let contentOffset = CGPoint(x: x + 2, y: 0)
                        collectionView.setContentOffset(contentOffset, animated: true)
                    }
                    
                    pagerView.panGestureRecognizer.rx.event.subscribe(onNext: { pan in
                        print("滑动了")
                        let x = collectionView.contentOffset.x
                        
                        let contentOffset = CGPoint(x: x + 2, y: 0)
                        collectionView.setContentOffset(contentOffset, animated: true)
                    }).disposed(by: self.rx.disposeBag)
                    break
                }
            }
        }
    }
}

//MARK: - FSPagerViewDataSource
extension HomeController: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return itmes.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.className, at: index)
        if let imagePath = itmes[index].imagePath,
           let url = URL(string: imagePath) {
            cell.imageView?.kf.setImage(with: url)
        }
        return cell
    }
}

//MARK: - FSPagerViewDelegate
extension HomeController: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: false)
        let item = itmes[index]
        debugLog("点击了轮播图的\(item)")
        pushToWebViewController(webLoadInfo: item, isNeedShowCollection: false)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        guard let pageControl = pagerView.subviews.last as? FSPageControl else {
            return
        }
        pageControl.currentPage = index
    }
}

extension HomeController {
    private func zipDebug() {
        /// 同时获取indexPath和模型
        
        /// 另一种运算方式,其实这种zip预算拿到的类型和Observable.zip并不相同
        tableView.rx.itemSelected.zip(with: tableView.rx.modelSelected(Info.self)) { index, model in
            return (index, model)
        }.subscribe { event in
            switch event {
                
            case .next((let index, let model)):
                break
            case .error(let error):
                debugLog(error)
            case .completed:
                debugLog("completed")
            }
            
        }
        .disposed(by: rx.disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Info.self))
            .bind { indexPath, model in
                
            }
            .disposed(by: rx.disposeBag)
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
         self.pushToWebViewController(webLoadInfo: item, isNeedShowCollection: true)
     default:
         break
     }
 }.disposed(by: rx.disposeBag)
 */
