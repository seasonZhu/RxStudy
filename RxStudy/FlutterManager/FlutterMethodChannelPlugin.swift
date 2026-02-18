//
//  FlutterMethodChannelPlugin.swift
//  RxStudy
//
//  Created by dy on 2025/5/23.
//  Copyright © 2025 season. All rights reserved.
//

#if canImport(Flutter)
import Foundation

import Flutter

class FlutterMethodChannelPlugin: NSObject {
    private func createMethodChannel(registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "com.lostsakura.www.RxStudy",
                                                 binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(self, channel: methodChannel)
    }
}

extension FlutterMethodChannelPlugin: FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = FlutterMethodChannelPlugin()
        plugin.createMethodChannel(registrar: registrar)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "pop":
            // Tools.currentNC()?.popViewController(animated: true)
            result("收到从Flutter要求返回的通信,并且已经执行")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
#endif
