//
//  BaseViewController.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import HttpRequest

import RxSwift
import RxCocoa
import RxGesture
import Moya

import SVProgressHUD

class BaseViewController: UIViewController {
    
    private lazy var errorImage: UIImageView = {
        let imageView = UIImageView(image: R.image.notFound())
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .playAndroidBg
        return imageView
    }()
    
    /// 错误异常重试
    let errorRetry = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 最简单的设置统一返回按钮的方法,所有的控制器继承该基类即可
        let leftBarButtonItem = UIBarButtonItem(image: R.image.back(), style: .plain, target: self, action: #selector(leftBarButtonItemAction(_:)))
        navigationItem.leftBarButtonItem = (navigationController?.viewControllers.count ?? 0) > 1 ? leftBarButtonItem : nil
        navigationItem.hidesBackButton = true
        
        /// 这个代理必须要设置为nil(其实self也可以但是会出事),侧滑才能使用
        /*
         在iOS7中，新增加了一个小小的功能，也就是这个self.navigationController.interactivePopGestureRecognizer。

         1.情景概况:

         在UINavigationController自定义返回按钮后无法实现手势右滑到上一级界面。

         2.解决方案:

         self.navigationController.interactivePopGestureRecognizer.delegate 默认是<_UINavigationInteractiveTransition: 0x15cd0a000>，必须置空或是其他。

         (1)self.navigationController.interactivePopGestureRecognizer.delegate = nil;

         (2)self.navigationController.interactivePopGestureRecognizer.delegate = self;(self是指控制器UIViewController)

         这些方法写在要滑动的控制器UIViewController里面的。

         3.知识延生:不要实现手势右滑到上一级界面

         self.navigationController.interactivePopGestureRecognizer.enabled = NO;(界面不具有相互交互手势)
         */
        
        /// 下面这个代码看似没有什么问题,如果在根控制器进行侧滑操作,然后再尝试点击进行页面的push操作就会卡住,必须要配合BaseNavigationController进行操作才行
        ///navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        /// 第一种: 将导航栏改成不透明即可, 可行
        //navigationController?.navigationBar.isTranslucent = false
        
        /// 第二种:导航栏透明的情况下,frame从导航栏下面开始,并没有达到预期的效果
        //edgesForExtendedLayout = UIRectEdge([])
        
        view.backgroundColor = .clear
        
        iOS15NavigationBarClear()
        iOS15TabBarClear()
        
        setupErrorImage()
    }
    
    @objc
    private func leftBarButtonItemAction(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    /// 写在extension分类中的方法不能被重写必须写在class里面
    @discardableResult
    func pushToWebViewController(webLoadInfo: WebLoadInfo, isNeedShowCollection: Bool = true) -> WebViewController {
        let vc = WebViewController(webLoadInfo: webLoadInfo, isNeedShowCollection: isNeedShowCollection)
        navigationController?.pushViewController(vc, animated: true)
        return vc
    }
    
    deinit {
        debugLog("\(className)被销毁了")
    }

}

//MARK: - 网络请求错误页面的配置
extension BaseViewController {
    private func setupErrorImage() {
        view.addSubview(errorImage)
        errorImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        errorImage.isHidden = true
        
        /*
        /// 被rx.tapGesture()取代
        let tap = UITapGestureRecognizer()
        errorImage.addGestureRecognizer(tap)
        tap.rx.event.map { _ in }.bind(to: errorRetry).disposed(by: rx.disposeBag)
        */
        
        errorImage.rx.tapGesture()
            .when(.recognized)
            .map { _ in }
            .bind(to: errorRetry)
            .disposed(by: rx.disposeBag)
    }
    
    func showErrorImage() {
        errorImage.isHidden = false
        view.bringSubviewToFront(errorImage)
    }
    
    func hiddenErrorImage() {
        errorImage.isHidden = true
        view.sendSubviewToBack(errorImage)
    }
}

extension BaseViewController {
    private func iOS15NavigationBarClear() {
        if #available(iOS 15.0, *) {
            /// UINavigationBarAppearance属性从iOS13开始
            let navBarAppearance = UINavigationBarAppearance()

            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            
            //navigationController?.navigationBar.standardAppearance = navBarAppearance
        }
    }
    
    private func iOS15TabBarClear() {
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            
            tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
}

extension BaseViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        SVProgressHUD.styleSetting()
    }
}

//MARK: - 绑定
extension Reactive where Base: BaseViewController {
    
    /// 显示网络错误
    var networkError: Binder<MoyaError?> {
        return Binder(base) { vc, error in
            if let _ = error {
                vc.showErrorImage()
            } else {
                vc.hiddenErrorImage()
            }
        }
    }
}
