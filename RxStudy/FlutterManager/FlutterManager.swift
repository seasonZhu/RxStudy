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
    
    var isFlutterEngineRun: Bool = false
    
    @discardableResult
    static func shared() -> FlutterManager {
        guard  let shared = _shared else {
            _shared = FlutterManager()
            return _shared!
        }
        return shared
    }
    
    private init() {
        initFlutterEngine()
    }
    
    @discardableResult
    func initFlutterEngine() -> FlutterEngine {
        flutterEngine = FlutterEngine(name: "com.season.www.Template")
        
        return flutterEngine!
        
//        guard let flutterEngine else {
//            return
//        }
        // 注意一个flutterEngine只能run一次,要么就把传参传好,要么就需要将flutterEngine置空重新再run!
        // flutterEngine.run()
    }
    
    func destoryInstance() {
        flutterEngine = nil
        methodChannel = nil
        isFlutterEngineRun = false
        FlutterManager._shared = nil
    }
    
    func setFlutterEngineToNil() {
        flutterEngine = nil
    }
    
    @discardableResult
    func runFlutterEngine(withEntrypoint: String? = nil, libraryURI: String? = nil, initialRoute: String? = nil, entrypointArgs: [String] = []) -> Bool {
        guard let flutterEngine else {
            return false
        }
        
        let result = flutterEngine.run(withEntrypoint: withEntrypoint, libraryURI: libraryURI, initialRoute: initialRoute, entrypointArgs: entrypointArgs)
        
        FlutterManager.shared().isFlutterEngineRun = result
        
        /// 这两个方法,必须再run之后再进行配置
        listenFlutterToNativeMessage()
        
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        return result
    }
    
    func nativeNotifyToFlutter(type: InvokeMethodType, jsonString: String, flutterReturnMessageCallback: ((Any?) -> Void)? = nil) {
        methodChannel.invokeMethod(type.rawValue, arguments: jsonString) { flutterReturnMessage in
            flutterReturnMessageCallback?(flutterReturnMessage)
            guard let message = flutterReturnMessage as? String else {
                return
            }
            print("flutter callback message:\(message)")
        }
    }
}

extension FlutterManager {
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
                FlutterManager.shared().currentVC()?.dismiss(animated: true)
                result("收到从Flutter要求返回的通信,并且已经执行")
                /// Flutter模块pop时,可以考虑将其engine置为nil,减少内存常驻开销,同时这样就没有办法将Native事件传递到Flutter侧了
                //FlutterManager.shared().setFlutterEngineToNil()
            case .tokenOverdue:
                print("token过期")
            case .logout:
                print("接收到Flutter登出的消息")
                FlutterManager.shared().setFlutterEngineToNil()
                
                AccountManager.shared.clearAccountInfo()
            case .login:
                /// Flutter侧进行登录后,如果回到Native侧,点击会卡住不动,需要将engine移除重新创建才行
                print("接收到Flutter登录的消息")
                FlutterManager.shared().setFlutterEngineToNil()
                
                guard let jsonString = call.arguments as? String else {
                    return
                }
                
                guard let data = jsonString.data(using: .utf8), let accountInfo = try? JSONDecoder().decode(AccountInfo.self, from: data) else {
                    return
                }
                
                guard let username = accountInfo.username, let password = accountInfo.password else {
                    return
                }
                AccountManager.shared.username = username
                AccountManager.shared.password = password
                AccountManager.shared.autoLogin()
            }
        })
    }
}

extension FlutterManager {
    func currentNC() -> UINavigationController? {
        return getCurrentNav()
    }
    
    func currentVC() -> UIViewController? {
        let nav = currentNC()
        guard let nav else {
            return nil
        }
        
        let array = nav.viewControllers
        if array.count == 0 {
            return nil
        }
        
        return array.last
    }
    
    private func getCurrentNav() -> UINavigationController? {
        var rootVc: UIViewController?

        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else {
                return nil
            }
            guard let window = windowScene.windows.last, window.isKind(of: UIWindow.self) else { return nil }

            if #available(iOS 15.0, *) {
                rootVc = windowScene.keyWindow?.rootViewController
            } else {
                rootVc = window.rootViewController
            }
        } else {
            if UIApplication.shared.windows.last?.isKind(of: UIWindow.self) == false {
                return nil
            }
            rootVc = UIApplication.shared.keyWindow?.rootViewController
        }
        guard let rootVc else { return nil }
        
        if rootVc.isKind(of: UITabBarController.self) {
            return getCurrentNCFrom(vc: rootVc)
        } else if rootVc.isKind(of: UINavigationController.self) {
            return rootVc as? UINavigationController
        } else {
            var tabVc: UITabBarController?
            
            for vc in rootVc.children {
                if vc.isKind(of: UITabBarController.self) {
                    tabVc = vc as? UITabBarController
                    break
                }
            }
            if tabVc == nil {
                return nil
            }
            return getCurrentNCFrom(vc: tabVc)
        }
    }
    
    private func getCurrentNCFrom(vc: UIViewController?) -> UINavigationController? {
        guard let vc else { return nil }
        if vc.isKind(of: UITabBarController.self),
           let tab = vc as? UITabBarController,
           let nav = tab.selectedViewController as? UINavigationController {
            return getCurrentNCFrom(vc: nav)
        } else if vc.isKind(of: UINavigationController.self) {
            if let pre = (vc as? UINavigationController)?.presentedViewController {
                return getCurrentNCFrom(vc: pre as? UINavigationController)
            }
            return getCurrentNCFrom(vc: (vc as? UINavigationController)?.topViewController)
        } else if vc.isKind(of: UIViewController.self) {
            if vc.presentedViewController != nil {
                return getCurrentNCFrom(vc: vc.presentedViewController)
            }
            return vc.navigationController
        } else {
            return nil
        }
    }
}
