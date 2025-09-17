//
//  NetworkDebuggingPlugin.swift
//  RxStudy
//
//  Created by dy on 2025/9/16.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import Alamofire
import Moya

/// 网络打印，DEBUG模式内置插件
/// Network printing, DEBUG mode built in plugin.
public struct NetworkDebuggingPlugin {
    
    public let options: NetworkDebuggingPlugin.Options
    
    public init(options: NetworkDebuggingPlugin.Options = .all) {
        self.options = options
    }
}

extension NetworkDebuggingPlugin {
    public struct Options: Equatable {
        /// This plugin has all the log records.
        public static let all = Options(logOptions: LogOptions.all)
        /// Concise printing log, has plugins and success body and error body.
        public static let concise = Options(logOptions: LogOptions.concise)
        /// Neither the request's nor the body of a response will be logged.
        public static let nothing = Options(logOptions: LogOptions.haveNothing)
        
        let logOptions: LogOptions
        
        public init(logOptions: LogOptions) {
            self.logOptions = logOptions
        }
    }
    
    /// Enable print request information.
    var openDebugRequest: Bool {
        if options.logOptions.contains(.requestMethod) {
            return true
        }
        if options.logOptions.contains(.requestBodyStream) {
            return true
        }
        if options.logOptions.contains(.requestHeaders) {
            return true
        }
        if options.logOptions.contains(.requestParameters) {
            return true
        }
        return false
    }
    
    /// Turn on printing the response result.
    var openDebugResponse: Bool {
        if options.logOptions.contains(.responseBody) {
            return true
        }

        return false
    }
}

extension NetworkDebuggingPlugin.Options {
    public struct LogOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        /// Neither the request's nor the body of a response will be logged.
        public static let haveNothing: LogOptions = LogOptions(rawValue: 1 << 0)
        
        /// The request's method will be logged.
        public static let requestMethod: LogOptions = LogOptions(rawValue: 1 << 1)
        /// The request's body stream will be logged.
        public static let requestBodyStream: LogOptions = LogOptions(rawValue: 1 << 2)
        /// The request's headers will be logged.
        public static let requestHeaders: LogOptions = LogOptions(rawValue: 1 << 3)
        /// The request's parameters will be logged.
        public static let requestParameters: LogOptions = LogOptions(rawValue: 1 << 4)
        
        /// The body of a response that is a success will be logged.
        public static let responseBody: LogOptions = LogOptions(rawValue: 1 << 87)
        
        /// Enable print request information.
        public static let request: LogOptions = [requestMethod, requestBodyStream, requestHeaders, requestParameters]
        /// Turn on printing the response result.
        public static let response: LogOptions = [responseBody]
        /// Open the request log and response log at the same time.
        public static let all: LogOptions = [request, response]
        /// Concise printing log.
        public static let concise: LogOptions = [responseBody]
        /// Diversity printing log.
        public static let diversity: LogOptions = [requestHeaders, requestParameters, responseBody]
    }
}

extension NetworkDebuggingPlugin: PluginType {
    
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        printRequest(request, target: target)
        #endif
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: any TargetType) {
        #if DEBUG
        ansysisResult(result, target: target, local: false)
        #endif
    }
}

extension NetworkDebuggingPlugin {
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale.current
        return formatter.string(from: Date())
    }
    
    private func realParameters(target: TargetType) -> Alamofire.Parameters? {
        guard options.logOptions.contains(.requestParameters) else {
            return nil
        }
        
        if case .requestParameters(let parame, _) = target.task {
            return parame
        }
        
        return nil
    }
    
    private func realHeaders(request: RequestType) -> [String: String]? {
        guard options.logOptions.contains(.requestHeaders) else {
            return nil
        }
        var allHeaders = request.sessionHeaders
        if let httpRequestHeaders = request.request?.allHTTPHeaderFields {
            allHeaders.merge(httpRequestHeaders) { $1 }
        }
        return allHeaders
    }
    
    private func realBodys(request: RequestType) -> String? {
        guard options.logOptions.contains(.requestBodyStream) else {
            return nil
        }
        return request.request?.httpBodyStream?.description
    }
    
    private func printRequest(_ request: RequestType, target: TargetType) {
        guard openDebugRequest else {
            return
        }
        
        let requestLink = request.request?.url?.absoluteString ?? "\(target.baseURL)\(target.path)"
        let prefix = """
                    ╔════════ 🎷 Prepare Request 🎷 ════════
                    ║ Time: \(dateString)
                    ║ URL: \(requestLink)\n
                    """
        let suffix = """
                    ╚══════════════════════════════════════
                    """
        var context: String = prefix
        if options.logOptions.contains(.requestMethod) {
            context += "║ Method: \(target.method.rawValue)\n"
        }
        if let value = realHeaders(request: request), !value.isEmpty {
            context += "║ Headers: \(value)\n"
        }
        if let value = realParameters(target: target), !value.isEmpty {
            context += "║ Parameters: \(value)\n"
        }
        if let value = realBodys(request: request), !value.isEmpty {
            context += "║ BodyStream: \(value)\n"
        }
        
        context += suffix
        print(context)
    }
    
    private func ansysisResult(_ result: Result<Response, MoyaError>, target: TargetType, local: Bool) {
        if !openDebugResponse {
            return
        }
        
        printResponse(result, target: target, local: false)
    }
    
    private func printResponse(_ result: Result<Response, MoyaError>, target: TargetType, local: Bool) {
        
        let isSuccess: Bool
        
        let requestLink: String
        
        var responseString: String = ""
        
        switch result {
        case .success(let response):
            isSuccess = true
            
            requestLink = response.request?.url?.absoluteString ?? "\(target.baseURL)\(target.path)"
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: response.data, options: .mutableContainers)
                let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                
                if let prettyString = String(data: prettyData, encoding: .utf8) {
                    responseString = prettyString
                }
            } catch {
                if let string = String(data: response.data, encoding: .utf8) {
                    responseString = string
                }
            }
            
        case .failure(let error):
            isSuccess = false
            
            requestLink = error.response?.request?.url?.absoluteString ?? "\(target.baseURL)\(target.path)"
        }

        let prefix = """
                ╔═══════════ 🎈 Request 🎈 ═══════════
                ║ Time: \(dateString)
                ║ URL: \(requestLink)
                ║--------------------------------------
                ║ Method: \(target.method.rawValue)
                ║ Host: \(target.baseURL.absoluteString)
                ║ Path: \(target.path)\n
                """
        let suffix = """
                ║---------- 🎈 Response 🎈 ----------
                ║ Result: \(isSuccess ? "Successed." : "Failed.")
                ║ DataType: \(local ? "Local data." : "Remote data.")
                ║ Response: \(responseString)
                ╚══════════════════════════════════════
                """
        var context: String = prefix
        if let param = realParameters(target: target), param.isEmpty == false {
            context += "║ Parameters: \(param)\n"
        }
        context += suffix
        print(context)
    }
}
