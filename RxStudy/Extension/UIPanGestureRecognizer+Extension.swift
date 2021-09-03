//
//  UIPanGestureRecognizer+Extension.swift
//  RxStudy
//
//  Created by dy on 2021/9/3.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

extension UIPanGestureRecognizer {
    
    /// 滑动的轴
    ///
    /// - horizontal: 横轴
    /// - vertical: 纵轴
    /// - unknown: 未知
    public enum Axis {
        case horizontal(Direction)
        case vertical(Direction)
        case unknown(Direction)
    }
    
    /// 滑动的方向
    ///
    /// - fromLeftToRight: 从左往右
    /// - fromRightToLeft: 从右往左
    /// - fromTopToBottom: 从上到下
    /// - fromBottomToTop: 从下到上
    /// - unknown: 未知
    public enum Direction {
        case fromLeftToRight
        case fromRightToLeft
        case fromTopToBottom
        case fromBottomToTop
        case unknown
    }
    
    /// 检测滑动的方向
    ///
    /// - Parameters:
    ///   - view: 相对View
    ///   - responseLength: 滑动距离的响应 默认的Int.max 获得的结果是不响应
    /// - Returns: 滑动的轴 是否响应
    public func checkPanGestureAxis(in view: UIView?, responseLength: CGFloat = CGFloat(Int.max)) -> (axis: Axis, response: Bool) {
        let translation = self.translation(in: view)
        let panGestureAxis: Axis
        let response: Bool
        
        switch state {
        case .changed:
            let x = abs(translation.x)
            let y = abs(translation.y)
            
            // 纵向滑动
            if x < y {
                if translation.y > 0 {
                    panGestureAxis = .vertical(.fromTopToBottom)
                }else {
                    panGestureAxis = .vertical(.fromBottomToTop)
                }
                
                response = y > responseLength
            }
            //  横向滑动
            else {
                if translation.x > 0 {
                    panGestureAxis = .horizontal(.fromLeftToRight)
                }else {
                    panGestureAxis = .horizontal(.fromRightToLeft)
                }
               response = x > responseLength
            }
        default:
            panGestureAxis = .unknown(.unknown)
            response = false
        }
        
        return (panGestureAxis, response)
    }
}

