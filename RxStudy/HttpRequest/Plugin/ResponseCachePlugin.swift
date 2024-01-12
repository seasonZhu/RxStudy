//
//  ResponseCachePlugin.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

import Moya
import Cache

private let responseCacheDiskConfig = DiskConfig(name: "ResponseCache")
private let responseCacheMemoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

private let responseCacheStorage = try! Storage<String, Data>(
    diskConfig: responseCacheDiskConfig,
    memoryConfig: responseCacheMemoryConfig,
  transformer: TransformerFactory.forData()
)

/// 写了一个胶水协议,便于让遵守协议的缓存架构都可以进行缓存
protocol ResponseCacheConvertible {

    func data(forKey key: String) throws -> Data?


    func setData(_ object: Data, forKey key: String) throws

}

extension Storage: ResponseCacheConvertible where Value == Data, Key == String {
    func data(forKey key: String) throws -> Data? {
        try? object(forKey: key)
    }
    
    func setData(_ data: Data, forKey key: String) throws {
        try setObject(data , forKey: key)
    }
}

//MARK: - 响应缓存插件
class ResponseCachePlugin: PluginType {
    
    let cache: any ResponseCacheConvertible
    
    init(cache: any ResponseCacheConvertible = responseCacheStorage) {
        self.cache = cache
    }
    
    func process(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) -> Swift.Result<Moya.Response, MoyaError> {

        switch result {
        case .success(let response):
            try? cache.setData(response.data, forKey: target.path)
            return result
        case .failure:
            if let data = try? cache.data(forKey: target.path) {
                let respone = Moya.Response(statusCode: 600, data: data)
                return .success(respone)
            }
            
            return result
        }
    }
}

