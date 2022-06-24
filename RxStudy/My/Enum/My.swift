//
//  MyEnum.swift
//  RxStudy
//
//  Created by season on 2021/6/15.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

enum My: CaseIterable {
    case ranking
    case openSource
    case myGitHub
    case myJueJin
    case tools
    case course
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
            string = "积分排名"
        case .openSource:
            string = "\(R.string.infoPlist.wanandroid())开源框架引用"
        case .myGitHub:
            string = "作者的GitHub"
        case .myJueJin:
            string = "作者的掘金"
        case .tools:
            string = "工具列表"
        case .course:
            string = "教程"
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
            string = "ThirdPartyController"
        case .myGitHub:
            string = "MyGitHubController"
        case .myJueJin:
            string = "MyJueJinController"
        case .tools:
            string = "ToolController"
        case .course:
            string = "TabsController"
        case .myCoin:
            string = "MyCoinController"
        case .myCollect:
            string = "MyCollectionController"
        case .login:
            string = "LoginController"
        case .logout:
            string = "Logout"
        }
        return string
    }
}

//MARK: -  这个分类的属性从这里开始就不纯粹了,和UI有关系了,这么设计不知道是
extension My {
    var accessoryType: UITableViewCell.AccessoryType {
        switch self {
        case .logout:
            return .none
        default:
            return .disclosureIndicator
        }
    }
}
