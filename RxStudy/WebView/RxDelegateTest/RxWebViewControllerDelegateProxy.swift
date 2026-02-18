//
//  RxWebViewControllerDelegateProxy.swift
//  RxStudy
//
//  Created by dy on 2021/9/17.
//  Copyright © 2021 season. All rights reserved.
//

import RxSwift
import RxCocoa

class RxWebViewControllerDelegateProxy
    : DelegateProxy<WebViewController, WebViewControllerDelegate>
    , DelegateProxyType
    , WebViewControllerDelegate {
    
    public weak private(set) var webViewController: WebViewController?
    
    init(webViewController: WebViewController) {
        self.webViewController = webViewController
        super.init(parentObject: webViewController,
                   delegateProxy: RxWebViewControllerDelegateProxy.self)
    }
     
    static func registerKnownImplementations() {
        self.register { RxWebViewControllerDelegateProxy(webViewController: $0) }
    }
    
    private var _actionSuccessPublishSubject: PublishSubject<()>?
    
    var actionSuccessPublishSubject: PublishSubject<()> {
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
    
    public static func currentDelegate(for object: WebViewController) -> WebViewControllerDelegate? {
        object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: WebViewControllerDelegate?, to object: WebViewController) {
        object.delegate = delegate
    }
    
    deinit {
        if let subject = _actionSuccessPublishSubject {
            subject.on(.completed)
        }
    }
}
