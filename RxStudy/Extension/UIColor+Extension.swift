//
//  UIColor+Extension.swift
//  RxStudy
//
//  Created by season on 2021/7/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

//MARK: - - LightMode与DarkMode的颜色思路
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
            self.init(cgColor: lightThemeColor.cgColor)
        }
    }
}

extension UIColor {
    
    /// 文字颜色 light为黑 dark为白
    static let playAndroidTitle = UIColor(lightThemeColor: .black, darkThemeColor: .white)
    
    /// 背景颜色 light为白 dark为黑
    static let playAndroidBg = UIColor(lightThemeColor: .white, darkThemeColor: .black)
}

@available(iOS 12.0, *)
extension UITraitCollection {
    static var isDark: Bool { UITraitCollection().isDark }
    
    static var isLight: Bool { UITraitCollection().isLight }
    
    static var isUnspecified: Bool  { UITraitCollection().isUnspecified }
    
    var isDark: Bool { userInterfaceStyle == .dark }
    
    var isLight: Bool { userInterfaceStyle == .light }
    
    var isUnspecified: Bool  { userInterfaceStyle == .unspecified }
}
