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
import RxBlocking
import Moya

class ViewController: UITabBarController {
    
    var transform: Transform!
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for (index, _) in children.enumerated() {
            tabBar.items?[index].tag = index
        }
    }
    
    private func setupUI() {
        transform = Transform()
        delegate = transform
        
        view.backgroundColor = .playAndroidBg
        title = viewControllers?.first?.title
        navigationItem.rightBarButtonItem = transform.searchButtonItem
        
        /// 一般情况下状态序列我们会选用 Driver 这个类型，事件序列我们会选用 Signal 这个类型。
        /// 虽然这个Signal我目前都没有使用过,但是这句话基本上就能理解其使用场景了
        /// 但是其实这里的tap是更为严格的ControlEvent,ControlEvent 专门用于描述 UI 控件所产生的事件,这里这种写法并不好,只是尝试
        navigationItem.rightBarButtonItem?.rx.tap.asSignal().emit(onNext: { _ in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: rx.disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap.subscribe({ [weak self] _ in
            print("点击事件")
            self?.navigationController?.pushViewController(HotKeyController(), animated: true)
        }).disposed(by: rx.disposeBag)
        
        addChildControllers()
    }
    
    //MARK:- 添加子控制器
    private func addSubviewController(subViewController: UIViewController, title: String, imageName: String, selectImageName: String) {
        subViewController.tabBarItem.title = title
        subViewController.tabBarItem.image = UIImage(named: imageName)
        subViewController.tabBarItem.selectedImage = UIImage(named: selectImageName)
        subViewController.title = title
        addChild(subViewController)
        
    }

    //MARK:- 添加所有子控制器
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
    }
}

/// 我尝试进行手势切换,但是目前还没有想到特别好的方式方法
extension ViewController {
    private func addPan() {
        let pan = UIPanGestureRecognizer()
        view.addGestureRecognizer(pan)
        pan.rx.event.subscribe { [weak self] _ in
            self?.handlePan(pan)
        }

    }
    
    
    private func handlePan(_ pan: UIPanGestureRecognizer) {
        let translationX =  pan.translation(in: view).x
        let _ = abs(translationX) / view.frame.size.width
        
        switch pan.state {
        case .began:
            let velocityX = pan.velocity(in: view).x
            if velocityX < 0 {

                if (self.selectedIndex < self.children.count - 1) {
                    self.selectedIndex += 1;
                    
                    let next = selectedIndex + 1
                    let pre = selectedIndex
                    
                    transform.selectedIndex = next
                    transform.preIndex = pre
                }
            }
            else {
                if (self.selectedIndex > 0) {
                    let next = selectedIndex - 1
                    let pre = selectedIndex
                    
                    transform.selectedIndex = pre
                    transform.preIndex = next
                }
            }
        case .changed:
            break
        default:
            break
        }
    }
}
