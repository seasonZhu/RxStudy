//
//  Api.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

enum Api {
    /// baseUrl
    static let baseUrl = "https://www.wanandroid.com/"
    
    /// 新的baseUrl,目前感觉两个都在同时使用
    static let newBaseUrl = "https://wanandroid.com/"
}

extension Api {
    /// 首页 queryKeyword是post请求 其他的是get请求
    enum Home {
        
        static let banner = "banner/json"

        static let topArticle = "article/top/json"

        static let normalArticle = "article/list/"

        static let hotKey = "hotkey/json"

        static let queryKeyword = "article/query/"
    }
}

extension Api {
    /// 项目 均是get请求
    enum Project {
        static let tags = "project/tree/json"
        
        static let tagList = "project/list/"
    }
}

extension Api {
    /// 公众号 均是get请求
    enum PublicNumber {
        static let tags = "wxarticle/chapters/json"

        static let tagList = "wxarticle/list/"
    }
}

extension Api {
    /// 用户登录注册登出 登录注册为post 登出为get
    enum Account {
        static let login = "user/login"

        static let register = "user/register"

        static let logout = "user/logout/json"
    }
}

extension Api {
    /// 体系 均是get请求
    enum Tree {
        
        static let tags = "tree/json"

        static let tagList = "article/list/"
    }
}

extension Api {
    /// 我的 取消收藏和点击收藏操作为post,其他为get
    enum My {
        static let coinRank = "coin/rank/"
        
        static let userCoinInfo = "lg/coin/userinfo/json"
        
        static let myCoinList = "lg/coin/list/"
        
        static let collectArticleList = "lg/collect/list/"
        
        static let collectArticle = "lg/collect/"

        static let unCollectArticle = "lg/uncollect_originId/"
        
        static let unreadCount = "message/lg/count_unread/json"
        
        static let unreadList = "message/lg/unread_list/"
        
        static let readList = "message/lg/readed_list/"
    }
}

extension Api {
    enum Other {
        static let tools = "tools/list/json"
        
        /// 问答和工具在数据结构与页面样式一模一样,所以就不再不停的重复写了
        static let questionAndAnswer = "wenda/list/"
        
        /// 常用网站
        static let friend = "friend/json"
        
        /// 导航
        static let navi = "navi/json"
    }
}

extension Api {
    enum Course {
        static let tags = "chapter/547/sublist/json"
        
        static let tagList = "article/list/"
    }
}

extension Api {
    enum Mock {
        static let mourn = "mourn/json"
    }
}
