//
//  Info.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

/// 单个信息模型,用于首页,项目,公众号,搜索关键词,体系,收藏夹
public struct Info: Codable {
    public var title: String?

    public var link: String?
    /// 我的收藏接口originId才是文章的标识符,id没有用,不要使用
    public var originId: Int?
    /// 不是我的收藏接口,拿到的id就是文章的标识符,需要通过这个字段进行收藏与取消收藏的操作,此时originId为nil
    public var id: Int?

    public let apkLink: String?
    public let audit: Int?
    public let author: String?
    public let canEdit: Bool?
    public let chapterId: Int?
    public let chapterName: String?
    public let collect: Bool?
    public let courseId: Int?
    public let desc: String?
    public let descMd: String?
    public let envelopePic: String?
    public let fresh: Bool?

    public let niceDate: String?
    public let niceShareDate: String?
    public let origin: String?

    public let prefix: String?
    public let projectLink: String?
    public let publishTime: Int?
    public let selfVisible: Int?
    public let shareDate: Int?
    public let shareUser: String?
    public let superChapterId: Int?
    public let superChapterName: String?
    public let tags: [Tag]?

    public let type: Int?
    public let userId: Int?
    public let visible: Int?
    public let zan: Int?
}

extension Info: WebLoadInfo {}

public struct Tag: Codable {
    public let name: String?
    public let url: String?
}
