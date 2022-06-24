//
//  TagType.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

enum TagType {
    case project
    case publicNumber
    case tree
    case course
}

extension TagType {
    var title: String {
        switch self {
        case .project:
            return "项目"
        case .publicNumber:
            return "公众号"
        case .tree:
            return "体系"
        case .course:
            return "教程"
        }
    }
    
    var pageNum: Int {
        switch self {
        case .project:
            return 1
        case .publicNumber:
            return 1
        case .tree:
            return 0
        case .course:
            return 0
        }
    }
}
