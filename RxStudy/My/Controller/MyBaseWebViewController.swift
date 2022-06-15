//
//  MyBaseWebViewController.swift
//  RxStudy
//
//  Created by season on 2021/7/2.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import WebKit

/// 在我的页面,我使用的通过字符串去创建控制器,我个人很想使用基类省去这么写的麻烦,但是在runtime的时候就报错了,所以不得不写了两个控制器
/// 其实可以设计为一个控制器,通过枚举来进行不同的页面操作,但是考虑使用runtime机制去生成与加载,所以放弃了
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
