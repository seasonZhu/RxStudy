//
//  CopyActivity.swift
//  RxStudy
//
//  Created by dy on 2022/10/26.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

class CopyActivity: UIActivity {
    
    private var urlString: String?
    
    /// 设置分享按钮的类型
    override class var activityCategory:  UIActivity.Category { .share }
    
    override var activityType: UIActivity.ActivityType? { ActivityType(CopyActivity.className) }
    
    /// 设置分享按钮的标题
    override var activityTitle: String? { "复制URL" }
    
    /// 设置分享按钮的图片
    override var activityImage: UIImage? { R.image.saber() }
    
    /// 设置是否显示分享按钮
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    /// 预处理分享数据
    override func prepare(withActivityItems activityItems: [Any]) {
        guard activityItems.count >= 2, let urlString = activityItems[1] as? String else {
            return
        }
        self.urlString = urlString
    }
    
    override var activityViewController: UIViewController? { nil }
    
    /// 执行分享
    override func perform() {
        UIPasteboard.general.string = urlString
    }
    
    /// 完成分享
    override func activityDidFinish(_ completed: Bool) {}
}
