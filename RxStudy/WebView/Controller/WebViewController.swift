//
//  WebViewController.swift
//  H5OCR
//
//  Created by season on 2020/6/23.
//  Copyright © 2020 season. All rights reserved.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa
import MBProgressHUD
import SVProgressHUD
import MarqueeLabel
import MJRefresh

class WebViewController: BaseViewController {
    
    weak var delegate: WebViewControllerDelegate?
    
    let collectActionRelay = PublishRelay<CollectActionType>()

    private let webLoadInfo: WebLoadInfo
    
    private let isNeedShowCollection: Bool
    
    private var actionTag = 0
    
    private var type: CollectActionType?
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(frame: .zero)
        view.tintColor = .systemBlue
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        /// 监听js的句柄
        for type in ScriptMessageHandlerType.allCases {
            config.userContentController.add(WeakScriptMessageDelegate(scriptDelegate: self), name: type.rawValue)
        }
        
        /// 获取js,并添加到webView中,在这一步,其实我们只是将js注入了某个页面,实际上还并没有执行js
        if let js = getJS() {
            config.userContentController.addUserScript(js)
        }
        
        if let grayModeJS = getGrayMode(), AccountManager.shared.isGrayModeRelay.value {
            config.userContentController.addUserScript(grayModeJS)
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.showsVerticalScrollIndicator = false
        return webView
    }()
    
    private lazy var lengthyLabel: MarqueeLabel = {
        let label = MarqueeLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 100, height: 44), duration: 8.0, fadeLength: 10.0)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    
    
    private lazy var collectionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.collect(), for: .normal)
        button.setImage(R.image.collect_selected(), for: .selected)
        return button
    }()
    
    let isContainsRelay = PublishRelay<Bool>()
    
    init(webLoadInfo: WebLoadInfo, isNeedShowCollection: Bool) {
        self.webLoadInfo = webLoadInfo
        self.isNeedShowCollection = isNeedShowCollection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if actionTag != 0, let type {
            collectActionRelay.accept(type)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    deinit {
        for type in ScriptMessageHandlerType.allCases {
            webView.configuration.userContentController.removeScriptMessageHandler(forName: type.rawValue)
        }
    }
}

extension WebViewController {
    private func setupUI() {
        /// 走马灯的Label
        var title = webLoadInfo.title
        lengthyLabel.text = title?.filterHTML()
        navigationItem.titleView = lengthyLabel
        
        /// 刷新页面
        webView.scrollView.mj_header = MJRefreshNormalHeader()
        webView.scrollView.mj_header?.rx.refresh
            .bind(to: rx.reload)
            .disposed(by: rx.disposeBag)
        
        /// 页面布局
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(kTopMargin)
            make.height.equalTo(2)
        }
        
        webView.rx.observe(Double.self, #keyPath(WKWebView.estimatedProgress)).subscribe { [weak self] event in
            switch event {
                
            case .next(let value):
                if let value {
                    self?.progressView.setProgress(Float(value), animated: true)
                    
                    if value >= 1 {
                        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseInOut) {
                            self?.progressView.isHidden = true
                        } completion: { finish in
                            if finish == true {
                                self?.progressView.progress = 0
                            }
                        }
                    }
                }
            case .error(_):
                self?.progressView.isHidden = true
            case .completed:
                self?.progressView.isHidden = true
            }
        }
        .disposed(by: rx.disposeBag)
        
        /// 加载url
        guard let link = webLoadInfo.link,
              let url = URL(string: link) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        /// 分享
        let toShare = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)

        toShare.rx.tap.subscribe(onNext:  { [weak self] _ in
            self?.shareAction()
        })
        .disposed(by: rx.disposeBag)
        
        /// viewModel
        let viewModel = WebViewModel()

        /// 收藏与取消收藏
        collectionButton.rx.tap.subscribe(onNext:  { [weak self] _ in

            guard let collectId = self?.getRealCollectId() else {
                return
            }
            
            guard let self else { return }
            
            if self.collectionButton.isSelected {
                /// 在这里说明是已经收藏过,取消收藏
                viewModel.inputs.unCollectAction(collectId: collectId)
            } else {
                /// 在这里说明是没有收藏过,进行收藏
                viewModel.inputs.collectAction(collectId: collectId)
            }
            
            self.collectionButton.isSelected = !self.collectionButton.isSelected
            
        })
        .disposed(by: rx.disposeBag)

        var items = [toShare]

        /// 需要显示收藏按钮,才通过判断登录状态来看是否显示收藏页面
        if isNeedShowCollection {
            
            /// 这里其实使用let isLogin = AccountManager.shared.isLoginRelay.value去做判断在本App中也是可以的
            /// 因为玩安卓App不存在被挤掉这种场景
            /// 但是考虑到isLoginRelay应该是随着登录的状态变化而做出UI变化的,于是保留了subscribe
            AccountManager.shared.isLoginRelay.subscribe { [weak self] event in
                guard let self else {
                    return
                }

                switch event {
                case .next(let isLogin):
                    if isLogin {
                        let collection = UIBarButtonItem(customView: self.collectionButton)
                        items.append(collection)

                        guard let collectIds = AccountManager.shared.accountInfo?.collectIds,
                              let collectId = self.getRealCollectId() else {
                            return
                        }

                        let value = collectIds.contains(collectId)
                        
                        self.collectionButton.isSelected = value
                    }
                default:
                    break
                }
            }
            .disposed(by: rx.disposeBag)
            
            /*
             let isLogin = AccountManager.shared.isLoginRelay.value
             if isLogin {
                 let collection = UIBarButtonItem(customView: self.collectionButton)
                 items.append(collection)

                 guard let collectIds = AccountManager.shared.accountInfo?.collectIds,
                       let collectId = self.getRealCollectId() else {
                     return
                 }

                 let value = collectIds.contains(collectId)
                 
                 self.collectionButton.isSelected = value
             }
             */
        }

        isContainsRelay
            .bind(to: collectionButton.rx.isSelected)
            .disposed(by: rx.disposeBag)

        navigationItem.rightBarButtonItems = items.reversed()
        
        viewModel.outputs.collectRelay
            .bind(to: isContainsRelay)
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.unCollectRelay
            .map { !$0 }
            .bind(to: isContainsRelay)
            .disposed(by: rx.disposeBag)
        
        isContainsRelay.subscribe(onNext: { [weak self] isContains in
            guard let self else { return }
            
            if isContains {
                self.actionTag = self.actionTag + 1
                self.type = .collect(self.webLoadInfo)
            } else {
                self.actionTag = self.actionTag - 1
                self.type = .unCollect(self.webLoadInfo)
            }
        }).disposed(by: rx.disposeBag)
    }
}

