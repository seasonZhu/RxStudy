//
//  NativeEventChannel.swift
//  RxStudy
//
//  Created by dy on 2025/5/23.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import Flutter

/// 原生通信到Flutter侧
class NativeEventChannel: NSObject {
    
    private var channel: FlutterEventChannel?

    private var events: FlutterEventSink?
    
    private var sendMessage: Any?
    
    convenience init(name: String, binaryMessenger: FlutterBinaryMessenger, sendMessage: Any? = nil) {
        self.init()
        channel = FlutterEventChannel(name: name, binaryMessenger: binaryMessenger)
        channel?.setStreamHandler(self)
        self.sendMessage = sendMessage
    }
}

extension NativeEventChannel: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.events = events
        self.events?(sendMessage)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.events = nil
        return nil
    }
}
