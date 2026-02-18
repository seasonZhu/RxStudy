//
//  BaseModel.swift
//  RxStudy
//
//  Created by season on 2021/5/20.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

struct BaseModel<T: Codable>: Codable {
    let data: T?
    let errorCode: Int?
    let errorMsg: String?
}

extension BaseModel {
    /// 请求是否成功
    var isSuccess: Bool {  errorCode == 0 }
    
}
