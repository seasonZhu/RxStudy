//
//  BaseNavigationController.swift
//  RxStudy
//
//  Created by season on 2021/6/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    /**
     - (void)viewDidLoad {
         [super viewDidLoad];
         self.interactivePopGestureRecognizer.delegate = self;
         self.delegate = self;
     }

     #pragma mark - UINavigationControllerDelegate
     // 当控制器显示完毕的时候调用
     - (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
         self.interactivePopGestureRecognizer.enabled = YES;
         // 解决某些情况下push时的假死bug，防止把根控制器pop掉
         if (navigationController.viewControllers.count == 1) {
             self.interactivePopGestureRecognizer.enabled = NO;
         }
     }
     */

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
