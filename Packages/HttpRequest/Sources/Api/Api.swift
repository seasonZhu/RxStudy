//
//  Api.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

public enum Api {
    /// baseUrl
    public static let baseUrl = "https://www.wanandroid.com/"

    /// 新的baseUrl,目前感觉两个都在同时使用
    public static let newBaseUrl = "https://wanandroid.com/"
}

public extension Api {
    /// 首页 queryKeyword是post请求 其他的是get请求
    enum Home {
        public static let banner = "banner/json"

        public static let topArticle = "article/top/json"

        public static let normalArticle = "article/list/"

        public static let hotKey = "hotkey/json"

        public static let queryKeyword = "article/query/"
    }
}

public extension Api {
    /// 项目 均是get请求
    enum Project {
        public static let tags = "project/tree/json"

        public static let tagList = "project/list/"
    }
}

public extension Api {
    /// 公众号 均是get请求
    enum PublicNumber {
        public static let tags = "wxarticle/chapters/json"

        public static let tagList = "wxarticle/list/"
    }
}

public extension Api {
    /// 用户登录注册登出 登录注册为post 登出为get
    enum Account {
        public static let login = "user/login"

        public static let register = "user/register"

        public static let logout = "user/logout/json"
    }
}

public extension Api {
    /// 体系 均是get请求
    enum Tree {
        public static let tags = "tree/json"

        public static let tagList = "article/list/"
    }
}

public extension Api {
    /// 我的 取消收藏和点击收藏操作为post,其他为get
    enum My {
        public static let coinRank = "coin/rank/"

        public static let userCoinInfo = "lg/coin/userinfo/json"

        public static let myCoinList = "lg/coin/list/"

        public static let collectArticleList = "lg/collect/list/"

        public static let collectArticle = "lg/collect/"

        public static let unCollectArticle = "lg/uncollect_originId/"

        public static let unreadCount = "message/lg/count_unread/json"

        public static let unreadList = "message/lg/unread_list/"

        public static let readList = "message/lg/readed_list/"
    }
}

public extension Api {
    enum Other {
        public static let tools = "tools/list/json"

        /// 问答和工具在数据结构与页面样式一模一样,所以就不再不停的重复写了
        public static let questionAndAnswer = "wenda/list/"

        /// 常用网站
        public static let friend = "friend/json"

        /// 导航
        public static let navi = "navi/json"
    }
}

public extension Api {
    enum Course {
        public static let tags = "chapter/547/sublist/json"

        public static let tagList = "article/list/"
    }
}
