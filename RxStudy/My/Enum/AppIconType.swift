//
//  AppIconType.swift
//  RxStudy
//
//  Created by dy on 2025/2/7.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

enum AppIconType: CaseIterable {
    case swiftStyle
    case flutterStyle
    case onBackgroundTimer
}

extension AppIconType {
    var iconName: String {
        switch self {
        case .swiftStyle:
            return "AppIcon-Swift"
        case .flutterStyle:
            return "AppIcon-Flutter"
        case .onBackgroundTimer:
            return "AppIcon-Swift"
        }
    }
    
    var title: String {
        switch self {
        case .swiftStyle:
            return "默认"
        case .flutterStyle:
            return "Flutter风格"
        case .onBackgroundTimer:
            return "后台计时器"
        }
    }
}
