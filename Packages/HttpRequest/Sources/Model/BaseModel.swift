//
//  BaseModel.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

public struct BaseModel<T: Codable>: Codable {
    public let data: T?
    public let errorCode: Int?
    public let errorMsg: String?

    public init(data: T?, errorCode: Int?, errorMsg: String?) {
        self.data = data
        self.errorCode = errorCode
        self.errorMsg = errorMsg
    }
}

public extension BaseModel {
    /// 请求是否成功
    var isSuccess: Bool { errorCode == 0 }
}
