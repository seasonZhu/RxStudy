//
//  flutter-bridge-tests.swift
//  RxStudy - Flutter 通信隔离测试
//
//  Created by Codex on 2026/10/19.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import UIKit
import Flutter
import FlutterPluginRegistrant

/// 仅记录原有账号操作；不在桥接测试中替换或重构 UIKit 认证逻辑。
final class AccountManager {
    static let shared = AccountManager()
    var username: String?
    var password: String?
    var logins = 0
    var logouts = 0
    func autoLogin() { logins += 1 }
    func clearAccountInfo() { logouts += 1; username = nil; password = nil }
}

@main
struct FlutterBridgeTests {
    static func reply(_ channel: FlutterMethodChannel, method: String, arguments: Any? = nil) -> Any? {
        var count = 0
        var value: Any?
        channel.receive(method, arguments) { count += 1; value = $0 }
        precondition(count == 1, "每个 Dart 方法必须恰好回复一次")
        return value
    }

    static func main() {
        testStartupAndRebuild()
        testFailureAndRetry()
        testReadinessTimeout()
        testLoginArgumentsSurviveRebuild()
        print("Flutter 桥接测试通过：握手、启动与重建、单页面关联、失败重试、超时、消息合并、旧消息隔离和逐次回复")
    }

    static func testStartupAndRebuild() {
        var engines: [FlutterEngine] = []
        let manager = FlutterManager(makeEngine: {
            let engine = FlutterEngine(name: "测试")
            engines.append(engine)
            return engine
        })
        let presenter = UIViewController()
        var opened = 0
        var openError: Error?
        manager.synchronizeLogin(json: "初始登录", password: "初始密码")
        manager.prepare()
        manager.present(from: presenter) { error in opened += 1; openError = error }
        precondition(engines.count == 1 && engines[0].runs == 1)
        precondition(engines[0].arguments == ["初始登录", "初始密码"])
        precondition(opened == 0 && presenter.presentedViewController == nil)
        let channel = FlutterMethodChannel.channels.last!
        let staleHandler = channel.handler!
        var superseded = 0
        manager.nativeNotifyToFlutter(type: .nativeLogout, jsonString: "退出") { value in
            precondition(value is FlutterError); superseded += 1
        }
        manager.synchronizeLogin(json: "最新登录", password: "最新密码")
        precondition(superseded == 1 && channel.sent.isEmpty)
        var duplicateError: Error?
        manager.present(from: presenter) { duplicateError = $0 }
        precondition(duplicateError != nil)
        _ = reply(channel, method: "ready")
        precondition(opened == 1 && openError == nil && presenter.presentedViewController != nil)
        precondition(channel.sent.count == 1 && channel.sent[0].0 == "nativeLogin")
        precondition(channel.sent[0].1 as? String == "最新登录")
        _ = reply(channel, method: "ready")
        precondition(opened == 1 && channel.sent.count == 1 && engines[0].runs == 1)
        precondition(reply(channel, method: "unknown") as AnyObject === FlutterMethodNotImplemented)
        precondition(reply(channel, method: "login", arguments: "非法 JSON") is FlutterError)
        precondition(AccountManager.shared.logins == 0)
        _ = reply(channel, method: "tokenOverdue")

        var completed = 0
        manager.nativeNotifyToFlutter(type: .userLocationUpdate, jsonString: "位置") { value in
            precondition(value is FlutterError); completed += 1
        }
        precondition(channel.sent.count == 1, "上一条消息回复前不能并发写入账号状态")
        channel.sent[0].2("账号已同步")
        precondition(channel.sent.count == 2)
        let lateReply = channel.sent.last!.2
        _ = reply(channel, method: "login", arguments: "{\"username\":\"用户\",\"password\":\"密码\"}")
        precondition(AccountManager.shared.logins == 1 && AccountManager.shared.username == "用户")
        precondition(completed == 1 && engines[0].destroys == 0, "可见引擎必须先完成回复和页面关闭")
        lateReply("晚到的旧回复")
        precondition(completed == 1)
        manager.synchronizeLogin(json: "原生认证结果", password: "密码")
        precondition(engines.count == 1)
        _ = reply(channel, method: "logout")
        precondition(AccountManager.shared.logouts == 1)
        _ = reply(channel, method: "pop")
        precondition(engines[0].destroys == 1 && presenter.presentedViewController == nil)
        precondition(channel.handler == nil && FlutterEventChannel.channels.last!.handler == nil)

        var reopened = 0
        manager.present(from: presenter) { precondition($0 == nil); reopened += 1 }
        precondition(engines.count == 2 && engines[1].arguments.isEmpty)
        var oldReply: Any?
        staleHandler(FlutterMethodCall(method: "login", arguments: "{}")) { oldReply = $0 }
        precondition(oldReply is FlutterError && AccountManager.shared.logins == 1)
        let secondChannel = FlutterMethodChannel.channels.last!
        _ = reply(secondChannel, method: "ready")
        precondition(reopened == 1 && engines[1].runs == 1)
        _ = reply(secondChannel, method: "pop")
        precondition(engines[1].destroys == 0, "普通关闭保留已运行引擎")
        manager.present(from: presenter) { precondition($0 == nil); reopened += 1 }
        precondition(reopened == 2 && engines.count == 2 && engines[1].runs == 1)
    }

    static func testFailureAndRetry() {
        var engines: [FlutterEngine] = []
        let manager = FlutterManager(makeEngine: {
            let engine = FlutterEngine(name: "测试")
            engine.succeeds = !engines.isEmpty
            engines.append(engine)
            return engine
        })
        let registrations = GeneratedPluginRegistrant.registrations
        var failures = 0
        let presenter = UIViewController()
        manager.present(from: presenter) { if $0 != nil { failures += 1 } }
        precondition(failures == 1 && engines[0].destroys == 1)
        precondition(GeneratedPluginRegistrant.registrations == registrations)
        manager.present(from: presenter) { precondition($0 == nil) }
        precondition(engines.count == 2)
        precondition(GeneratedPluginRegistrant.registrations == registrations + 1)
        let channel = FlutterMethodChannel.channels.last!
        precondition(reply(channel, method: "pop") is FlutterError)
        _ = reply(channel, method: "ready")
        precondition(presenter.presentedViewController != nil)
    }

    static func testLoginArgumentsSurviveRebuild() {
        var engines: [FlutterEngine] = []
        let manager = FlutterManager(makeEngine: {
            let engine = FlutterEngine(name: "账号重建测试")
            engines.append(engine)
            return engine
        })
        let presenter = UIViewController()
        manager.present(from: presenter)
        let channel = FlutterMethodChannel.channels.last!
        _ = reply(channel, method: "ready")
        let json = "{\"username\":\"新用户\",\"password\":\"新密码\"}"
        _ = reply(channel, method: "login", arguments: json)
        _ = reply(channel, method: "pop")
        // 即使原生自动登录尚未返回，下一次启动也不能使用旧账号参数。
        manager.present(from: presenter)
        precondition(engines.count == 2 && engines[1].arguments == [json, "新密码"])
        _ = reply(FlutterMethodChannel.channels.last!, method: "ready")
    }

    static func testReadinessTimeout() {
        let engine = FlutterEngine(name: "超时测试")
        let manager = FlutterManager(makeEngine: { engine }, readinessTimeout: 0.01)
        let presenter = UIViewController()
        var failures = 0
        manager.present(from: presenter) { if $0 != nil { failures += 1 } }
        let limit = Date().addingTimeInterval(1)
        while failures == 0 && Date() < limit {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        precondition(failures == 1 && engine.destroys == 1 && presenter.presentedViewController == nil)
    }
}
