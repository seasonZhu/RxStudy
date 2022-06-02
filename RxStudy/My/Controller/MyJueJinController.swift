//
//  MyJueJinController.swift
//  RxStudy
//
//  Created by dy on 2021/12/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import WebKit

/// 我的掘金页面
class MyJueJinController: BaseViewController {
    
    private let juejinAppUrl = "https://apps.apple.com/cn/app/%E6%8E%98%E9%87%91/id987739104"

    private var url: String
        
    init() {
        self.url = "https://juejin.cn/user/4353721778057997"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController.add(WeakScriptMessageDelegate(scriptDelegate: self), name: ScriptMessageHandlerType.wanAndroid.rawValue)
        
        /// 获取js,并添加到webView中,在这一步,其实我们只是将js注入了某个页面,实际上还并没有执行js
        if let js = getJS() {
            config.userContentController.addUserScript(js)
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ScriptMessageHandlerType.wanAndroid.rawValue)
    }
}

extension MyJueJinController {
    func setupUI() {
        title = "作者的掘金"
        view.backgroundColor = .white
        view.addSubview(webView)
        
        /// 调用输入框的网址
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

extension MyJueJinController {
    /// 获取js方法,转成iOS的WKWebView可以识别的对象
    private func getJS() -> WKUserScript? {
        guard let url = R.file.appStoreJs() else {
            return nil
        }
        
        guard let string = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        
        let userScript = WKUserScript(source: string, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        debugLog(string)
        
        return userScript
    }
}

// MARK: - 协议类专门用来处理监听JavaScript方法从而调用原生方法，和WKUserContentController搭配使用
extension MyJueJinController: WKScriptMessageHandler {
    
    /// 原生界面监听JS运行,截取JS中的对应在userContentController注册过的方法
    ///
    /// - Parameters:
    ///   - userContentController: WKUserContentController
    ///   - message: WKScriptMessage 其中包含方法名称已经传递的参数,WKScriptMessage,其中body可以接收的类型是Allowed types are NSNumber, NSString, NSDate, NSArray, NSDictionary, and NSNull
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugLog("方法名:\(message.name)")
        debugLog("参数:\(message.body)")
         
        guard let msg = message.body as? String else { return }
        
        if msg == "download",
            let url = URL(string: juejinAppUrl),
            UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
    }
}

extension MyJueJinController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString.contains("zlink") == true {
            webView.evaluateJavaScript("downloadInject()") { (result: Result<String, Error>) in
                switch result {
                case .success(let string):
                    print(string)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension MyJueJinController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil
            || navigationAction.targetFrame?.isMainFrame == false {
            webView.load(navigationAction.request)
        }
         
        return nil
    }
}
