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

/// 更新自定义句柄,这个是我自己写的JS,并定义其句柄
private let JSCallback = "wanAndroid"

class WebViewController: BaseViewController {

    private let webLoadInfo: WebLoadInfo
    
    private let isFromBanner: Bool
    
    weak var delegate: WebViewControllerDelegate?
    
    let hasCollectAction = PublishSubject<Void>()
    
    init(webLoadInfo: WebLoadInfo, isFromBanner: Bool) {
        self.webLoadInfo = webLoadInfo
        self.isFromBanner = isFromBanner
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController.add(WeakScriptMessageDelegate(scriptDelegate: self), name: JSCallback)
        
        /// 获取js,并添加到webView中
        if let js = getJS() {
            config.userContentController.addUserScript(js)
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
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
    
    let isContains = BehaviorRelay(value: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        /// 走马灯的Label
        var title = webLoadInfo.title
        lengthyLabel.text = title?.filterHTML()
        navigationItem.titleView = lengthyLabel
        
        /// 刷新页面
        webView.scrollView.mj_header = MJRefreshNormalHeader()
        webView.scrollView.mj_header?.rx.refresh
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.webView.reload()
            }).disposed(by: rx.disposeBag)
        
        /// 页面布局
        view.addSubview(webView)
        webView.navigationDelegate = self
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        /// vm
        let vm = WebViewModel()
        
        /// 加载url
        guard let link = webLoadInfo.link, let url = URL(string: link) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        /// 分享
        let toShare = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)

        toShare.rx.tap.subscribe { [weak self] _ in
            self?.shareAction()
        }.disposed(by: rx.disposeBag)

        /// 收藏与取消收藏
        collectionButton.rx.tap.subscribe { [weak self] _ in

            guard let collectId = self?.getRealCollectId() else {
                return
            }

            self?.hasCollectAction.onNext(())

            if self?.isContains.value == true {
                /// 在这里说明是已经收藏过,取消收藏
                vm.inputs.unCollectAction(collectId: collectId)
            }else {
                /// 在这里说明是没有收藏过,进行收藏
                vm.inputs.collectAction(collectId: collectId)
            }
        }.disposed(by: rx.disposeBag)

        var items = [toShare]

        /// 非轮播的页面跳转进来才通过判断登录状态来看是否显示收藏页面
        if !isFromBanner {
            AccountManager.shared.isLogin.subscribe { [weak self] event in
                guard let self = self else {
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

                        self.isContains.accept(value)
                    }
                default:
                    break
                }
            }.disposed(by: rx.disposeBag)
        }

        isContains
            .bind(to: collectionButton.rx.isSelected)
            .disposed(by: rx.disposeBag)

        navigationItem.rightBarButtonItems = items.reversed()

        vm.outputs.collectSuccess.subscribe { [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .next(let isSuccess):
                if isSuccess {
                    self.isContains.accept(isSuccess)
                }
            default:
                break
            }
        }.disposed(by: rx.disposeBag)

        vm.outputs.unCollectSuccess.subscribe { [weak self] event in
            guard let self = self else {
               return
            }
            
            switch event {
            case .next(let isSuccess):
                if isSuccess {
                    self.isContains.accept(!isSuccess)
                }
            default:
                break
            }
        }.disposed(by: rx.disposeBag)
    }
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: JSCallback)
    }
    
}

extension WebViewController {
    private func getRealCollectId() -> Int? {
        let id = webLoadInfo.id
        let collectId = webLoadInfo.originId
        
        if collectId == nil && id != nil {
            return id
        }else {
            return collectId
        }
    }
    
