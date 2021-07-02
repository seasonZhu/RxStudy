//
//  BaseNavigationController.swift
//  RxStudy
//
//  Created by season on 2021/6/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
    }
    
}

extension BaseNavigationController: UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
        /// 解决某些情况下push时的假死bug，防止把根控制器pop掉
        if (navigationController.viewControllers.count == 1) {
            interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
