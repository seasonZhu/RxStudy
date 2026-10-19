//
//  FlutterManager.swift
//  RxStudy
//
//  Created by dy on 2025/5/23.
//  Copyright © 2025 season. All rights reserved.
//

#if canImport(Flutter) && canImport(FlutterPluginRegistrant)
import UIKit
import Flutter
import FlutterPluginRegistrant

/// 引擎、通信和页面关联由此统一维护，调用者不再判断引擎状态。
final class FlutterManager {
    private enum Phase { case idle, waitingForDart, ready, retiring }

    private struct Message {
        let type: InvokeMethodType
        let arguments: String
        let completion: ((Any?) -> Void)?
    }

    private static let instance = FlutterManager()
    static func shared() -> FlutterManager { instance }

    private let makeEngine: () -> FlutterEngine
    private let registerPlugins: (FlutterEngine) -> Void
    private let readinessTimeout: TimeInterval
    private var phase = Phase.idle
    private var engine: FlutterEngine?
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: NativeEventChannel?
    private weak var activeController: FlutterViewController?
    private var initialArguments: [String] = []
    private var pendingPreparations: [(Result<FlutterEngine, Error>) -> Void] = []
    private var pendingMessages: [Message] = []
    private var inFlightMessages: [UUID: (Any?) -> Void] = [:]
    private var sendingIdentifier: UUID?
    private var timeout: DispatchWorkItem?
    private var isOpening = false

    init(makeEngine: @escaping () -> FlutterEngine = { FlutterEngine(name: "com.season.www.Template") },
         registerPlugins: @escaping (FlutterEngine) -> Void = { GeneratedPluginRegistrant.register(with: $0) },
         readinessTimeout: TimeInterval = 15) {
        self.makeEngine = makeEngine
        self.registerPlugins = registerPlugins
        self.readinessTimeout = readinessTimeout
    }

    /// 预热与展示共用启动过程；收到 Dart 的 ready 才认为通信可用。
    func prepare() {
        onMain {
            self.prepareEngine { result in
                if case .failure(let error) = result { print(error.localizedDescription) }
            }
        }
    }

    func synchronizeLogin(json: String, password: String) {
        onMain {
            self.initialArguments = [json, password]
            switch self.phase {
            case .idle: self.prepare()
            case .waitingForDart, .ready:
                self.send(Message(type: .nativeLogin, arguments: json, completion: nil))
            case .retiring:
                // Flutter 发起认证后不回传给旧引擎；新引擎通过启动参数恢复最新账号。
                break
            }
        }
    }

    func nativeNotifyToFlutter(type: InvokeMethodType, jsonString: String,
                               flutterReturnMessageCallback: ((Any?) -> Void)? = nil) {
        onMain {
            if type == .nativeLogout { self.initialArguments = [] }
            self.send(Message(type: type, arguments: jsonString, completion: flutterReturnMessageCallback))
        }
    }

    func present(from presenter: UIViewController, completion: ((Error?) -> Void)? = nil) {
        onMain {
            guard !self.isOpening, presenter.presentedViewController == nil,
                  self.activeController?.presentingViewController == nil else {
                completion?(BridgeError.pageAlreadyOpen)
                return
            }
            self.isOpening = true
            self.prepareEngine { [weak self, weak presenter] result in
                guard let self else { return }
                self.isOpening = false
                switch result {
                case .failure(let error): completion?(error)
                case .success(let engine):
                    guard let presenter, presenter.viewIfLoaded?.window != nil,
                          presenter.presentedViewController == nil else {
                        completion?(BridgeError.presenterUnavailable)
                        return
                    }
                    engine.viewController = nil
                    let controller = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
                    self.activeController = controller
                    controller.modalPresentationStyle = .fullScreen
                    controller.setFlutterViewDidRenderCallback { [weak self] in
                        self?.eventChannel?.eventSink?("这是从Native持续传过来来的消息")
                    }
                    presenter.present(controller, animated: true) { completion?(nil) }
                }
            }
        }
    }

