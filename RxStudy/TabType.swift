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

    /// ✅ 使用 SwiftGen 生成的类型安全图片资源
    var image: UIImage {
        switch self {
        case .home:
          return Asset.home.image
        case .project:
            return Asset.project.image
        case .publicNumber:
            return Asset.publicNumber.image
        case .tree:
            return Asset.tree.image
        case .my:
            return Asset.my.image
        }
    }

    /// ✅ 使用 SwiftGen 生成的类型安全选中图片资源
    var selectedImage: UIImage {
        switch self {
        case .home:
            return Asset.homeSelected.image
        case .project:
            return Asset.projectSelected.image
        case .publicNumber:
            return Asset.publicNumberSelected.image
        case .tree:
            return Asset.treeSelected.image
        case .my:
            return Asset.mySelected.image
        }
    }
}
