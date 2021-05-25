//
//  RefreshStatus.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

/// 刷新状态
enum RefreshStatus {
    
    case header(HeaderStatus)
    case footer(FooterStatus)
    
    enum HeaderStatus {
        case none
        case begainHeaderRefresh
        case endHeaderRefresh
    }
    
    enum FooterStatus {
        case hiddenFooter
        case showFooter
        case endFooterRefresh
        case endFooterRefreshWithNoData
    }
}
