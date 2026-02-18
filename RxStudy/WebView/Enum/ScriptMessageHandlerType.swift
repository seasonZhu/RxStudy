//
//  ScriptMessageHandlerType.swift
//  RxStudy
//
//  Created by dy on 2022/6/2.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

enum ScriptMessageHandlerType: String, CaseIterable {
    
    /// 更新自定义句柄,这个是我自己写的JS,并定义其句柄
    case wanAndroid = "wanAndroid"
    
    /// 在简书的网页 "打开"=>class="wrap-item-btn" => function openApp => M.stats.trackEvent=>key: "trackEvent",value: function(e) {this.callApp("Core.Instance.TrackEvent", e)}=> callApp => i = window.webkit.messageHandlers.handleMessageFromJS.postMessage(n);
    case jianshu = "handleMessageFromJS"
}
