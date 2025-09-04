//
//  ResponseCachePlugin.swift
//  RxStudy
//
//  Created by dy on 2024/1/11.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

import Moya

extension String {
    var SHA256: String {
        guard let data = data(using: .utf8) else {
            return ""
        }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes({ byte in
            _ = CC_SHA256(byte.baseAddress, CC_LONG(data.count), &hash)
        })
        
        let hashData = Data(hash)
        let result = hashData.map { String(format: "%02x", $0) }.joined()
        print("SHA256--->>>>\(result)")
        return result
    }
}

// MARK: - 写了一个胶水协议,便于让遵守协议的缓存架构都可以进行缓存
protocol ResponseCacheConvertible {

    func loadData(forKey key: String) throws -> Data?

    func saveData(_ object: Data, forKey key: String) throws
        
    func clearAllData()

    func clearData(by key: String)
}

// MARK: - 使用Cache作为缓存
#if canImport(Cache)
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
        try setObject(data, forKey: key)
    }
    
    func clearAllData() {
        try? removeAll()
    }
    
    func clearData(by key: String) {
        removeObject(forKey: key)
    }
}
#endif

// MARK: - 使用YYCache做缓存
#if canImport(YYCache)
import YYCache

let yyResponseCache = YYCache(name: "yyResponseCache")!

extension YYCache: ResponseCacheConvertible {
    func loadData(forKey key: String) throws -> Data? {
        let nsData = object(forKey: key.SHA256)
        return nsData as? Data
    }
    
    func saveData(_ object: Data, forKey key: String) throws {
        let nsData = object as NSData
        setObject(nsData, forKey: key.SHA256)
    }
    
    func clearAllData() {
        return removeAllObjects()
    }
    
    func clearData(by key: String) {
        removeObject(forKey: key)
    }
}
#endif

// MARK: - 使用系统自带的UserDefaults也可以做缓存
let userDefaultsCache = UserDefaults(suiteName: "userDefaultsCache")!

extension UserDefaults: ResponseCacheConvertible {
    func loadData(forKey key: String) throws -> Data? {
        data(forKey: key.SHA256)
    }
    
    func saveData(_ data: Data, forKey key: String) throws {
        set(data, forKey: key.SHA256)
    }
    
    func clearAllData() {
        let dict = dictionaryRepresentation()
        for key in dict.keys {
            removeObject(forKey: key)
        }
    }
    
    func clearData(by key: String) {
        removeObject(forKey: key)
    }
}

// MARK: - 响应缓存插件
class ResponseCachePlugin: PluginType {
    
    private let cache: any ResponseCacheConvertible
    
    /// 白名单判断闭包
    private let shouldCache: (TargetType) -> Bool
    
    /// 默认7天
    private let cacheDuration: TimeInterval

    private let queue = DispatchQueue(label: "com.network.cache.plugin")
    
    init(cache: any ResponseCacheConvertible = userDefaultsCache,
         shouldCache: @escaping (TargetType) -> Bool = { _ in true },
         cacheDuration: TimeInterval = 86400 * 7) {
        self.cache = cache
        self.shouldCache = shouldCache
        self.cacheDuration = cacheDuration
    }
    
    func process(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) -> Swift.Result<Moya.Response, MoyaError> {
        
        guard shouldCache(target) else {
            return result
        }

        switch result {
        case .success(let response):
            saveResponse(response: response, target: target)
            return result
        case .failure:
            if let respone = getResponse(target: target) {
                return .success(respone)
            }
            
            return result
        }
    }
    
    func clearResponseCache() {
        cache.clearAllData()
    }
    
    private func saveResponse(response: Response, target: TargetType) {
        queue.async { [weak self] in
            /// 白名单二次校验
            guard self?.shouldCache(target) == true else { return }
            
            let cacheObject = CacheObject(
                data: response.data,
                statusCode: response.statusCode,
                headers: response.response?.allHeaderFields as? [String: String],
                timestamp: Date().timeIntervalSince1970
            )
            
            if let data = try? JSONEncoder().encode(cacheObject) {
                try? self?.cache.saveData(data, forKey: "\(target.path)\(target.task.parametersString)")
            }
        }
    }
    
    private func getResponse(target: TargetType) -> Moya.Response? {
        /// 白名单二次校验
        guard shouldCache(target) else { return nil }
        
        let key = "\(target.path)\(target.task.parametersString)"
        guard let data = try? cache.loadData(forKey: key),
              let cacheObject = try? JSONDecoder().decode(CacheObject.self, from: data) else {
            return nil
        }

        /// 检查缓存是否过期
        if Date().timeIntervalSince1970 - cacheObject.timestamp > cacheDuration {
            cache.clearData(by: key)
            return nil
        }

        return Response(statusCode: cacheObject.statusCode,
                        data: cacheObject.data,
                        response: HTTPURLResponse(url: target.baseURL.appendingPathComponent(target.path),
                                                  statusCode: cacheObject.statusCode,
                                                  httpVersion: nil,
                                                  headerFields: cacheObject.headers
                                                 )
        )
    }
}

extension ResponseCachePlugin {
    // 缓存数据模型
    struct CacheObject: Codable {
        let data: Data
        let statusCode: Int
        let headers: [String: String]?
        let timestamp: TimeInterval
    }
}

extension Moya.Task {
    var parametersString: String {
        switch self {
        case .requestPlain:
            return ""
        case .requestData(let data):
            return String(data: data, encoding: .utf8) ?? ""
        case .requestJSONEncodable(let encodable), .requestCustomJSONEncodable(let encodable, _):
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(encodable), let string = String(data: data, encoding: .utf8) {
                return string
            } else {
                return ""
            }
        case .requestParameters(let parameters, _):
            if let data = try? JSONSerialization.data(withJSONObject: parameters), let string = String(data: data, encoding: .utf8) {
                return string
            } else {
                return ""
            }
        case .requestCompositeData(let bodyData, let urlParameters):
            if let data = try? JSONSerialization.data(withJSONObject: urlParameters),
               let urlString = String(data: data, encoding: .utf8),
               let string = String(data: bodyData, encoding: .utf8) {
                return "\(urlString)\(string)"
            } else {
                return ""
            }
        case .requestCompositeParameters(let bodyParameters, _, let urlParameters):
            var newBodyParameters = bodyParameters
            for (k, v) in urlParameters {
                newBodyParameters[k] = v
            }
            if let data = try? JSONSerialization.data(withJSONObject: newBodyParameters), let string = String(data: data, encoding: .utf8) {
                return string
            } else {
                return ""
            }
        /// 这里认为上传下载的response不需要通过入参进行数据缓存没有差异化
        case .uploadFile, .uploadMultipart, .uploadCompositeMultipart, .downloadDestination, .downloadParameters:
            return ""
        }
    }
}
