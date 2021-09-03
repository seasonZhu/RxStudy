//
//  DebugLog.swift
//  RxStudy
//
//  Created by dy on 2021/9/3.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import SwiftPrettyPrint

/// 仅在Debug模式下打印,我小看了print,这个方法打印出来的效果和print打印出来的效果完全不一样
public func debugLog(_ items: Any..., label: String? = nil, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Pretty.prettyPrintDebug(label: label, items, separator: separator)
    #endif
}
