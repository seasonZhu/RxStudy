//
//  ResponseCachePlugin.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

import Moya
import Cache

private let diskConfig = DiskConfig(name: "ResponseCache")
private let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

private let storage = try! Storage<String, Data>(
    diskConfig: diskConfig,
    memoryConfig: memoryConfig,
  transformer: TransformerFactory.forData()
)

//MARK: - 响应缓存插件
class ResponseCachePlugin: PluginType {
    func process(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) -> Swift.Result<Moya.Response, MoyaError> {

        switch result {
        case .success(let response):
            try? storage.setObject(response.data, forKey: target.path)
            return result
        case .failure:
            if let data = try? storage.object(forKey: target.path) {
                let respone = Moya.Response(statusCode: 600, data: data)
                return .success(respone)
            }
            
            return result
        }
    }
}

