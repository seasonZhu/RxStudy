//
//  BaseViewController.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    
    private lazy var errorImage: UIImageView = {
        let imageView = UIImageView(image: R.image.saber())
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
        ///navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        /// 第一种: 将导航栏改成不透明即可, 可行
        //navigationController?.navigationBar.isTranslucent = false
        
        /// 第二种:导航栏透明的情况下,frame从导航栏下面开始,并没有达到预期的效果
        //edgesForExtendedLayout = UIRectEdge([])
        
        view.backgroundColor = .white
        
        setupErrorImage()
    }
    
    @objc
    private func leftBarButtonItemAction(_ item: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    /// 分类中的方法不能被重写必须写在class里面
    @discardableResult
    func pushToWebViewController(webLoadInfo: WebLoadInfo, isFromBanner: Bool = false) -> WebViewController {
        let vc = WebViewController(webLoadInfo: webLoadInfo, isFromBanner: isFromBanner)
        navigationController?.pushViewController(vc, animated: true)
        return vc
    }
    
    deinit {
        print("\(className)被销毁了")
    }

}

//MARK:- 网络请求错误页面的配置项(待用)
extension BaseViewController {
    private func setupErrorImage() {
        view.addSubview(errorImage)
        errorImage.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        errorImage.isHidden = true
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

//MARK:- 绑定
extension Reactive where Base: BaseViewController {
    
    /// 显示网络错误
    var networkError: Binder<Void> {
        return Binder(base) { vc, _ in
            vc.showErrorImage()
        }
    }
}
