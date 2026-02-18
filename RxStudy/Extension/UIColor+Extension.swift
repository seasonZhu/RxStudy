//
//  UIColor+Extension.swift
//  RxStudy
//
//  Created by season on 2021/7/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import SwiftUI

// MARK: - - LightMode与DarkMode的颜色思路
extension UIColor {
    /// 便利构造函数(配合cssHex函数使用 更好)
    /// - Parameters:
    ///   - lightThemeColor: 明亮主题的颜色
    ///   - darkThemeColor: 黑暗主题的颜色
    public convenience init(lightThemeColor: UIColor, darkThemeColor: UIColor? = nil) {
        if #available(iOS 13.0, *) {
            self.init { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case .light:
                        return lightThemeColor
                    case .unspecified:
                        return lightThemeColor
                    case .dark:
                        return darkThemeColor ?? lightThemeColor
                    @unknown default:
                        fatalError()
                }
            }
        } else {
            /// 是我自己小看了这里,因为是一个便利构造函数,所以这里必须使用一级构造函数
            self.init(cgColor: lightThemeColor.cgColor)
            // self.init(Color(uiColor: lightThemeColor))
        }
    }
}

extension UIColor {
    
    /// 随机颜色
    static var random: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return  UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIColor {
    
    /// 文字颜色 light为黑 dark为白
    static let playAndroidTitle = UIColor(lightThemeColor: .black, darkThemeColor: .white)
    
    /// 背景颜色 light为白 dark为黑
    static let playAndroidBackground = UIColor(lightThemeColor: .white, darkThemeColor: .black)
}
