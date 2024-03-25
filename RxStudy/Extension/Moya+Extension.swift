//
//  Moya+Extension.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import Moya
import MBProgressHUD
import SVProgressHUD

/// 在wanandroid客户端中,针对登录后状态,在请求头中塞进cookie
extension TargetType {
    var loginHeader: [String: String]? {
        AccountManager.shared.isLoginRelay.value ? ["cookie": AccountManager.shared.cookieHeaderValue] : nil
    }
}
