//
//  SVProgressHUD+Extension.swift
//  RxStudy
//
//  Created by season on 2021/7/14.
//  Copyright © 2021 season. All rights reserved.
//

import SVProgressHUD

extension SVProgressHUD: HUD {
    
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

extension SVProgressHUD {
    /// 要想SVProgressHUD用的好,必须进行合适的配置
    static func setting() {
        /// 不显示图片,仅显示文字
        SVProgressHUD.setImageViewSize(.zero)
        /// 转圈的风格
        UITraitCollection.isDark ? SVProgressHUD.setDefaultStyle(.dark) : SVProgressHUD.setDefaultStyle(.light)
        /// 蒙层的类型
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
    }
}
