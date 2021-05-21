//
//  Api.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct Api {
    /// baseUrl
    static let baseUrl = "https://www.wanandroid.com/"
    
    private init() {}

    enum Home {
        /// 首页
        static let banner = "banner/json"

        static let topArticle = "article/top/json"

        static let normalArticle = "article/list/"

        static let searchHotKey = "hotkey/json"

        static let queryKey = "article/query/"
    }


    /// 项目
    let getProjectClassify = "project/tree/json"

    let getProjectClassifyList = "project/list/"


    /// 公众号
    let getPubilicNumber = "wxarticle/chapters/json"

    let getPubilicNumberList = "wxarticle/list/"


    /// 用户登录注册登出
    let postLogin = "user/login"

    let postRegister = "user/register"

    let getLogout = "user/logout/json"


    /// 我的
    enum My {
        static let postCollectArticle = "lg/collect/"

        static let postUnCollectArticle = "lg/uncollect_originId/"

        static let getCollectArticleList = "lg/collect/list/"

        static let getCoinList = "lg/coin/list/"

        static let getUserCoinInfo = "lg/coin/userinfo/json"

        static let coinRank = "coin/rank/"
    }

    /// 体系
    let getTree = "tree/json"

    let getTreeDetailList = "article/list/"
}
