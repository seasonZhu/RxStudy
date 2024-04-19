//
//  WebView+Extension.swift
//  RxStudy
//
//  Created by dy on 2021/12/28.
//  Copyright © 2021 season. All rights reserved.
//

import WebKit

extension WKWebView {
    enum RunJavaScriptError: Error {
        case runJavaScriptFailed(Error)
        case genericConversionsFailed(Any?)
    }
    
    /// 优化evaluateJavaScript方法,以保证错误类型更加明显
    /// - Parameters:
    ///   - javaScriptString: JavaScript方法
    ///   - resultHandler: 回调
    func runJavaScript<T>(_ javaScriptString: String, resultHandler: ((Result<T, WKWebView.RunJavaScriptError>) -> Void)? = nil) {
        evaluateJavaScript(javaScriptString) { any, error in
            if let e = error {
                resultHandler?(.failure(.runJavaScriptFailed(e)))
            } else if let result = any as? T {
                resultHandler?(.success(result))
            } else {
                resultHandler?(.failure(.genericConversionsFailed(any)))
            }
        }
    }
}
