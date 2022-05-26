//
//  Moya+Plugin.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import Moya
import MBProgressHUD
import SVProgressHUD

/// 可以认为是请求和响应的拦截器,这里做的是在请求时loading,请求完毕后结束loading
class RequestLoadingPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        debugLog("prepare")
        var mRequest = request
        mRequest.timeoutInterval = 20
        return mRequest
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        debugLog("开始请求")
        
        if let showLoading = target.headers?["showLoading"],
           showLoading == "false" {
            return
        }
        
        /// 开启loading
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            SVProgressHUD.beginLoading()
        }
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        debugLog("结束请求")
        
        /// 关闭loading
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            SVProgressHUD.stopLoading()
        }
        
        switch result {
        case .success(let response):
            if response.statusCode == 200 {
                debugLog(response.prettyPrintJSON)
            } else {
                DispatchQueue.main.async {
                    /// 进行统一弹窗
                    SVProgressHUD.showText("statusCode not 200")
                }
            }
            
            
        case .failure(let error):
            debugLog(error.localizedDescription)
        }
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        return result
    }
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
}
