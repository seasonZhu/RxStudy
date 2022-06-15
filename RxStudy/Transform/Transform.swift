//
//  Transform.swift
//  RxStudy
//
//  Created by season on 2021/8/2.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

private let kPadding: CGFloat  = 10

private let kDamping: CGFloat  = 0.75

private let kVelocity: CGFloat = 2

/// TabbarController的动画转换器
class Transform: NSObject {
    
    var preIndex: Int
    
    var selectedIndex: Int
    
    override init() {
        preIndex = 0
        selectedIndex = 0
        super.init()
    }

}

extension Transform: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let tabVC  = tabBarController as? ViewController else {
            return nil
        }
        
        return tabVC.transform
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        debugLog("shouldSelect--即将显示的控制器--\(viewController.className)")
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        debugLog("didSelect--当前显示的控制器--\(viewController.className)")
        tabBarController.title = viewController.title
    }
}

extension Transform: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        let translationX = containerView.bounds.size.width + kPadding
        let cgAffineTransform = CGAffineTransform(translationX: preIndex > selectedIndex ? translationX : -translationX, y: 0)
        
        toViewController.view.transform = cgAffineTransform.inverted()
        
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: kDamping, initialSpringVelocity: kVelocity, options: .curveEaseInOut) {
            fromViewController.view.transform = cgAffineTransform
            toViewController.view.transform = .identity
        } completion: { _ in
            fromViewController.view.transform = .identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
}
