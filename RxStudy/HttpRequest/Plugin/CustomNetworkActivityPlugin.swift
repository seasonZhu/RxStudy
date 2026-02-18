//
//  CustomNetworkActivityPlugin.swift
//  RxStudy
//
//  Created by dy on 2025/9/4.
//  Copyright © 2025 season. All rights reserved.
//

import Moya

class CustomNetworkActivityPlugin: PluginType {
    private let lock = NSRecursiveLock()
    private var requestCount = 0
    private let beginLoading: () -> Void
    private let endLoading: () -> Void
    
    init(begin: @escaping () -> Void, end: @escaping () -> Void) {
        self.beginLoading = begin
        self.endLoading = end
    }
    
    // 每次请求开始时调用
    func willSend(_ request: RequestType, target: TargetType) {
        lock.lock()
        defer { lock.unlock() }
        
        if requestCount == 0 {
            DispatchQueue.main.async(execute: beginLoading)
        }
        requestCount += 1
    }
    
    // 每次请求结束时调用
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        lock.lock()
        defer { lock.unlock() }
        
        requestCount -= 1
        if requestCount == 0 {
            DispatchQueue.main.async(execute: endLoading)
        }
    }
}
