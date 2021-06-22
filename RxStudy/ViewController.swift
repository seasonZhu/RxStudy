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
import AcknowList

class ViewController: UITabBarController {
    
    lazy var searchButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        delegate = self
        addChildControllers()
        title = viewControllers?.first?.title
        navigationItem.rightBarButtonItem = searchButtonItem
        
        navigationItem.rightBarButtonItem?.rx.tap.subscribe({ [weak self] _ in
            print("点击事件")
            self?.navigationController?.pushViewController(HotKeyController(), animated: true)
        }).disposed(by: rx.disposeBag)
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



extension ViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("shouldSelect--即将显示的控制器--\(viewController.className)")
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("didSelect--当前显示的控制器--\(viewController.className)")
        tabBarController.title = viewController.title
        let isHome = tabBarController.selectedIndex == 0
        navigationItem.rightBarButtonItem = isHome ? searchButtonItem : nil
//        Observable.of(isHome).bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: rx.disposeBag)
    }
}


extension ViewController {
    private func requestTest() {
        homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
            .map { $0.data }
            .subscribe { model in
            print(model)
        } onError: { error in
            
        }
        
        let model1 = try? homeProvider.rx.request(HomeService.banner).map(BaseModel<[Banner]>.self).toBlocking().first()
        let model2 = try? homeProvider.rx.request(HomeService.topArticle).map(BaseModel<[Info]>.self).toBlocking().first()
        let model3 = try? homeProvider.rx.request(HomeService.normalArticle(0)).map(BaseModel<Page<Info>>.self).toBlocking().first()
        print("toBlocking")
        print(model1)
        print("----------------")
        print(model2)
        print("----------------")
        print(model3)
        print("----------------")
        
        myProvider.rx.request(MyService.coinRank(1)).map(BaseModel<Page<CoinRank>>.self).subscribe(onSuccess: { model in
            print(model)
        }, onError: { error in
            print(error)
        }).disposed(by: rx.disposeBag)
    }
}

