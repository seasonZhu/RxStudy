//
//  InnerEventResponsible.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation

protocol InnerEventConvertible {}

protocol InnerEventResponsible: UIResponder {
    func innerEventHandle(event: any InnerEventConvertible)
}

protocol BubbleEventProtocol {
    func bubbleEvent(_ event: any InnerEventConvertible)
}

extension UIView: BubbleEventProtocol {
    /// 一个沿着响应链向上传递事件的方法，bubble=冒泡
    func bubbleEvent(_ eventType: any InnerEventConvertible) {
        var nextRespnder = self.next
        while nextRespnder != nil {
            if let savior = nextRespnder as? InnerEventResponsible {
                savior.innerEventHandle(event: eventType)
                nextRespnder = nil
            }
            nextRespnder = nextRespnder?.next
        }
     }
}

extension UIViewController: BubbleEventProtocol {
    /// 一个沿着响应链向上传递事件的方法，bubble=冒泡
    func bubbleEvent(_ eventType: any InnerEventConvertible) {
        var nextRespnder = self.next
        while nextRespnder != nil {
            if let savior = nextRespnder as? InnerEventResponsible {
                savior.innerEventHandle(event: eventType)
                nextRespnder = nil
            }
            nextRespnder = nextRespnder?.next
        }
     }
}