extension WebViewController {
    private func getRealCollectId() -> Int? {
        let id = webLoadInfo.id
        let collectId = webLoadInfo.originId
        
        if collectId == nil && id != nil {
            return id
        } else {
            return collectId
        }
    }
    
    private func shareAction() {
        guard let title = webLoadInfo.title,
              let url = webLoadInfo.link else {
            SVProgressHUD.showText("无法获取分享信息")
            return
        }
        
        let activityItems = [title, url]
        
        let activities = [SafariActivity(), CopyActivity()]
        
        /// 排除的分享类型,这里排除系统的复制到剪切板
        let excludedActivityTypes: [UIActivity.ActivityType] = [.copyToPasteboard,]
        
        let activityContrller = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        activityContrller.excludedActivityTypes = excludedActivityTypes
        activityContrller.completionWithItemsHandler = { [weak activityContrller] activityType, completed, returnedItems, activityError in
            if completed {
                SVProgressHUD.showText("分享成功!")
            } else {
                //SVProgressHUD.showText("分享失败!")
                /// 此处回调的complete为Bool值,false也有可能是点击了close按钮导致,所以这里暂时就不toast内容了
                debugLog("分享未完成")
            }
            
            activityContrller?.dismiss(animated: true, completion: nil)
        }
        present(activityContrller, animated: true, completion: nil)
    }
}

extension WebViewController {
    private func openApp() {
        guard let link = webLoadInfo.link,
              let url = URL(string: link) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    fileprivate func reload() {
        webView.reload()
    }
}

// MARK: - 协议类专门用来处理监听JavaScript方法从而调用原生方法，和WKUserContentController搭配使用
extension WebViewController: WKScriptMessageHandler {
    
    /// 原生界面监听JS运行,截取JS中的对应在userContentController注册过的方法
    ///
    /// - Parameters:
    ///   - userContentController: WKUserContentController
    ///   - message: WKScriptMessage 其中包含方法名称已经传递的参数,WKScriptMessage,其中body可以接收的类型是Allowed types are NSNumber, NSString, NSDate, NSArray, NSDictionary, and NSNull
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugLog("方法名:\(message.name)")
        debugLog("参数:\(message.body)")
        
        /* 但是这里捕获不到,说明没有监听到,抑或说js侧没有触发对应的方法
        if message.name == JianShuJSCallback {
            openApp()
            return
        }
        */
         
