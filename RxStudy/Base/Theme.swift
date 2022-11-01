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

let themeService = ThemeType.service(initial: .light)