    private func shareAction() {
        guard let title = webLoadInfo.title, let url = webLoadInfo.link else {
            SVProgressHUD.showText("无法获取分享信息")
            return
        }
        
        let activityItems = [title, url]
        
        let excludedActivityTypes: [UIActivity.ActivityType] = [.postToWeibo,
                                                                .message,
                                                                .airDrop,
                                                                .addToReadingList,
                                                                .copyToPasteboard,
                                                                .mail,
                                                                .assignToContact
        ]
        
        let activityContrller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityContrller.excludedActivityTypes = excludedActivityTypes
        activityContrller.completionWithItemsHandler = { [weak activityContrller] activityType, completed, returnedItems, activityError in
            if completed {
                SVProgressHUD.showText("分享成功!")
            }else {
                SVProgressHUD.showText("分享失败!")
            }
            
            activityContrller?.dismiss(animated: true, completion: nil)
        }
        present(activityContrller, animated: true, completion: nil)
    }
}

extension WebViewController {
    private func openApp() {
        guard let link = webLoadInfo.link, let url = URL(string: link) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
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
        
        guard let msg = message.body as? String else { return }
        
        if msg == "goToApp" {
            debugLog("打开App操作")
            /// 这里其实只是针对掘金了,CSDN的可以其实可以直接跳转了
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
        /// 加载完网页后,进行运行js,将在App端通过JS编写的点击事件与掘金网页的"APP内打开绑定"
        webView.evaluateJavaScript("injectBegin('\(webView.url?.absoluteString)')") { any, error in
            debugLog(any)
            debugLog(error)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        delayEndRefreshing()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delayEndRefreshing()
    }
}

extension WebViewController {
    private func delayEndRefreshing() {
        /// 其实使用Rx做这种延时操作还不如GCD简单明白
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.webView.scrollView.mj_header?.endRefreshing()
//        }
        
        Observable<Void>.just(void).delaySubscription(.seconds(2), scheduler: MainScheduler.instance).subscribe { _ in
            self.webView.scrollView.mj_header?.endRefreshing()
        }.disposed(by: rx.disposeBag)
    }
}

extension WebViewController {
    /// 获取js方法,转成iOS的WKWebView可以识别的对象
    private func getJS() -> WKUserScript? {
        guard let url = Bundle.main.url(forResource: "javascript", withExtension: "js") else {
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

// MARK: - 自己写的Rx的代理,其实既不好写,也不好理解,而且有不少坑,不如直接代理来的简单明了

@objc /// 死活点不出来的原因找到了,因为需要在协议上面加上@objc
public protocol WebViewControllerDelegate: AnyObject {
    
    func webViewControllerActionSuccess()
}
 
extension WebViewController: HasDelegate {
    typealias Delegate = WebViewControllerDelegate
}

class RxWebViewControllerDelegateProxy
    : DelegateProxy<WebViewController, WebViewControllerDelegate>
    , DelegateProxyType
    , WebViewControllerDelegate {
    
    init(webViewController: WebViewController) {
        super.init(parentObject: webViewController,
                   delegateProxy: RxWebViewControllerDelegateProxy.self)
    }
     
    static func registerKnownImplementations() {
        self.register { RxWebViewControllerDelegateProxy(webViewController: $0) }
    }
    
    private var _actionSuccessPublishSubject: PublishSubject<()>?
    
    var actionSuccessPublishSubject: PublishSubject<()>{
        if let subject = _actionSuccessPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _actionSuccessPublishSubject = subject

        return subject
    }
    
    func webViewControllerActionSuccess() {
        if let subject = _actionSuccessPublishSubject {
            subject.on(.next(()))
        }
        
        /// 死活点不出来的原因找到了,因为需要在协议上面加上@objc
        _forwardToDelegate?.webViewControllerActionSuccess()
    }
    
    deinit {
        if let subject = _actionSuccessPublishSubject {
            subject.on(.completed)
        }
    }
}

extension Reactive where Base: WebViewController {
     
    /// 代理委托
    var delegate: DelegateProxy<WebViewController, WebViewControllerDelegate> {
        return RxWebViewControllerDelegateProxy.proxy(for: base)
    }
    
    var actionSuccess: Observable<Void> {
        return delegate
            .sentMessage(#selector(WebViewControllerDelegate
                            .webViewControllerActionSuccess))
            .map({ (a) in
                return ()
            })
    }
    
    func setDelegate(_ delegate: WebViewControllerDelegate)
        -> Disposable {
        return RxWebViewControllerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}
