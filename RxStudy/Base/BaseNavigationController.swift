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
        //leftPanBankSettingAction()
        grayMode()
    }
    
    private func grayMode() {
        if AccountManager.shared.isGrayMode {
            let overlay = GrayView(frame: view.bounds)
            view.addSubview(overlay)
            view.bringSubviewToFront(overlay)
        }
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

/// 之前看一个视频说iOS没有向左滑返回,导致大屏手机从左向右滑的边缘侧滑手势非常的尴尬
extension BaseNavigationController {
    private func leftPanBankSettingAction() {
        let pan = UIPanGestureRecognizer()
        view.addGestureRecognizer(pan)
        pan.addTarget(self, action: #selector(panAction(_ :)))
    }
    
    @objc
    private func panAction(_ pan: UIPanGestureRecognizer) {
        if viewControllers.count > 1 {
            let panResult = pan.checkPanGestureAxis(in: self.view, responseLength: 150)
            
            if panResult.response, case UIPanGestureRecognizer.Axis.horizontal(.fromRightToLeft) = panResult.axis  {
                popViewController(animated: true)
            }
        }
    }
}
