//
//  AppDelegate.swift
//  AppTemplate
//
//  应用入口文件
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 创建窗口
        window = UIWindow(frame: UIScreen.main.bounds)

        // 创建根视图控制器
        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
