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
        // SVProgressHUD.showInfo(withStatus: text)
    }
}

extension SVProgressHUD {
    /// 要想SVProgressHUD用的好,必须进行合适的配置
    static func setting() {
        /// 不显示图片,仅显示文字
        SVProgressHUD.setImageViewSize(.zero)
        /// 转圈的风格
        styleSetting()
        /// 蒙层的类型
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
    }
    
    /// 这里单独将改变Style拿出来,当用户去设置页面进行风格变化,需要调用这个方法
    /// 之前方法中我调用的是UITraitCollection的分类的方法,没有办法实时改变SV的风格
    static func styleSetting() {
        if #available(iOS 13.0, *) {
            (UIApplication.shared.delegate as? AppDelegate)?.window?.traitCollection.isDark == true ? SVProgressHUD.setDefaultStyle(.light) : SVProgressHUD.setDefaultStyle(.dark)
        } else {
            SVProgressHUD.setDefaultStyle(.dark)
        }
    }
}
