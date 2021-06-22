//
//  Info.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

/// 单个信息模型,用于首页,项目,公众号,搜索关键词,体系,收藏夹
struct Info : Codable {
    
    var title : String?
    
    var link: String?
    /// 我的收藏接口originId才是文章的标识符,id没有用,不要使用
    var originId: Int?
    /// 不是我的收藏接口,拿到的id就是文章的标识符,需要通过这个字段进行收藏与取消收藏的操作,此时originId为nil
    var id : Int?
    
    let apkLink : String?
    let audit : Int?
    let author : String?
    let canEdit : Bool?
    let chapterId : Int?
    let chapterName : String?
    let collect : Bool?
    let courseId : Int?
    let desc : String?
    let descMd : String?
    let envelopePic : String?
    let fresh : Bool?

    
    let niceDate : String?
    let niceShareDate : String?
    let origin : String?

    let prefix : String?
    let projectLink : String?
    let publishTime : Int?
    let selfVisible : Int?
    let shareDate : Int?
    let shareUser : String?
    let superChapterId : Int?
    let superChapterName : String?
    let tags : [Tag]?

    let type : Int?
    let userId : Int?
    let visible : Int?
    let zan : Int?
}

extension Info: WebLoadInfo {}

struct Tag : Codable {

    let name : String?
    let url : String?
}
