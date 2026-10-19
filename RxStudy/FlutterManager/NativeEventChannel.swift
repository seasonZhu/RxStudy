//
//  NativeEventChannel.swift
//  RxStudy
//
//  Created by dy on 2025/5/23.
//  Copyright © 2025 season. All rights reserved.
//

#if canImport(Flutter)
import Foundation

import Flutter

/// 原生Event通信到Flutter侧
class NativeEventChannel: NSObject {
    
    /// 这个对外暴露,方便持续传值到Flutter侧
    var eventSink: FlutterEventSink?
    
    private var channel: FlutterEventChannel?

    private var sendMessage: Any?
    
    convenience init(name: String, binaryMessenger: FlutterBinaryMessenger, sendMessage: Any? = nil) {
        self.init()
        channel = FlutterEventChannel(name: name, binaryMessenger: binaryMessenger)
        channel?.setStreamHandler(self)
        self.sendMessage = sendMessage
    }

    /// 与引擎一起释放，避免旧事件处理器和回调继续持有彼此。
    func invalidate() {
        channel?.setStreamHandler(nil)
        eventSink = nil
        channel = nil
    }
}

extension NativeEventChannel: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        self.eventSink?(sendMessage)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
#endif
