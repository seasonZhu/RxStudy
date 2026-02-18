//
//  NetworkRequestLoggerPlugin.swift
//  RxStudy
//
//  Created by dy on 2024/5/7.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation

import Alamofire
import Moya

import CocoaLumberjack

public enum NetworkRequestLoggerLevel {
    case off
    
    case debug

    case info

    case warn
    
    case error

    case fatal
}

/// 该插件弃用
public class NetworkRequestLoggerPlugin: PluginType {

    public var level: NetworkRequestLoggerLevel
    
    private let queue = DispatchQueue(label: "\(NetworkRequestLoggerPlugin.self) Queue")
    
    private var startTime: TimeInterval?
    
    init(level: NetworkRequestLoggerLevel = .info) {
        self.level = level
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        queue.async {
            self.startTime = CFAbsoluteTimeGetCurrent()
            
            /// Moya更新了,此时的request是RequestTypeWrapper类型,不再是DataRequest,导致转换失败,无法正常打印日志,直接使用AlamofireNetworkActivityLogger就可以了
            guard let dataRequest = request as? DataRequest,
                let task = dataRequest.task,
                let request = task.originalRequest,
                let httpMethod = request.httpMethod,
                let requestURL = request.url
                else {
                    return
            }
            
            switch self.level {
            case .debug:
                let cURL = dataRequest.cURLDescription()
                
                self.logDivider()
                
                print("\(httpMethod) '\(requestURL.absoluteString)':")
                
                print("cURL:\n\(cURL)")
            case .info:
                self.logDivider()
                
                print("\(httpMethod) '\(requestURL.absoluteString)'")
            default:
                break
            }
        }
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        queue.async {
            let response: Moya.Response?
            
            switch result {
            case .success(let success):
                response = success
            case .failure(let failure):
                response = failure.response
            }
            
            guard let response,
                let request = response.request,
                let httpMethod = request.httpMethod,
                let requestURL = request.url
                else {
                    return
            }
            
            var elapsedTime: TimeInterval = 0
            
            if let startTime = self.startTime {
                elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
            }
            
            if let error = result.moyaError {
                switch self.level {
                case .debug, .info, .warn, .error:
                    self.logDivider()
                    
                    print("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                    print(error)
                default:
                    break
                }
            } else {
                guard let HTTPURLResponse = response.response else {
                    return
                }
                
                switch self.level {
                case .debug:
                    self.logDivider()
                    
                    print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
                    
                    self.logHeaders(headers: HTTPURLResponse.allHeaderFields)
                    
                    let data = response.data
                    
                    print("Body:")
                    
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                        let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                        
                        if let prettyString = String(data: prettyData, encoding: .utf8) {
                            print(prettyString)
                        }
                    } catch {
                        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                            print(string)
                        }
                    }
                case .info:
                    self.logDivider()
                    
                    print("\(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]")
                default:
                    break
                }
            }
            
            self.startTime = nil
        }
    }
}

private extension NetworkRequestLoggerPlugin {
    func logDivider() {
        print("---------------------")
    }
    
    func logHeaders(headers: [AnyHashable: Any]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key): \(value)")
        }
        print("]")
    }
    
    func logHeadersInSandBox(headers: [AnyHashable: Any]) {
        
        /// 优化在沙盒中的打印
        let strings = headers.map({
            return "  \($0.key): \($0.value)"
        }).joined(separator: "\n")
    
        // DDLogInfo not available - CocoaLumberjack API changed
        print("Headers: [ \(strings) ]")

    }
}
