//
//  SafariActivity.swift
//  RxStudy
//
//  Created by dy on 2022/10/19.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

import SFSafeSymbols

class SafariActivity: UIActivity {
    
    private var url: URL?
    
    /// 设置分享按钮的类型
    override class var activityCategory:  UIActivity.Category { .share }
    
    override var activityType: UIActivity.ActivityType? { ActivityType(NSStringFromClass(SafariActivity.self)) }
    
    /// 设置分享按钮的标题
    override var activityTitle: String? { "Safari" }
    
    /// 设置分享按钮的图片
    override var activityImage: UIImage? { R.image.safari() }
    
    /// 设置是否显示分享按钮
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    /// 预处理分享数据
    override func prepare(withActivityItems activityItems: [Any]) {
        guard activityItems.count >= 2, let urlString = activityItems[1] as? String, let url = URL(string: urlString) else {
            return
        }
        self.url = url
    }
    
    override var activityViewController: UIViewController? { nil }
    
    /// 执行分享
    override func perform() {
        if let url = self.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    /// 完成分享
    override func activityDidFinish(_ completed: Bool) {}
}
