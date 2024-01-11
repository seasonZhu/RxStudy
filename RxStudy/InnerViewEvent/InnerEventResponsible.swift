//
//  InnerEventResponsible.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation

protocol InnerEventConvertible {}

/// 响应子View的外层View去实现这个具体方法
protocol InnerEventResponsible: UIResponder {
    func innerEventHandle(event: any InnerEventConvertible)
}

protocol BubbleEventProtocol {
    func bubbleEvent(_ event: any InnerEventConvertible)
}

/// 冒泡方法在内层子View中实现
extension UIView: BubbleEventProtocol {
    /// 一个沿着响应链向上传递事件的方法，bubble=冒泡
    func bubbleEvent(_ eventType: any InnerEventConvertible) {
        var nextRespnder = next
        while nextRespnder != nil {
            if let savior = nextRespnder as? InnerEventResponsible {
                savior.innerEventHandle(event: eventType)
                nextRespnder = nil
            }
            nextRespnder = nextRespnder?.next
        }
     }
}

/// 因为存在vc里面添加一个addChildController的情况,所以这里还是实现了
extension UIViewController: BubbleEventProtocol {
    /// 一个沿着响应链向上传递事件的方法，bubble=冒泡
    func bubbleEvent(_ eventType: any InnerEventConvertible) {
        var nextRespnder = next
        while nextRespnder != nil {
            if let savior = nextRespnder as? InnerEventResponsible {
                savior.innerEventHandle(event: eventType)
                nextRespnder = nil
            }
            nextRespnder = nextRespnder?.next
        }
     }
}
