//
//  WeakScriptMessageDelegate.swift
//  JiuRongCarERP
//
//  Created by season on 2018/9/3.
//  Copyright © 2018年 season. All rights reserved.
//

import Foundation
import WebKit

/// 专用WKScriptMessageHandler的代理层
class WeakScriptMessageDelegate: NSObject {

    //MARK: - 属性设置 之前这个属性没有用weak修饰,所以一直持有,无法释放
    private weak var scriptDelegate: WKScriptMessageHandler!

    //MARK: - 初始化
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

/// 更为通用的弱代理交换器
class WeakProxy: NSObject {
    
    weak var target: NSObjectProtocol?
    
    init(target: NSObjectProtocol) {
        self.target = target
        super.init()
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return (target?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}

extension WeakProxy: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        (target as? WKScriptMessageHandler)?.userContentController(userContentController, didReceive: message)
    }
}
