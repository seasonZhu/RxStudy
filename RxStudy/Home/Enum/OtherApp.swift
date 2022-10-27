//
//  OtherApp.swift
//  RxStudy
//
//  Created by dy on 2022/10/27.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

enum  OtherApp: String {
    case alipay
    case weixin
    case qq
}

extension OtherApp {
    var scheme: String {
        switch self {
        case .alipay:
            return "alipay://"
        case .weixin:
            return "weixin://"
        case .qq:
            return "mqq://"
        }
    }
    
    var isCanOpen: Bool {
        guard let url = URL(string: self.scheme) else {
            return false
        }
        
        let canOpen = UIApplication.shared.canOpenURL(url)
        
        return canOpen
    }
}
