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

    //MARK:- 属性设置 之前这个属性没有用weak修饰,所以一直持有,无法释放
    private weak var scriptDelegate: WKScriptMessageHandler!

    //MARK:- 初始化
    convenience init(scriptDelegate: WKScriptMessageHandler) {
        self.init()
        self.scriptDelegate = scriptDelegate
    }
}

extension WeakScriptMessageDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate.userContentController(userContentController, didReceive: message)
    }
}
