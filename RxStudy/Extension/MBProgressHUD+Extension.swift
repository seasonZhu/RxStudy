//
//  MBProgressHUD+Extension.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import MBProgressHUD

@MainActor
extension MBProgressHUD: @preconcurrency HUD {
    
    static let keyWindow: UIWindow = UIApplication.shared.mainWindow!
    
    static func beginLoading() {
        MBProgressHUD.showAdded(to: keyWindow, animated: true)
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
        hud.hide(animated: true, afterDelay: 3)
    }
}

extension MBProgressHUD {

    // 显示自定义 HUD 的方法
    static func showCustomActivityIndicator() {
        // 创建 HUD 并添加到当前视图
        let hud = MBProgressHUD.showAdded(to: keyWindow, animated: true)
        
        // 设置模式为自定义视图
        hud.mode = .customView
        
        // 创建一个 UIActivityIndicatorView 作为自定义视图
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.color = .systemBlue // 设置颜色
        activityIndicator.startAnimating()
        
        // 将自定义视图设置给 HUD
        hud.customView = activityIndicator
        
        // 设置提示文本
        hud.label.text = "加载中..."
        
        // 设置最小显示时间，避免闪烁
        hud.minShowTime = 0.5
    }
    
    // 显示带图片序列动画的 HUD
    static func showCustomImageSequenceLoading() {
        let hud = MBProgressHUD.showAdded(to: keyWindow, animated: true)
        
        hud.mode = .customView
        hud.bezelView.color = .systemBlue
        
        // 创建 UIImageView 用于显示帧动画
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFill
        
        // 准备动画帧数组
        var images: [UIImage] = []
        for i in 1...12 {
            let number = i.toString.count == 1 ? "0\(i)" : "\(i)"
            let imageName = "loading_\(number)"
            if let image = UIImage(named: imageName) {
                images.append(image)
            }
        }
        
        // 设置动画
        imageView.animationImages = images
        imageView.animationDuration = 1.0 // 动画持续时间
        imageView.animationRepeatCount = 0 // 0表示无限循环
        imageView.startAnimating()
        
        hud.customView = imageView
        hud.label.text = "正在处理..."
    }
    
    // 显示自定义圆形进度条 HUD
    static func showCustomCircularProgress() {
        let hud = MBProgressHUD.showAdded(to: keyWindow, animated: true)
        
        // 设置为圆形进度模式
        hud.mode = .annularDeterminate
        
        // 自定义颜色
        hud.bezelView.color = UIColor(white: 0.0, alpha: 0.7) // 背景色
        hud.label.textColor = .white // 文本颜色
        
        hud.label.text = "加载进度"
        
        // 模拟进度更新
//        DispatchQueue.global(qos: .default).async {
//            var progress: Float = 0.0
//            while progress < 1.0 {
//                progress += 0.01
//                DispatchQueue.main.async {
//                    hud.progress = progress
//                    if progress == 1.0 {
//                        hud.hide(animated: true)
//                    }
//                }
//                usleep(50000) // 50毫秒
//            }
//        }
    }
    
    // 显示带有完全自定义样式的 HUD
    static func showFullyCustomizedHUD() {
        let hud = MBProgressHUD.showAdded(to: keyWindow, animated: true)
        
        // 自定义外观
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(white: 0.0, alpha: 0.8)
        
        // 自定义文本
        hud.label.text = "加载中"
        hud.label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        hud.label.textColor = .white
        
        // 自定义详情文本
        hud.detailsLabel.text = "请稍候..."
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 14)
        hud.detailsLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        
        // 自定义动画视图
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .orange
        activityIndicator.startAnimating()
        hud.customView = activityIndicator
        hud.mode = .customView
        
        // 设置偏移量，使HUD不居中显示
        hud.offset = CGPoint(x: 0.0, y: 100)
    }
}
