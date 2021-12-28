//
//  WebView+Extension.swift
//  RxStudy
//
//  Created by dy on 2021/12/28.
//  Copyright © 2021 season. All rights reserved.
//

import WebKit

extension WKWebView {
    enum TransformError: Error {
        case anyTransformError
    }
    
    func evaluateJavaScript<T>(_ javaScriptString: String, resultHandler: ((Result<T, Error>) -> Void)? = nil) {
        evaluateJavaScript(javaScriptString) { any, error in
            if let e = error {
                resultHandler?(.failure(e))
            }else if let result = any as? T {
                resultHandler?(.success(result))
            }else {
                resultHandler?(.failure(TransformError.anyTransformError))
            }
        }
    }
}
