//
//  UITraitCollection+Extension.swift
//  RxStudy
//
//  Created by dy on 2022/2/9.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

/// UITraitCollection.current.userInterfaceStyle获取的值并不每次都正确,不要这么使用
/// 详细请看: https://www.jianshu.com/p/af9ab7a33e8f

@available(iOS 13.0, *)
extension UITraitCollection {
    static var isDark: Bool { UITraitCollection.current.isDark }
    
    static var isLight: Bool { UITraitCollection.current.isLight }
    
    static var isUnspecified: Bool { UITraitCollection.current.isUnspecified }
    
    var isDark: Bool { userInterfaceStyle == .dark }
    
    var isLight: Bool { userInterfaceStyle == .light }
    
    var isUnspecified: Bool { userInterfaceStyle == .unspecified }
}
