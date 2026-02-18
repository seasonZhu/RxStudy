//
//  CustomTabItem.swift
//  CustomTabBarExample
//
//  Created by Jędrzej Chołuj on 18/12/2021.
//

import UIKit

enum CustomTabItem: String {
    case profile
    case search
    case favorite
    case share
}

extension CustomTabItem: CaseIterable {}
 
extension CustomTabItem {
    var index: Int {
        switch self {
        case .profile:
            return 0
        case .search:
            return 1
        case .favorite:
            return 2
        case .share:
            return 3
        }
    }
    
    var viewController: UIViewController {
        TypeViewController(item: self)
    }
    
    var customItemView: CustomItemView {
        CustomItemView(with: self)
    }
    
    var image: UIImage? {
        switch self {
        case .search:
            return UIImage(systemName: "magnifyingglass.circle")
        case .favorite:
            return UIImage(systemName: "heart.circle")
        case .profile:
            return UIImage(systemName: "person.crop.circle")
        case .share:
            return UIImage(systemName: "square.and.arrow.up.fill")
        }
    }
    
    var icon: UIImage? {
        image?.withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
    }
    
    var selectedIcon: UIImage? {
        image?.withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    var name: String {
        rawValue.capitalized
    }
}
