//
//  SVProgressHUD+Extension.swift
//  RxStudy
//
//  Created by season on 2021/7/14.
//  Copyright © 2021 season. All rights reserved.
//

import SVProgressHUD

extension SVProgressHUD: HUD {
    
    /// 为啥不用start,因为容易混淆
    static func beginLoading() {
        SVProgressHUD.show()
    }
    
    static func stopLoading() {
        SVProgressHUD.dismiss()
    }
    
    static func showText(_ text: String) {
        SVProgressHUD.showInfo(withStatus: text)
    }
}
