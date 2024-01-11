//
//  ResponseInterceptorPlugin.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

import Moya
import SVProgressHUD

//MARK: - 响应异常拦截器插件
class ResponseInterceptorPlugin: PluginType {
    func process(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) -> Swift.Result<Moya.Response, MoyaError> {

        switch result {
        case .success(let response):
            if let dictionary = response.dictionary,
               let message = dictionary["errorMsg"] as? String,
               message.isNotEmpty {
                
                SVProgressHUD.showText(message)
                
                /// 注意,这里我自认为是statusCode导致的错误
                return .failure(.statusCode(response))
            } else {
                return result
            }
        case .failure:
            return result
        }
    }
}

extension ResponseInterceptorPlugin {
    /// 错误的服务端业务编码
    static let errorServerCodes = [-1]
}


/// 对Moya的Response做只读属性的扩展,打印漂亮的json
extension Moya.Response {
    /// json打印
    var prettyPrintJSON: String {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    var any: Any? {
        try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    var array: [Any]? {
        any as? [Any]
    }
    
    var dictionary: [String: Any]? {
        any as? [String: Any]
    }
    
}

