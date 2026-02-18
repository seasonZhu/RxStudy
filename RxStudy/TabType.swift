//
//  TabType.swift
//  RxStudy
//
//  Created by dy on 2025/3/7.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import UIKit

enum TabType: CaseIterable {
    case home
    case project
    case publicNumber
    case tree
    case my
}

extension TabType {
    var viewController: UIViewController {
        switch self {
        case .home:
            return HomeController()
        case .project:
            return TabsController(type: .project)
        case .publicNumber:
            return TabsController(type: .publicNumber)
        case .tree:
            return TreeController(type: .tree)
        case .my:
            return MyController()
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "首页"
        case .project:
            return "项目"
        case .publicNumber:
            return "公众号"
        case .tree:
            return "体系"
        case .my:
            return "我的"
        }
    }
    
    var imageName: String {
        switch self {
        case .home:
            return "home"
        case .project:
            return "project"
        case .publicNumber:
            return "publicNumber"
        case .tree:
            return "tree"
        case .my:
            return "my"
        }
    }

    var selectImageName: String {
        switch self {
        case .home:
            return "home_selected"
        case .project:
            return "project_selected"
        case .publicNumber:
            return "publicNumber_selected"
        case .tree:
            return "tree_selected"
        case .my:
            return "my_selected"
        }
    }
}