    private func prepareEngine(completion: @escaping (Result<FlutterEngine, Error>) -> Void) {
        if phase == .retiring {
            guard activeController?.presentingViewController == nil else {
                completion(.failure(BridgeError.pageAlreadyOpen))
                return
            }
            tearDown(error: BridgeError.engineReplaced)
        }
        if phase == .ready, let engine {
            completion(.success(engine))
            return
        }
        pendingPreparations.append(completion)
        guard phase == .idle else { return }
        let engine = makeEngine()
        self.engine = engine
        phase = .waitingForDart
        guard engine.run(withEntrypoint: nil, libraryURI: nil, initialRoute: nil,
                         entrypointArgs: initialArguments) else {
            tearDown(error: BridgeError.startFailed)
            return
        }
        registerPlugins(engine)
        let channel = FlutterMethodChannel(name: "com.lostsakura.www.RxStudy", binaryMessenger: engine.binaryMessenger)
        methodChannel = channel
        eventChannel = NativeEventChannel(name: "nativeEvent", binaryMessenger: engine.binaryMessenger,
                                          sendMessage: "这是从Native传递过来的消息")
        channel.setMethodCallHandler { [weak self, weak engine] call, result in
            guard let self else {
                result(FlutterError(code: "engine_replaced", message: "消息所属引擎已释放", details: nil))
                return
            }
            self.onMain { [weak self, weak engine] in
                guard let self, let engine, self.engine === engine else {
                    result(FlutterError(code: "engine_replaced", message: "消息所属引擎已释放", details: nil))
                    return
                }
                self.receive(call, result: result)
            }
        }
        let work = DispatchWorkItem { [weak self, weak engine] in
            guard let self, let engine, self.engine === engine, self.phase == .waitingForDart else { return }
            self.tearDown(error: BridgeError.dartNotReady)
        }
        timeout = work
        DispatchQueue.main.asyncAfter(deadline: .now() + readinessTimeout, execute: work)
    }

    private func send(_ message: Message) {
        switch phase {
        case .ready, .waitingForDart:
            if message.type == .nativeLogin || message.type == .nativeLogout {
                let superseded = pendingMessages.filter { $0.type == .nativeLogin || $0.type == .nativeLogout }
                pendingMessages.removeAll { $0.type == .nativeLogin || $0.type == .nativeLogout }
                pendingMessages.append(message)
                superseded.forEach { $0.completion?(flutterError(BridgeError.messageSuperseded)) }
            } else {
                pendingMessages.append(message)
            }
            sendNextMessage()
        case .idle, .retiring:
            message.completion?(flutterError(BridgeError.notRunning))
        }
    }

    private func sendNextMessage() {
        guard phase == .ready, sendingIdentifier == nil, !pendingMessages.isEmpty, let methodChannel else { return }
        let message = pendingMessages.removeFirst()
        let identifier = UUID()
        sendingIdentifier = identifier
        if let completion = message.completion { inFlightMessages[identifier] = completion }
        // 等待前一条回复后再发送，避免 Dart 的异步凭证写入互相覆盖。
        methodChannel.invokeMethod(message.type.rawValue, arguments: message.arguments) { [weak self] value in
            self?.onMain { [weak self] in
                guard let self, self.sendingIdentifier == identifier else { return }
                self.sendingIdentifier = nil
                self.inFlightMessages.removeValue(forKey: identifier)?(value)
                self.sendNextMessage()
            }
        }
    }