        guard let msg = message.body as? String else { return }
        
        /// 简书和掘金都可以直接跳转到App了,这里的js注入没有什么意义了
        if msg == "goToApp" {
            debugLog("打开App操作")
            /// 这里其实只是针对掘金了,CSDN的可以其实可以直接跳转了
            if OtherApp.juejin.isCanOpen
                || OtherApp.jianshu.isCanOpen
                || OtherApp.csdn.isCanOpen {
                return
            }
                
            openApp()
        }
    }
}

// MARK: - 其实在RxCocoa中有WebView+Rx的分类,专门来将WebView的代理进行rx的编写方式,就和UITablevDelegate差不多,这里只是没有使用
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        decisionHandler(.allow)
        return
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        delayEndRefreshing()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delayEndRefreshing()
        /// 加载完网页后,执行js方法,会根据打开的网页,决定不同的注入依赖
        /// 将在App端通过JS编写的点击事件与掘金网页的"APP内打开绑定"
        webView.evaluateJavaScript("injectBegin('\(webView.url?.absoluteString)')") { any, error in
            debugLog(any)
            debugLog(error)
        }
        
        /// 执行灰色模式
        if AccountManager.shared.isGrayModeRelay.value {
            webView.evaluateJavaScript("grayMode()")
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delayEndRefreshing()
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delayEndRefreshing()
        progressView.isHidden = true
    }
}

//MARK: -  WKUIDelegate
extension WebViewController: WKUIDelegate {
    /// 拦截当前页面的_blank弹出窗口,然后通过弹出的窗口新建新的WebView,WKWebView 如何支持window.open方法
    ///
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - configuration: WKWebViewConfiguration的配置
    ///   - navigationAction: 导航行为 注意这个里面包含的WKNavigationType
    ///   - windowFeatures: 窗口特性
    /// - Returns: 新的WKWebView
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        /*
        if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false {
            webView.load(navigationAction.request)
        }
        */
         
        return nil
    }
    
    /// 处理js里的alert
    ///
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - message: web端回传的文字
    ///   - frame: web端的frame信息
    ///   - completionHandler: 回调
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

    }
    
    /// 处理js里的confirm
    ///
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - message: web端回传的文字
    ///   - frame: web端的frame信息
    ///   - completionHandler: 回调
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    /// 处理js里的 textInput
    ///
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - prompt: 说明文字
    ///   - defaultText: 默认文字 placeholder
    ///   - frame: web端的frame信息
    ///   - completionHandler: 回调
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
    }
}

extension WebViewController {
    private func delayEndRefreshing() {
        /// 其实使用Rx做这种延时操作还不如GCD简单明白
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.webView.scrollView.mj_header?.endRefreshing()
        }
        */
        
        Observable<Void>.just(void).delaySubscription(.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext:  { _ in
            self.webView.scrollView.mj_header?.endRefreshing()
        })
        .disposed(by: rx.disposeBag)
    }
}

extension WebViewController {
    /// 获取js方法,转成iOS的WKWebView可以识别的对象
    private func getJS() -> WKUserScript? {
        guard let url = R.file.openJs() else {
            return nil
        }
        
        guard let string = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        
        let userScript = WKUserScript(source: string, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        debugLog(string)
        
        return userScript
    }
    
    private func getGrayMode() -> WKUserScript? {
        let jsString = "var filter = '-webkit-filter:grayscale(100%);-moz-filter:grayscale(100%); -ms-filter:grayscale(100%); -o-filter:grayscale(100%) filter:grayscale(100%);';document.getElementsByTagName('html')[0].style.filter = 'grayscale(100%)';"
        
        /*
        guard let url = R.file.grayModeJs() else {
            return nil
        }
        
        guard let string = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        
        debugLog(string)
        */
        let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        
        
        
        return userScript
    }
}

// MARK: - 自己写的Rx的代理,其实既不好写,也不好理解,而且有不少坑,不如直接代理来的简单明了

/// 死活点不出来的原因找到了,因为需要在协议上面加上@objc, 这里协议名称需要用objc修饰,同时optional也需要objc修复,太久没在swift中写这种协议,都忘记了
@objc
public protocol WebViewControllerDelegate: AnyObject {
    
    @objc optional func webViewControllerActionSuccess()
}
 
extension WebViewController: HasDelegate {
    typealias Delegate = WebViewControllerDelegate
}

extension Reactive where Base == WebViewController {
    var reload: Binder<Void> {
        return Binder(base) { base, _ in
            base.reload()
        }
    }
}
