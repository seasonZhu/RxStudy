//
//  ResponseCachePlugin.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

//MARK: - 写了一个胶水协议,便于让遵守协议的缓存架构都可以进行缓存
protocol ResponseCacheConvertible {

    func loadData(forKey key: String) throws -> Data?


    func saveData(_ object: Data, forKey key: String) throws

}

//MARK: -  使用Cache作为缓存
import Cache

private let responseCacheDiskConfig = DiskConfig(name: "ResponseCache")
private let responseCacheMemoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)

let responseCacheStorage = try! Storage<String, Data>(
    diskConfig: responseCacheDiskConfig,
    memoryConfig: responseCacheMemoryConfig,
  transformer: TransformerFactory.forData()
)

extension Storage: ResponseCacheConvertible where Value == Data, Key == String {
    func loadData(forKey key: String) throws -> Data? {
        try? object(forKey: key)
    }
    
    func saveData(_ data: Data, forKey key: String) throws {
        try setObject(data , forKey: key)
    }
}

//MARK: -  使用YYCache做缓存
import YYCache

let yyResponseCache = YYCache(name: "yyResponseCache")!

extension YYCache: ResponseCacheConvertible {
    func loadData(forKey key: String) throws -> Data? {
        let nsData = object(forKey: MD5(key))
        return nsData as? Data
    }
    
    func saveData(_ object: Data, forKey key: String) throws {
        let nsData = object as NSData
        setObject(nsData, forKey: MD5(key))
    }
}

//MARK: -  使用系统自带的UserDefaults也可以做缓存
let userDefaultsCache = UserDefaults(suiteName: "userDefaultsCache")!

extension UserDefaults: ResponseCacheConvertible {
    func loadData(forKey key: String) throws -> Data? {
        data(forKey: MD5(key))
    }
    
    func saveData(_ data: Data, forKey key: String) throws {
        set(data, forKey: MD5(key))
    }
}

import Moya

//MARK: - 响应缓存插件
class ResponseCachePlugin: PluginType {
    
    let cache: any ResponseCacheConvertible
    
    init(cache: any ResponseCacheConvertible = responseCacheStorage) {
        self.cache = cache
    }
    
    func process(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) -> Swift.Result<Moya.Response, MoyaError> {

        switch result {
        case .success(let response):
            try? cache.saveData(response.data, forKey: target.path)
            return result
        case .failure:
            if let data = try? cache.loadData(forKey: target.path) {
                let respone = Moya.Response(statusCode: 600, data: data)
                return .success(respone)
            }
            
            return result
        }
    }
}

