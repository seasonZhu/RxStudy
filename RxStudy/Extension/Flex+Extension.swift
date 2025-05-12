//
//  Flex+Extension.swift
//  RxStudy
//
//  Created by dy on 2025/5/12.
//  Copyright © 2025 season. All rights reserved.
//

import FlexLayout

extension Flex {
    
    /// 添加一个撑满的间隙
    @discardableResult
    func addSpacer(_ value: CGFloat = 1) -> Flex {
        addItem().grow(value).shrink(value)
    }
    
    /// 创建行
    func row() -> Flex {
        direction(.row)
    }
    
    /// 创建列
    func column() -> Flex {
        direction(.column)
    }
    
    /// 是否进行布局计算及显示
    var isLayoutAndShow: Bool {
        set {
            isIncludedInLayout = newValue
            self.view?.isHidden = !newValue
        }
        get {
            return isIncludedInLayout && (self.view?.isHidden ?? false)
        }
    }
}
