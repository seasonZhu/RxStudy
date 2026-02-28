//
//  CustomTabBarViewController.swift
//  CustomTabBarExample
//
//  Created by Jędrzej Chołuj on 18/12/2021.
//  [CustomerTabBar-Swift](https://github.com/SwiftCommunityRes/CustomerTabBar-Swift)：一个通过UIStackView自定义底部tabbar的思路，代码思路还是非常简洁的，值得借鉴。

import UIKit

import RxSwift
import SnapKit
import NSObject_Rx

class CustomTabBarController: UITabBarController {
    
    private lazy var customTabBar = CustomTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupProperties()
        bind()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        deinitDDLog()
    }
    
    private func setupHierarchy() {
        view.addSubview(customTabBar)
    }
    
    private func setupLayout() {
        customTabBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(90)
        }
    }
    
    private func setupProperties() {
        tabBar.isHidden = true
        
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.addShadow()
        
        selectedIndex = 0
        let controllers = CustomTabItem.allCases.map { $0.viewController }
        setViewControllers(controllers, animated: true)
    }

    private func selectTabWith(index: Int) {
        selectedIndex = index
    }
    
    // MARK: - Bindings
    
    private func bind() {
        customTabBar.itemTappedRelay
            .bind(onNext: { [weak self ] index in
                self?.selectTabWith(index: index)
            })
            .disposed(by: rx.disposeBag)
    }
}

/**
 Memory Leak: (
     "RxStudy.CustomTabBarController",
     UILayoutContainerView,
     UITabBar,
     UITabBarButton
 )
 这个报错不准确,已经确定都释放了
 
 */
