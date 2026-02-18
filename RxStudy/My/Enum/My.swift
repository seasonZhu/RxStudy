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
    case myMessage
    case aSwiftUI
    case appIcon
    case treeCellStyleChange
    case flutterModule
    case uniMPModule
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
            string = "玩安卓开源框架引用"
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
        case .myMessage:
            string = "我的站内消息"
        case .aSwiftUI:
            string = "一个SwiftUI的简单例子"
        case .appIcon:
            string = "更换App图标"
        case .treeCellStyleChange:
            string = "更换体系Cell布局"
        case .flutterModule:
            string = "Flutter玩安卓模块"
        case .uniMPModule:
            string = "UniApp玩安卓模块"
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
        case .myMessage:
            string = "MyMessageController"
        case .aSwiftUI:
            string = "aSwiftUI"
        case .appIcon:
            string = "AppIconSelectController"
        case .treeCellStyleChange:
            string = "TreeCellStyleChangeController"
        case .flutterModule:
            string = "FlutterViewController"
        case .uniMPModule:
            string = "uniMPModule"
        case .login:
            string = "LoginController"
        case .logout:
            string = "Logout"
        }
        return string
    }
}

// MARK: - 这个分类的属性从这里开始就不纯粹了,和UI有关系了,这么设计不知道是好还是坏
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

extension My {
    static let logoutDataSource: [My] = [.myGitHub, .myJueJin, .aSwiftUI, .openSource, .tools, .course, .ranking, .appIcon, .treeCellStyleChange, .flutterModule, .uniMPModule, .login]
    
    static let loginDataSource: [My] = [.myGitHub, .myJueJin, .aSwiftUI, .openSource, .tools, .course, .ranking, .appIcon, .treeCellStyleChange, .flutterModule, .uniMPModule, .myCoin, .myCollect, .myMessage, .logout]
}
