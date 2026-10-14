//
//  WebLoadInfo.swift
//  RxStudy - Shared
//
//  Web 加载信息协议
//

import Foundation

public protocol WebLoadInfo {
    var id: Int? { get set }
    var originId: Int? { get set }
    var title: String? { get set }
    var link: String? { get }
}
