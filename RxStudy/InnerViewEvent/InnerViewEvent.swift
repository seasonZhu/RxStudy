//
//  InnerViewEvent.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation

enum InnerViewEvent: InnerEventConvertible {
    /// 可以在这里扩展枚举,针对不同的事件进行处理,也可以直接通过遵守InnerEventConvertible新建一个事件,处理业务
    case custom([String: Any])
}