    private func receive(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let type = FlutterMethodCallType(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        switch type {
        case .ready:
            // 先回复握手，再发送缓冲消息或展示页面，避免嵌套调用阻塞初始化。
            result("原生通信已就绪")
            guard phase == .waitingForDart, let engine else { return }
            timeout?.cancel()
            timeout = nil
            phase = .ready
            let preparations = pendingPreparations
            pendingPreparations.removeAll()
            sendNextMessage()
            preparations.forEach {
                if self.engine === engine, phase == .ready {
                    $0(.success(engine))
                } else {
                    $0(.failure(BridgeError.engineReplaced))
                }
            }
        case .pop:
            guard let controller = activeController else {
                result(FlutterError(code: "no_flutter_page", message: "没有可关闭的 Flutter 页面", details: nil))
                return
            }
            result("收到从Flutter要求返回的通信,并且已经执行")
            controller.dismiss(animated: true) { [weak self, weak controller] in
                guard let self, self.activeController === controller else { return }
                self.activeController = nil
                if self.phase == .retiring {
                    self.tearDown(error: BridgeError.engineReplaced)
                } else {
                    self.engine?.viewController = nil
                }
            }
        case .tokenOverdue:
            print("token过期")
            result("已接收凭证过期通知")
        case .logout:
            result("原生已接收退出通知")
            retire()
            initialArguments = []
            AccountManager.shared.clearAccountInfo()
        case .login:
            guard let json = call.arguments as? String, let data = json.data(using: .utf8),
                  let info = try? JSONDecoder().decode(AccountInfo.self, from: data),
                  let username = info.username, !username.isEmpty,
                  let password = info.password, !password.isEmpty else {
                result(FlutterError(code: "invalid_arguments", message: "登录消息缺少有效账号信息", details: nil))
                return
            }
            result("原生已接收登录通知")
            initialArguments = [json, password]
            retire()
            // 继续使用 UIKit 原有的凭证保存与自动登录流程。
            AccountManager.shared.username = username
            AccountManager.shared.password = password
            AccountManager.shared.autoLogin()
        }
    }

    private func retire() {
        phase = .retiring
        timeout?.cancel()
        timeout = nil
        let messages = pendingMessages
        pendingMessages.removeAll()
        let preparations = pendingPreparations
        pendingPreparations.removeAll()
        messages.forEach { $0.completion?(flutterError(BridgeError.engineReplaced)) }
        let inFlight = inFlightMessages
        inFlightMessages.removeAll()
        sendingIdentifier = nil
        inFlight.values.forEach { $0(flutterError(BridgeError.engineReplaced)) }
        preparations.forEach { $0(.failure(BridgeError.engineReplaced)) }
    }

    private func tearDown(error: BridgeError) {
        timeout?.cancel()
        timeout = nil
        let oldEngine = engine
        methodChannel?.setMethodCallHandler(nil)
        eventChannel?.invalidate()
        methodChannel = nil
        eventChannel = nil
        engine = nil
        phase = .idle
        oldEngine?.viewController = nil
        oldEngine?.destroyContext()
        let messages = pendingMessages
        pendingMessages.removeAll()
        let preparations = pendingPreparations
        pendingPreparations.removeAll()
        let inFlight = inFlightMessages
        inFlightMessages.removeAll()
        sendingIdentifier = nil
        messages.forEach { $0.completion?(flutterError(error)) }
        inFlight.values.forEach { $0(flutterError(error)) }
        preparations.forEach { $0(.failure(error)) }
    }

    deinit {
        timeout?.cancel()
        methodChannel?.setMethodCallHandler(nil)
        eventChannel?.invalidate()
        engine?.viewController = nil
        engine?.destroyContext()
    }

    private func onMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread { action() } else { DispatchQueue.main.async(execute: action) }
    }

    private func flutterError(_ error: BridgeError) -> FlutterError {
        FlutterError(code: error.rawValue, message: error.localizedDescription, details: nil)
    }

    private enum BridgeError: String, LocalizedError {
        case startFailed, dartNotReady, pageAlreadyOpen, presenterUnavailable
        case engineReplaced, notRunning, messageSuperseded

        var errorDescription: String? {
            switch self {
            case .startFailed: return "Flutter 引擎启动失败，请重试"
            case .dartNotReady: return "Flutter 通信初始化超时，请重试"
            case .pageAlreadyOpen: return "Flutter 页面正在打开或已经显示"
            case .presenterUnavailable: return "当前页面无法展示 Flutter"
            case .engineReplaced: return "Flutter 引擎将在下次打开时重建"
            case .notRunning: return "Flutter 通信尚未启动或正在等待重建"
            case .messageSuperseded: return "消息已被更新的账号状态替代"
            }
        }
    }
}
#endif
