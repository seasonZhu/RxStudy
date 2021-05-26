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

    /// 首页 均是get请求
    enum Home {
        
        static let banner = "banner/json"

        static let topArticle = "article/top/json"

        static let normalArticle = "article/list/"

        static let searchHotKey = "hotkey/json"

        static let queryKey = "article/query/"
    }

    /// 项目 均是get请求
    enum Project {
        static let tags = "project/tree/json"
        
        static let tagList = "project/list/"
    }

    /// 公众号 均是get请求
    enum PublicNumber {
        static let tags = "wxarticle/chapters/json"

        static let tagList = "wxarticle/list/"
    }
    
    /// 体系 均是get请求
    enum Tree {
        
        static let tags = "tree/json"

        static let tagList = "article/list/"
    }

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
}
