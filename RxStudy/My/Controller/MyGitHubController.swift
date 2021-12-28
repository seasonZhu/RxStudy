//
//  MyGitHubController.swift
//  RxStudy
//
//  Created by dy on 2021/12/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import WebKit

/// 我的GitHub页面
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
