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

import Moya
import Alamofire

import SVProgressHUD

class ViewController: UITabBarController {
    
    lazy var transform = Transform()
    
    private let titles = TabType.allCases.map { $0.title }
    
    let textRelay = ExBehaviorRelay(value: "season", isIgnoreInitValue: true, isIgnoreFirstAccept: true)
    
    private lazy var searchButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addPan()
        networkListening()
//        addRxPan()
//        testExBehaviorRelay()
        logger.info("This is an info")
        logger.warning("Ummm...seems not that good...")
        logger.fault("Something really BAD happens!!")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// 这段代码必须写在这里,写在viewDidLoad中,items还没有,无法正确赋值        
        for index in children.indices {
            tabBar.items?[index].tag = index
        }
    }
    
    private func setupUI() {
        title = titles.first
        
        delegate = transform
        
        view.backgroundColor = .playAndroidBackground
        
        navigationItem.rightBarButtonItem = searchButtonItem
        
        /// 一般情况下状态序列我们会选用 Driver 这个类型，事件序列我们会选用 Signal 这个类型。
        /// 虽然这个Signal我目前都没有使用过,但是这句话基本上就能理解其使用场景了
        /// 但是其实这里的tap是更为严格的ControlEvent,ControlEvent 专门用于描述 UI 控件所产生的事件,这里这种写法并不好,只是尝试
        navigationItem.rightBarButtonItem?.rx.tap.asSignal().emit(onNext: { _ in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        })
        .disposed(by: rx.disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: { [weak self] _ in
            debugLog("点击事件")
            Haptics.success.feedback()
            // 使用 FlexLayout 布局的热门快捷键页面
            self?.navigationController?.pushViewController(HotKeyController(), animated: true)
        })
        .disposed(by: rx.disposeBag)
        
        addChildControllers()
        
        /// 我其实没有明白UIViewController中children与UITabBarViewController的viewControllers的区别
        /*
         UITabBarViewController的viewControllers是一个可选数组,而UIViewController的children是一个数组,但是里面的元素是一样的
         (lldb) po self.children
         ▿ 5 elements
           ▿ 0 : <RxStudy.HomeController: 0x14017cf00>
           ▿ 1 : <RxStudy.TabsController: 0x14017d400>
           ▿ 2 : <RxStudy.TabsController: 0x14017d900>
           ▿ 3 : <RxStudy.TreeController: 0x14022b800>
           ▿ 4 : <RxStudy.MyController: 0x14017de00>
         (lldb) po self.viewControllers
         ▿ Optional<Array<UIViewController>>
           ▿ some : 5 elements
             ▿ 0 : <RxStudy.HomeController: 0x14017cf00>
             ▿ 1 : <RxStudy.TabsController: 0x14017d400>
             ▿ 2 : <RxStudy.TabsController: 0x14017d900>
             ▿ 3 : <RxStudy.TreeController: 0x14022b800>
             ▿ 4 : <RxStudy.MyController: 0x14017de00>
         */
        
        bindGayMode()
        
        /// https://mp.weixin.qq.com/s/i5ydTkzlyxcgdQQ39b7lnA
        /// 一行代码解决iOS 18 iPad TabBar位置变化，还你熟悉的底部导航
        if #available(iOS 18.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                // 这行魔法代码就是解决问题的关键！
                traitOverrides.horizontalSizeClass = .compact
            }
        }
        
        // beginSplashView()
    }
    
    // MARK: - 添加子控制器
    private func addSubviewController(type: TabType) {
        let subViewController = type.viewController
        subViewController.tabBarItem.title = type.title
        // ✅ 使用 SwiftGen 生成的类型安全图片资源
        subViewController.tabBarItem.image = type.image
        subViewController.tabBarItem.selectedImage = type.selectedImage
        subViewController.title = type.title
        addChild(subViewController)

    }

    // MARK: - 添加所有子控制器
    private func addChildControllers() {
        
        TabType.allCases.forEach { type in
            addSubviewController(type: type)
        }
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
    private func networkListening() {
        /// 保证第一次进入App的时候,接收网络权限后,自动网络请求
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { _ in
            let value = NetworkReachabilityManager.default?.isReachable == true
            let isFirst = UserDefaults.standard.value(forKey: kIsFirst) as? Bool
            if value && isFirst == nil {
                self.refreshChildren()
                UserDefaults.standard.setValue(false, forKey: kIsFirst)
            }
        })
    }
    
    private func refreshChildren() {
        guard let vcs = viewControllers as? [BaseViewController] else {
            return
        }
        
        guard let contentVCs = vcs as? [TabBarViewControllerChildrenRefreshProtocol] else {
            return
        }
        
        contentVCs.forEach { $0.dataRefresh() }
    }
}

extension ViewController {
    private func beginSplashView() {
        /// R.image 已移除，使用系统图标
        let saberImage = UIImage(systemName: "star.circle.fill") ?? UIImage()
        let launchImage = UIImage(systemName: "app.fill") ?? UIImage()
        let revealingSplashView = RevealingSplashView(iconImage: saberImage, iconInitialSize: CGSize(width: 70, height: 70), backgroundImage: launchImage)
        
        (UIApplication.shared.delegate as! AppDelegate).window?.addSubview(revealingSplashView)
        
        revealingSplashView.duration = 4.0
        
        revealingSplashView.iconColor = UIColor.red
        revealingSplashView.useCustomIconColor = false
        
        revealingSplashView.animationType = SplashAnimationType.swingAndZoomOut
    
        revealingSplashView.startAnimation {
            print("Completed")
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
        if selectedIndex > 0 {
            let next = selectedIndex - 1
            let preIndex = selectedIndex
            selectedIndex = next
            
            transform.selectedIndex = next
            transform.preIndex = preIndex
        }
    }
    
    func rightScroll() {
        if selectedIndex < children.count - 1 {
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

extension ViewController {
    func testExBehaviorRelay() {
//        textRelay.exSubscribe(onNext: { [weak textRelay] string in
//            print(string)
//        })
//        .disposed(by: rx.disposeBag)
        
        let observer: AnyObserver<String> = AnyObserver { [weak self] (event) in
            guard let self else { return }
            if self.textRelay.isIgnoreInitValue {
                self.textRelay.isIgnoreInitValue = false
                return
            }
            
            switch event {
            case .next(let data):
                print("Data Task Success with count: \(data)")
            case .error(let error):
                print("Data Task Error: \(error)")
            default:
                break
            }
        }
        
        let binder = Binder<String>(view) { _, string in
            print(string)
        }

        textRelay.subscribe(observer).disposed(by: rx.disposeBag)
        textRelay.subscribe(binder).disposed(by: rx.disposeBag)
        
        textRelay.accept("soso")
        textRelay.accept("sola")
        
        EventBus.User.login.rx().subscribe { notification in
            print("rx() login")
            guard let userInfo = notification.userInfo as? [String: String] else {
                return
            }
            
            let name = userInfo["name"]
            print(name)
            
        }.disposed(by: rx.disposeBag)
        
        EventBus.User.login.rx.subscribe { _ in
            print("rx login")
        }.disposed(by: rx.disposeBag)
        
        EventBus.User.login.post(userInfo: ["name": "season"])
    }
}
