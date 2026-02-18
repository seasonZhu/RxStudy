//
//  UIViewController+Extension.swift
//  RxStudy
//
//  Created by dy on 2025/6/11.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

/*
 获取到的状态栏高度为 0”问题，常见原因如下：

 获取时机太早
 如果在 AppDelegate 的 didFinishLaunchingWithOptions 或 SceneDelegate 的 willConnectTo 里获取，UI 还没布局完成，状态栏高度可能为 0。

 没有激活的 windowScene
 如果 App 还没有 window 或 windowScene 没激活，也会导致拿到 0。
 
 在视图控制器的 viewDidAppear 或 viewDidLayoutSubviews 获取，目前发现在viewDidLoad里面也是可以正常获取到的,就是没法像之前写到Constant里面静态获取了
 */
extension UIViewController {
    var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
}

extension UIView {
    
    /// 解决UI边框为0.5时,绘制不均匀的问题, fillColor不为nil时,可能会盖住view里面内容 https://juejin.cn/post/7534671606074114063
    /// - Parameters:
    ///   - cornerRadius: 倒角
    ///   - strokeColor: 线的颜色
    ///   - lineWidth: 线的宽度
    ///   - fillColor: 填充颜色
    func addShapeLayer(cornerRadius: CGFloat = 8, strokeColor: UIColor, lineWidth: CGFloat = 0.5, fillColor: UIColor? = nil) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = fillColor?.cgColor
        layer.addSublayer(shapeLayer)
    }
}
