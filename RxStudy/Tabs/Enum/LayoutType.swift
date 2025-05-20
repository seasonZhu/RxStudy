//
//  LayoutType.swift
//  RxStudy
//
//  Created by dy on 2025/5/20.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

enum LayoutType: CaseIterable {
    case wrap
    case list
}

extension LayoutType {
    var title: String {
        switch self {
        case .wrap:
            return "换行布局"
        case .list:
            return "列表布局"
        }
    }
}
