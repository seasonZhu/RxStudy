//
//  CommonModels.swift
//  RxStudy - SwiftUIApp
//
//  通用数据模型
//

import Foundation

// MARK: - 热词模型

struct HotKeyModel: Codable, Identifiable {
    let id: Int?
    let link: String?
    let name: String?
    let order: Int?
    let visible: Int?
}

// MARK: - 通用文章模型（用于首页、项目、公众号、体系、搜索等）

struct InfoModel: Codable, Identifiable {
    var title: String?
    var link: String?
    var originId: Int?
    var id: Int?

    let apkLink: String?
    let audit: Int?
    let author: String?
    let canEdit: Bool?
    let chapterId: Int?
    let chapterName: String?
    let collect: Bool?
    let courseId: Int?
    let desc: String?
    let descMd: String?
    let envelopePic: String?
    let fresh: Bool?
    let top: Bool?

    let niceDate: String?
    let niceShareDate: String?
    let origin: String?

    let prefix: String?
    let projectLink: String?
    let publishTime: Int?
    let selfVisible: Int?
    let shareDate: Int?
    let shareUser: String?
    let superChapterId: Int?
    let superChapterName: String?
    let tags: [TagModel]?

    let type: Int?
    let userId: Int?
    let visible: Int?
    let zan: Int?
}

struct TagModel: Codable {
    let name: String?
    let url: String?
}

// MARK: - 项目相关模型

struct ProjectTagModel: Codable, Identifiable {
    let id: Int?
    let name: String?
    let children: [ProjectChildTagModel]?
}

struct ProjectChildTagModel: Codable, Identifiable {
    let id: Int?
    let name: String?
}

// MARK: - 公众号相关模型

struct PublicNumberTagModel: Codable, Identifiable {
    let id: Int?
    let name: String?
}

// MARK: - 账号相关模型

struct UserInfoModel: Codable {
    let admin: Bool?
    let chapterTops: [String]?
    let collectIds: [Int]?
    let email: String?
    let icon: String?
    let id: Int?
    let nickname: String?
    let password: String?
    let publicName: String?
    let token: String?
    let type: Int?
    let username: String?
}

// MARK: - 体系相关模型

struct TreeTagModel: Codable, Identifiable {
    let id: Int?
    let name: String?
    let children: [TreeChildTagModel]?
}

struct TreeChildTagModel: Codable, Identifiable {
    let id: Int?
    let name: String?
}

// MARK: - 兼容性别名

// 文章模型别名
typealias TreeArticleModel = InfoModel
typealias ProjectArticleModel = InfoModel
typealias PublicNumberArticleModel = InfoModel
typealias HomeArticleModel = InfoModel
typealias CollectArticleModel = InfoModel
