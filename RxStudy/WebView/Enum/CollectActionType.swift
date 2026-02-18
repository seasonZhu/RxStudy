//
//  CollectActionType.swift
//  RxStudy
//
//  Created by dy on 2023/3/21.
//  Copyright © 2023 season. All rights reserved.
//

import Foundation

enum CollectActionType {
    case collect(WebLoadInfo)
    
    case unCollect(WebLoadInfo)
}

extension CollectActionType {
    var webLoadInfo: WebLoadInfo {
        switch self {
        case .collect(let webLoadInfo):
            return webLoadInfo
        case .unCollect(let webLoadInfo):
            return webLoadInfo
        }
    }
}
