//
//  WebViewController+Rx.swift
//  RxStudy
//
//  Created by dy on 2021/9/17.
//  Copyright © 2021 season. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: WebViewController {
     
    /// 代理委托
    var delegate: DelegateProxy<WebViewController, WebViewControllerDelegate> {
        return RxWebViewControllerDelegateProxy.proxy(for: base)
    }
    
    var actionSuccess: Observable<Void> {
        return delegate
            .sentMessage(#selector(WebViewControllerDelegate
                            .webViewControllerActionSuccess))
            .map({ (_) in
                return ()
            })
    }
    
    func setDelegate(_ delegate: WebViewControllerDelegate)
        -> Disposable {
        return RxWebViewControllerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}
