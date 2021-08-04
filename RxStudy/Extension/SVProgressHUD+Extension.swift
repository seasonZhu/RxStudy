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
        SVProgressHUD.show(UIImage(), status: text)
        /// 使用showInfo,会有图标,而通过上面的方式是没有的图标的,不过同时设置一下图片的大小,在AppDelegate中已经设置过了
        //SVProgressHUD.showInfo(withStatus: text)
    }
}
