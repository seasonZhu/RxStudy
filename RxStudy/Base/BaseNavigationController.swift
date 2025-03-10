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
        // leftPanBankSettingAction()
    }
    
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        if AccountManager.shared.isLoginRelay.value == true {
//            if self.children.count >= 1 {
//                viewController.hidesBottomBarWhenPushed = true
//            }
//            super.pushViewController(viewController, animated: animated)
//        } else {
//            super.pushViewController(LoginController(), animated: animated)
//        }
//        
//    }
    
}

extension BaseNavigationController: UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
        /// 解决某些情况下push时的假死bug，防止把根控制器pop掉
        if navigationController.viewControllers.count == 1 {
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
            
            if panResult.response, case UIPanGestureRecognizer.Axis.horizontal(.fromRightToLeft) = panResult.axis {
                popViewController(animated: true)
            }
        }
    }
}

extension UINavigationController {
    enum RemoveVCType {
        case instance(UIViewController)
        case classType(UIViewController.Type)
        case className(String)
        
        func isFindController(_ controller: UIViewController) -> Bool {
            switch self {
            case .instance(let viewController):
                return controller == viewController
            case .classType(let type):
                return controller.isKind(of: type)
            case .className(let string):
                return controller.className == string
            }
        }
    }
    
    func removeViewController(_ type: RemoveVCType, animated flag: Bool) {
        var controllers = viewControllers
        var controllerToRemove: UIViewController?
        
        for controller in controllers where type.isFindController(controller) {
            controllerToRemove = controller
            break
        }
        
        if let controllerToRemove = controllerToRemove,
           let index = controllers.firstIndex(of: controllerToRemove) {
            controllers.remove(at: index)
            self.setViewControllers(controllers, animated: true)
        }
    }
}

extension UINavigationController {
    
    func removeViewController(_ controller: UIViewController, animated flag: Bool) {
        var controllers = viewControllers
        var controllerToRemove: UIViewController?
        
        for obj in controllers {
            if obj == controller {
                controllerToRemove = obj
                break
            }
        }
        
        if let controllerToRemove = controllerToRemove {
            if let index = controllers.firstIndex(of: controllerToRemove) {
                controllers.remove(at: index)
                setViewControllers(controllers, animated: true)
            }
        }
    }
    
    func removeViewControllerByType(_ type: UIViewController.Type, animated flag: Bool) {
        var controllers = viewControllers
        var controllerToRemove: UIViewController?
        
        for obj in controllers {
            if obj.isKind(of: type) {
                controllerToRemove = obj
                break
            }
        }
        
        if let controllerToRemove = controllerToRemove {
            if let index = controllers.firstIndex(of: controllerToRemove) {
                controllers.remove(at: index)
                setViewControllers(controllers, animated: true)
            }
        }
    }
    
    func removeViewControllerByClassName(_ className: String, animated flag: Bool) {
        var controllers = viewControllers
        var controllerToRemove: UIViewController?
        
        for obj in controllers {
            if obj.className == className {
                controllerToRemove = obj
                break
            }
        }
        
        if let controllerToRemove = controllerToRemove {
            if let index = controllers.firstIndex(of: controllerToRemove) {
                controllers.remove(at: index)
                self.setViewControllers(controllers, animated: true)
            }
        }
    }
    
    
    func removeViewControllerByClassNames(_ classNames: [String], animated flag: Bool) {
        var controllers = viewControllers
        var controllersToRemove: [UIViewController] = []
        
        for obj in controllers where classNames.contains(obj.className) {
            controllersToRemove.append(obj)
        }
        
        for removeVC in controllersToRemove {
            if let index = controllers.firstIndex(of: removeVC) {
                controllers.remove(at: index)
            }
        }
        
        self.setViewControllers(controllers, animated: true)
    }
}
