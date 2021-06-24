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

class RequestLoadingPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        print("prepare")
        var mRequest = request
        mRequest.timeoutInterval = 20
        return mRequest
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        print("开始请求")
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            MBProgressHUD.beginLoading()
        }
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        print("结束请求")
        // 关闭loading
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            MBProgressHUD.stopLoading()
        }
        
        switch result {
        case .success(let response):
            if response.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: .mutableContainers),
                   let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let _ = try? String(data: data, encoding: .utf8) {
                    print(json)
                }
            }else {
                DispatchQueue.main.async {
                    // 进行统一弹窗
                    MBProgressHUD.showText("statusCode not 200")
                }
            }
            
            
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func process(_ result: Result<Moya.Response, MoyaError>, target: TargetType) -> Result<Moya.Response, MoyaError> {
        return result
    }
}

extension TargetType {
    var loginHeader: [String : String]? {
        return AccountManager.shared.isLogin.value ? ["cookie": AccountManager.shared.cookieHeaderValue] : nil
    }
}
