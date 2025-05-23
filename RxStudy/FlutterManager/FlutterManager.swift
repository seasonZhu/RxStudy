//
//  FlutterManager.swift
//  RxStudy
//
//  Created by dy on 2025/5/23.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import Flutter
import FlutterPluginRegistrant

final class FlutterManager {
    private static var _shared: FlutterManager?
    
    private(set) var flutterEngine: FlutterEngine?
    
    private var methodChannel: FlutterMethodChannel!
    
    static func shared() -> FlutterManager {
        guard  let shared = _shared else {
            _shared = FlutterManager()
            return _shared!
        }
        return shared
    }
    
    private init() {
        initFlutterEngine()
        listenFlutterToNativeMessage()
    }
    
    func destoryInstance() {
        FlutterManager._shared = nil
    }
    
    func setFlutterEngineToNil() {
        flutterEngine = nil
    }
    
    func updateFlutterEngine(withEntrypoint: String? = nil, libraryURI: String? = nil, initialRoute: String? = nil, entrypointArgs: [String] = []) -> Bool {
        guard let flutterEngine else {
            return false
        }
        
        return flutterEngine.run(withEntrypoint: withEntrypoint, libraryURI: libraryURI, initialRoute: initialRoute, entrypointArgs: entrypointArgs)
    }
    
    func nativeNotifyToFlutter(type: InvokeMethodType, jsonString: String) {
        methodChannel.invokeMethod(type.rawValue, arguments: jsonString) { flutterReturnMessage in
            guard let message = flutterReturnMessage as? String else {
                return
            }
            print("flutter callback message:\(message)")
        }
    }
}

extension FlutterManager {
    private func initFlutterEngine() {
        flutterEngine = FlutterEngine(name: "com.season.www.Template")
        
        guard let flutterEngine else {
            return
        }
        
        flutterEngine.run()
        
        GeneratedPluginRegistrant.register(with: flutterEngine)
    }
    
    private func listenFlutterToNativeMessage() {
        guard let flutterEngine else {
            return
        }
        
        methodChannel = FlutterMethodChannel(name: "com.lostsakura.www.RxStudy",
                                             binaryMessenger: flutterEngine.binaryMessenger)
        
        methodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) in
            /// 这里将Flutter传过来的字符串方法,转为Swift枚举进行区分
            guard let methodCallType = FlutterMethodCallType(rawValue: call.method) else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            switch methodCallType {
            case .pop:
                print("收到从Flutter要求返回的通信")
                result("收到从Flutter要求返回的通信,并且已经执行")
            case .tokenOverdue:
                print("token过期")
            }
        })
    }
}
