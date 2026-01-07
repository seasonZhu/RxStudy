//
//  AppIconSelectController.swift
//  RxStudy
//
//  Created by dy on 2025/2/7.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import MJRefresh

// https://mp.weixin.qq.com/s?__biz=Mzg3MDk3NzUzNw==&mid=2247484414&idx=1&sn=6324639765e7abbabbcc44aa1cd4177f&chksm=ce84da90f9f3538692764048e313cdd03e609f81d7ef22fe090859385f948fb8adb1253c7d7d&scene=21#wechat_redirect
// https://mp.weixin.qq.com/s?__biz=Mzg3MDk3NzUzNw==&mid=2247486755&idx=1&sn=44f178bc937a93412336a634042daa9c&chksm=ce84d44df9f35d5b7df6760cc94767a48e015073c930e45e5093554ddc070090d92e29a92082&scene=21#wechat_redirect

// https://juejin.cn/post/7392066866078302217

class AppIconSelectController: BaseTableViewController {
    
    let appProxy: LSApplicationProxy = LSBundleProxy.bundleProxyForCurrentProcess()
    
    var appIconName = AppIconType.swiftStyle.iconName
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension AppIconSelectController {
    private func setupUI() {
        title = "更换App图标"
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        tableView.rowHeight = 44
    }
    
    private func binding() {

        Driver.just(AppIconType.allCases)
            .drive(tableView.rx.items) { [weak self] (tableView, _, type) in
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = type.title
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        /// 这里相当于重写
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                
                guard UIApplication.shared.supportsAlternateIcons else {
                    print("不支持设置其他图标")
                    return
                }
                
                let type = AppIconType.allCases[indexPath.row]
                
                switch type {
                case .onBackgroundTimer:
                    self?.startAnimation()
                default:
                    guard UIApplication.shared.alternateIconName != type.iconName else {
                        let alert = UIAlertController(title: "提示", message: "当前使用的正是这个图标，无需重复设置", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                        return
                    }
                    
                    /// 1.通过自定义一个透明的控制器去拦截系统弹窗,推荐这个方法
                    let transparentVC = TransparentViewController()
                    transparentVC.modalPresentationStyle = .overFullScreen
                    self?.present(transparentVC, animated: false) {
                        UIApplication.shared
                            .setAlternateIconName(type.iconName) { error in
                            if let error {
                                print("设置 App Icon 出错： \(error)")
                            } else {
                                print("App Icon 设置成功")
                            }
                        }
                    }
                    
                    /// 2.通过反射去调用系统的私有方法
//                    self?.setApplicationIconName(type.iconName)
                    
                    /// 3.定义这个私有方法
//                    UIApplication.shared
//                        ._setAlternateIconName(type.iconName) { error in
//                            if let error {
//                                print("设置 App Icon 出错： \(error)")
//                            } else {
//                                print("App Icon 设置成功")
//                            }
//                        }
                }

            }
            .disposed(by: rx.disposeBag)
    }
}

extension AppIconSelectController {
    func setApplicationIconName(_ iconName: String?) {
        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
            
            typealias setAlternateIconName = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError?) -> Void) -> Void
            
            let selectorString = "_setAlternateIconName:completionHandler:"
            
            let selector = NSSelectorFromString(selectorString)
            let imp = UIApplication.shared.method(for: selector)
            let method = unsafeBitCast(imp, to: setAlternateIconName.self)
            method(UIApplication.shared, selector, iconName as NSString?, { error in
                if let error {
                    print("设置 App Icon 出错： \(error)")
                } else {
                    print("App Icon 设置成功")
                }
            })
        }
    }
}

extension AppIconSelectController {
    func startAnimation() {
        UIApplication.shared.beginBackgroundTask()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.appProxy.setAlternateIconName(self.getLogoName()) { _, error  in
                    if let error {
                        print("设置 App Icon 出错： \(error)")
                    } else {
                        print("App Icon 设置成功")
                    }
                }
            }
        }
    }
    
    func getLogoName() -> String {
        if appIconName == AppIconType.swiftStyle.iconName {
            appIconName = AppIconType.flutterStyle.iconName
        } else {
            appIconName = AppIconType.swiftStyle.iconName
        }
        return appIconName
    }
}

/// 通过自定义弹窗干掉系统弹窗
class TransparentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加一个透明背景视图
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backgroundView.frame = view.bounds
        view.addSubview(backgroundView)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // 当系统想要调用弹窗时直接 dismiss 掉
        dismiss(animated: false)
    }
}
