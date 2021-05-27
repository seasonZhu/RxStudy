//
//  TagType.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya

enum TagType {
    case project
    case publicNumber
    case tree
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
        }
    }
}
