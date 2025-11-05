//
//  NetworkActivityManager.swift
//  RxStudy
//
//  Created by dy on 2025/9/29.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation
import Moya

import SVProgressHUD

final class NetworkActivityManager {
    private static var activityCount = 0
    
    private static let lock = NSLock()
    
    private static var targetTypeInterceptor: ((_ target: TargetType) -> Bool)?
    
    private static var beginLoadingCallback: (() -> Void)?
    
    private static var stopLoadingCallback: (() -> Void)?
    
    private init() {}
    
    static func plugin(targetTypeInterceptor: ((_ target: TargetType) -> Bool)?,
                       beginLoadingCallback: (() -> Void)?,
                       stopLoadingCallback: (() -> Void)?) -> NetworkActivityPlugin {
        self.targetTypeInterceptor = targetTypeInterceptor
        self.beginLoadingCallback = beginLoadingCallback
        self.stopLoadingCallback = stopLoadingCallback
        return NetworkActivityPlugin(networkActivityClosure: updateActivityCount)
    }
    
    static private func updateActivityCount(change: NetworkActivityChangeType, target: TargetType) {
        lock.lock()
        defer { lock.unlock() }
        
        if let targetTypeInterceptor, targetTypeInterceptor(target) {
            switch change {
            case .began:
                if activityCount == 0 {
                    // 首次开始请求，显示加载
                    beginLoading()
                }
                activityCount += 1
            case .ended:
                activityCount = max(0, activityCount - 1)
                if activityCount == 0 {
                    // 所有请求结束，隐藏加载
                    stopLoading()
                }
            }
        } else {
            
        }
    }
    
    private static func beginLoading() {
        // 主线程更新UI
        DispatchQueue.main.async {
            print("开始加载")
            beginLoadingCallback?()
        }
    }
    
    private static func stopLoading() {
        // 主线程更新UI
        DispatchQueue.main.async {
            print("停止加载")
            stopLoadingCallback?()
        }
    }
}

let activityManagerPlugin = NetworkActivityManager.plugin { targetType in
    /// 添加无网络拦截
    if AccountManager.shared.networkIsReachableRelay.value == false {
        if plugins.contains(where: {
            return $0 is ResponseCachePlugin
        }) {
            return false
        } else {
            SVProgressHUD.showText("似乎已断开与互联网的连接")
            return false
        }
        
    }
    
    if blackList.contains(targetType.path) {
        return false
    }
    
    if let showLoading = targetType.headers?["showLoading"],
       showLoading == "false" {
        return false
    }
    
    return true
} beginLoadingCallback: {
    SVProgressHUD.beginLoading()
} stopLoadingCallback: {
    SVProgressHUD.stopLoading()
}
