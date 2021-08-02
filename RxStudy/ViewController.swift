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

//MARK:- 测试代码
extension ViewController {
    private func requestTest() {
        homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
            .map { $0.data }
            .subscribe { model in
            print(model)
        } onError: { error in
            
        }.disposed(by: rx.disposeBag)
        
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
    
    private func createObservable() {
            
            let subject = PublishSubject<Void>()
            
            /// 使用flatMap转换为其他序列
            let otherOb =  subject.asObservable()
                .flatMapLatest({_ -> Observable<String> in
                    print("flatMap")
                    return self.netRequest()
                })
            
            // 发出一次next, 由于没有订阅，所以没有效
            subject.onNext(())
            
            // 订阅
            subject.subscribe(onNext: { (_) in
                print("发出一次事件")})
                .disposed(by: rx.disposeBag)
            // 又发出一次事件
            subject.onNext(())
            
            // 订阅otherOb， 之后发出的事件都可以监听，除非序列发出Error事件
            otherOb.subscribe(onNext: { (value) in
                print("otherSub subscribe")
                print(value)})
                .disposed(by: rx.disposeBag)
            
            // subject 发出两次事件
            subject.onNext(()) // [1]如果在netRequet方法中抛出Error, 就会引起序列终止，下面一个发出事件也就无效。
            subject.onNext(())

        }
        
    // 模拟网络请求
    private func netRequest() -> Observable<String> {
       return Observable<String>.create { (observer) -> Disposable in
        observer.onError(NSError(domain: "www.baidu.com", code: 30, userInfo: [:]))
//            observer.onNext("你好")
//            observer.onCompleted()
            return Disposables.create()
        }
    }

}

