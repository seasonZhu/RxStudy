//
//  MBProgressHUD+Extension.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD: HUD {
    static var keyWindow: UIWindow { UIApplication.shared.keyWindow! }
    
    static func beginLoading() {
        MBProgressHUD.showAdded(to:keyWindow , animated: true)
    }
    
    static func stopLoading() {
        MBProgressHUD.hide(for: keyWindow, animated: true)
    }
    
    static func showText(_ text: String) {
        /**
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
         hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
         hud.animationType = MBProgressHUDAnimationZoom;
         hud.bezelView.color = [UIColor colorWithRed:163/255.0 green:164/255.0  blue:164/255.0  alpha:0.8];
         hud.bezelView.layer.cornerRadius = 0;
         hud.bezelView.layer.masksToBounds = YES;
         hud.detailsLabel.text = text;
         hud.detailsLabel.font = [UIFont systemFontOfSize:16];
         hud.mode = MBProgressHUDModeText;
         hud.removeFromSuperViewOnHide = YES;
         hud.detailsLabel.textColor = UIColor.whiteColor;//kThemeColor;
         [hud hideAnimated:YES afterDelay:3];
         */
        
        let hud = MBProgressHUD.showAdded(to: keyWindow, animated: true)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(red: 163/255.0, green: 164/255.0, blue: 164/255.0, alpha: 1)
        hud.animationType = .fade
        hud.detailsLabel.text = text
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 16)
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        /// 编码的顺序很重要,只有在这里设置颜色才生效
        hud.detailsLabel.textColor = .white
        hud .hide(animated: true, afterDelay: 3)
    }
}
