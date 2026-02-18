//
//  Page.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

/// 有分页的基础模型
public struct Page<Content: Codable>: Codable {
    public let curPage: Int?
    public let datas: [Content]?
    public let offset: Int?
    public let over: Bool?
    public let pageCount: Int?
    public let size: Int?
    public let total: Int?
}

public extension Page {
    /// 自定义属性来判断是否到底了,其实let over : Bool也是可以判断
    var isNoMoreData: Bool {
        /// 解包数据
        if let curPage = curPage, let pageCount = pageCount {
            /// 相等就是没有数据
            if curPage == pageCount {
                return true
            } else {
                return false
            }
        }
        return false
    }
}
