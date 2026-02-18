//
//  NSObject+Extension.swift
//  RxStudy
//
//  Created by season on 2021/5/24.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

// MARK: - 获取类的字符串名称

public extension NSObject {
    /// 对象获取类的字符串名称
    var className: String { runtimeType.className }

    /// 类获取类的字符串名称
    static var className: String { String(describing: self) }

    /// NSObject对象获取类型
    var runtimeType: NSObject.Type { type(of: self) }
}
