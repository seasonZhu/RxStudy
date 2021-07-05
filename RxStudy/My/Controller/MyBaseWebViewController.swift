//
//  MyBaseWebViewController.swift
//  RxStudy
//
//  Created by season on 2021/7/2.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import WebKit

class MyGitHubController: BaseViewController {

    private var url: String
        
    init() {
        self.url = "https://github.com/seasonZhu"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webView = WKWebView(frame: view.frame, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension MyGitHubController {
    func setupUI() {
        title = "作者的GitHub"
        view.backgroundColor = .white
        view.addSubview(webView)
        
        /// 调用输入框的网址
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}


class MyJueJinController: BaseViewController {

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
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webView = WKWebView(frame: view.frame, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

class MyBaseWebViewController: BaseViewController {

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
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webView = WKWebView(frame: view.frame, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension MyBaseWebViewController {
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(webView)
        
        /// 调用输入框的网址
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
