//
//  Theme.swift
//  RxStudy
//
//  Created by dy on 2022/11/1.
//  Copyright © 2022 season. All rights reserved.
//

import RxTheme

protocol Theme {
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
}

struct LightTheme: Theme {
    let backgroundColor = UIColor.white
    let textColor = UIColor.black
}

struct DarkTheme: Theme {
    let backgroundColor = UIColor.black
    let textColor = UIColor.white
}

enum ThemeType {
    
    case light
    
    case dark
}

extension ThemeType: ThemeProvider {
    
    var associatedObject: Theme {
        switch self {
        case .light:
            return LightTheme()
        case .dark:
            return DarkTheme()
        }
    }
}

/// 主题服务
let themeService = ThemeType.service(initial: .light)

/// 主题反转
func themeTriggered() {
    switch themeService.type {
    case .light:
        themeService.switch(.dark)
    case .dark:
        themeService.switch(.light)
    }
}

/// 触控反馈
enum Haptics {
    case success
    case warning
    case error
}

extension Haptics {
    func feedback() {
        let generator = UINotificationFeedbackGenerator()
        switch self {
        case .success:
            generator.notificationOccurred(.success)
        case .warning:
            generator.notificationOccurred(.warning)
        case .error:
            generator.notificationOccurred(.error)
        }
    }
}
