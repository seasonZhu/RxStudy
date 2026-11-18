//
//  AppIconType.swift
//  RxStudy
//
//  Created by dy on 2025/2/7.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

enum AppIconType: CaseIterable {
    case primary
    case swiftStyle
    case flutterStyle
}

extension AppIconType {
    var iconName: String? {
        switch self {
        case .primary:
            return nil
        case .swiftStyle:
            return "AppIcon-Swift"
        case .flutterStyle:
            return "AppIcon-Flutter"
        }
    }
    
    var title: String {
        switch self {
        case .primary:
            return "默认"
        case .swiftStyle:
            return "Swift 风格"
        case .flutterStyle:
            return "Flutter 风格"
        }
    }
}
