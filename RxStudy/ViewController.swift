//
//  ViewController.swift
//  RxStudy
//
//  Created by season on 2019/1/29.
//  Copyright © 2019 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture


import SVProgressHUD

class ViewController: UITabBarController {
    
    lazy var transform = Transform()
    
    private var titles: [String] = []
    
    private lazy var searchButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addPan()
        //addRxPan()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// 这段代码必须写在这里,写在viewDidLoad中,items还没有,无法正确赋值
        for (index, _) in children.enumerated() {
            tabBar.items?[index].tag = index
        }
    }
    
    private func setupUI() {
        delegate = transform
        
        view.backgroundColor = .playAndroidBg
        
        navigationItem.rightBarButtonItem = searchButtonItem
        
        /// 一般情况下状态序列我们会选用 Driver 这个类型，事件序列我们会选用 Signal 这个类型。
        /// 虽然这个Signal我目前都没有使用过,但是这句话基本上就能理解其使用场景了
        /// 但是其实这里的tap是更为严格的ControlEvent,ControlEvent 专门用于描述 UI 控件所产生的事件,这里这种写法并不好,只是尝试
        navigationItem.rightBarButtonItem?.rx.tap.asSignal().emit(onNext: { _ in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: rx.disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap.subscribe { [weak self] _ in
            debugLog("点击事件")
            Haptics.success.feedback()
            self?.navigationController?.pushViewController(HotKeyController(), animated: true)
        }.disposed(by: rx.disposeBag)
        
        addChildControllers()
        
        /// 我其实没有明白UIViewController中children与UITabBarViewController的viewControllers的区别
        title = viewControllers?.first?.title
    }
    
    //MARK: - 添加子控制器
    private func addSubviewController(subViewController: UIViewController, title: String, imageName: String, selectImageName: String) {
        subViewController.tabBarItem.title = title
        subViewController.tabBarItem.image = UIImage(named: imageName)
        subViewController.tabBarItem.selectedImage = UIImage(named: selectImageName)
        subViewController.title = title
        addChild(subViewController)
        titles.append(title)
    }

    //MARK: - 添加所有子控制器
    private func addChildControllers() {

        let homeVC = HomeController()
        addSubviewController(subViewController: homeVC,
                             title: "首页",
                             imageName: R.image.home.name,
                             selectImageName: R.image.home_selected.name)


        let projectVC = TabsController(type: .project)
        addSubviewController(subViewController: projectVC,
                             title: "项目",
                             imageName: R.image.project.name,
                             selectImageName: R.image.project_selected.name)


        let publicNumberVC = TabsController(type: .publicNumber)
        addSubviewController(subViewController: publicNumberVC,
                             title: "公众号",
                             imageName: R.image.publicNumber.name,
                             selectImageName: R.image.publicNumber_selected.name)

        let treeVC = TreeController(type: .tree)
        addSubviewController(subViewController: treeVC,
                             title: "体系",
                             imageName: R.image.tree.name,
                             selectImageName: R.image.tree_selected.name)
        
        let myVC = MyController()
        addSubviewController(subViewController: myVC,
                             title: "我的",
                             imageName: R.image.my.name,
                             selectImageName: R.image.my_selected.name)
    }
}

extension ViewController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        transform.selectedIndex = item.tag
        transform.preIndex = selectedIndex
        debugLog("selectedIndex:\(item.tag)")
        debugLog("preIndex:\(selectedIndex)")
    }
}

/// 我尝试进行手势切换,但是目前还没有想到特别好的方式方法
extension ViewController {
    private func addPan() {
        let pan = UIPanGestureRecognizer()
        view.addGestureRecognizer(pan)
        
        /// 会打印一次begin,很多次change,和一次end,我需要抓取一次的这种事件,然后再去驱动进程tab的切换而过滤掉change
        pan.rx.event.map { $0.state == .began }
            .subscribe(onNext: { [weak self] isBegan in
                if isBegan {
                    self?.handlePan(pan)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    /// 这个rx.panGesture,在项目\公众号页面,无法区分是scrollViwe的左右滑动还是手势的左右侧滑
    private func addRxPan() {
        view.rx.panGesture().when(.began)
            .subscribe(onNext: { [weak self] pan in
                self?.handlePan(pan)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    private func handlePan(_ pan: UIPanGestureRecognizer) {
        let velocityX = pan.velocity(in: view).x
        let translation = pan.translation(in: view)
        
        let x = abs(translation.x)
        let y = abs(translation.y)
        
        debugLog("x: \(x), y: \(y)")
        
        
        if x < y {
            /// 纵向滑动
        } else {
            /// 横向滑动
            let direction: ViewController.Direction = velocityX < 0 ? .toRight : .toLeft
    
            Driver.just(direction)
                .drive(rx.selectedIndexChange)
                .disposed(by: rx.disposeBag)
        }
    }
}

extension ViewController {
    enum Direction {
        case toLeft
        case toRight
    }
}

extension ViewController.Direction: CustomStringConvertible {
    var description: String {
        let string: String
        switch self {
        case .toLeft:
            string = "向左"
        case .toRight:
            string = "向右"
        }
        return string
    }
}

extension Reactive where Base: ViewController {
    var selectedIndexChange: Binder<ViewController.Direction> {
        return Binder(base) { vc, direction in
            vc.changeSelectedViewController(direction: direction)
        }
    }
}

extension ViewController {
    func changeSelectedViewController(direction: Direction) {
        switch direction {
        case .toLeft:
            leftScroll()
        case .toRight:
            rightScroll()
        }
        title = titles[selectedIndex]
    }
    
    func leftScroll() {
        if (selectedIndex > 0) {
            let next = selectedIndex - 1
            let preIndex = selectedIndex
            selectedIndex = next
            
            transform.selectedIndex = next
            transform.preIndex = preIndex
        }
    }
    
    func rightScroll() {
        if (selectedIndex < children.count - 1) {
            let next = selectedIndex + 1
            let preIndex = selectedIndex
            selectedIndex = next
            
            transform.selectedIndex = next
            transform.preIndex = preIndex
        }
    }
}

extension ViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        SVProgressHUD.styleSetting()
    }
}
