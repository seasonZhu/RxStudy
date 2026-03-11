//
//  Page.swift
//  RxStudy - Shared
//
//  通用分页模型
//

import Foundation

/// 有分页的基础模型
struct Page<Content: Codable>: Codable {
    let curPage: Int?
    let datas: [Content]?
    let offset: Int?
    let over: Bool?
    let pageCount: Int?
    let size: Int?
    let total: Int?
}

extension Page {
    /// 判断是否还有更多数据
    var hasMore: Bool {
        guard let cur = curPage, let total = pageCount else { return false }
        return cur < total
    }

    /// 判断是否没有更多数据了
    var isNoMoreData: Bool {
        guard let curPage = curPage, let pageCount = pageCount else { return false }
        return curPage == pageCount
    }
}

