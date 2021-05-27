//
//  WeakScriptMessageDelegate.swift
//  JiuRongCarERP
//
//  Created by season on 2018/9/3.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import WebKit

class WeakScriptMessageDelegate: NSObject {

    //MARK:- 属性设置
    private var scriptDelegate: WKScriptMessageHandler
    
    //MARK:- 初始化
    init(scriptDelegate: WKScriptMessageHandler) {
        self.scriptDelegate = scriptDelegate
    }
}

extension WeakScriptMessageDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.scriptDelegate.userContentController(userContentController, didReceive: message)
    }
}
