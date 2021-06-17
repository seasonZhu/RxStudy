//
//  MyEnum.swift
//  RxStudy
//
//  Created by season on 2021/6/15.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

enum My {
    case ranking
    case openSource
    case myCoin
    case myCollect
    case login
    case logout
}

extension My {
    var title: String {
        let string: String
        switch self {
        case .ranking:
            string = "排名"
        case .openSource:
            string = "开源框架引用"
        case .myCoin:
            string = "我的积分"
        case .myCollect:
            string = "我的收藏"
        case .login:
            string = "登录"
        case .logout:
            string = "登出"
        }
        return string
    }
    
    var imageName: String? {
        return nil
    }
        
    var path: String {
        let string: String
        switch self {
        case .ranking:
            string = "CoinRankListController"
        case .openSource:
            string = "AcknowListViewController"
        case .myCoin:
            string = "MyCoinController"
        case .myCollect:
            string = "MyCollectionController"
        case .login:
            string = "LoginController"
        case .logout:
            string = "logout"
        }
        return string
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        switch self {
        case .logout:
            return .none
        default:
            return .disclosureIndicator
        }
    }
}
