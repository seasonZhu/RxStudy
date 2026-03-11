//
//  BaseModel.swift
//  RxStudy - Shared
//
//  基础响应模型定义
//

import Foundation

/// 基础响应模型
public struct BaseModel<T: Codable>: Codable {
    public let data: T?
    public let errorCode: Int?
    public let errorMsg: String?

    public var isSuccess: Bool {
        errorCode == 0
    }
}
