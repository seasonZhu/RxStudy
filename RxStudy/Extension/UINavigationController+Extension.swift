//
//  UINavigationController+Extension.swift
//  RxStudy
//
//  Created by dy on 2025/3/10.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

extension UINavigationController {
    /// 其实这种删除实例的方法是没有意义的,除非在push到下一个页面的时候,将当前页面的实例带过去,才会发现该实例与viewControllers的实例是一致的,但凡new一个都删除不了
    /// 建议用下面两种removeViewControllerByTypes和removeViewControllerByClassNames
    func removeViewController(_ controller: UIViewController, animated flag: Bool) {
        var controllers = viewControllers
        var controllerToRemove: UIViewController?
        
        for obj in controllers where obj == controller {
            controllerToRemove = obj
        }
        
        if let controllerToRemove = controllerToRemove {
            if let index = controllers.firstIndex(of: controllerToRemove) {
                controllers.remove(at: index)
                setViewControllers(controllers, animated: true)
            }
        }
    }
    
    func removeViewControllerByTypes(_ types: [UIViewController.Type], animated flag: Bool) {
        var controllers = viewControllers
        var controllersToRemove: [UIViewController] = []
        
        for obj in controllers {
            let type = type(of: obj)
            
            if types.contains(where: { $0 == type}) {
                controllersToRemove.append(obj)
            }
        }
        
        for removeVC in controllersToRemove {
            if let index = controllers.firstIndex(of: removeVC) {
                controllers.remove(at: index)
            }
        }
        
        setViewControllers(controllers, animated: true)
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
        
        setViewControllers(controllers, animated: true)
    }
}
