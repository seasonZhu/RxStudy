//
//  UniMPManager.swift
//  RxStudy
//
//  Created by dy on 2024/11/14.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation
import os

@MainActor
final class UniMPManager: NSObject {
        
    static let shared = UniMPManager()
    
    private(set) var uniMPInstance: DCUniMPInstance?
    private var openGeneration = UUID()
    
    var closeButtonClickedCallback: ((_ appId: String) -> Void)?
    
    var defaultMenuItemClickedCallback: ((_ appid: String, _ identifier: String) -> Void)?
    
    var customSplashViewCallback: ((_ appId: String) -> UIView)?
    
    var uniMPOnCloseCallback: ((_ appId: String) -> Void)?
    
    typealias EventObserver = @Sendable (String, String, Any, DCUniMPKeepAliveCallback) -> Void

    // 只保护观察者的注册与读取。事件和回复闭包仍在 SDK 回调栈内使用。
    private nonisolated let eventObserver = OSAllocatedUnfairLock<EventObserver?>(initialState: nil)

    var onUniMPEventReceiveCallback: EventObserver? {
        get { eventObserver.withLock { $0 } }
        set { eventObserver.withLock { $0 = newValue } }
    }
    
    private override init() {
        super.init()
        DCUniMPSDKEngine.setDelegate(self)
        
        /// 默认配置了创建按钮
        let item1 = DCUniMPMenuActionSheetItem(title: "Item 1", identifier: "item1")
        let item2 = DCUniMPMenuActionSheetItem(title: "Item 2", identifier: "item2")
        /// 默认添加到全局配置
        DCUniMPSDKEngine.setDefaultMenuItems([item1, item2])
    }
    
    func initDCUniMPSDKEngineEnvironment(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let options = NSMutableDictionary.init(dictionary: launchOptions ?? [:])
        options.setValue(NSNumber.init(value: true), forKey: "debug")
        DCUniMPSDKEngine.initSDKEnvironment(launchOptions: options as! [AnyHashable: Any])
        
        /// 这里是初始化的模块,可以在Uni中进行调用
        WXSDKEngine.registerModule("TestModule", with: NSClassFromString("TestModule"))
        WXSDKEngine.registerComponent("testmap", with: NSClassFromString("TestMapComponent"))
    }
    
    func openUniApp(appid: String, callback: (@MainActor @Sendable (Result<DCUniMPInstance, Error>) -> Void)? = nil) {
        let wgtPath = Bundle.main.path(forResource: appid, ofType: "wgt") ?? ""
        do {
            try DCUniMPSDKEngine.installUniMPResource(withAppid: appid, resourceFilePath: wgtPath, password: nil)
            let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
            let name = version["code"]!
            let code = version["code"]!
            print("✅ 小程序：\(appid) 资源释放成功，版本信息：name:\(name) code:\(code)")
            
            DispatchQueue.main.async {
                let config = DCUniMPConfiguration()
                config.openMode = .present
                let completion: @Sendable (DCUniMPInstance?, Error?) -> Void = { instance, error in
                    if let instance {
                        // SDK 实例缺少跨线程所有权契约，只在运行时确认主 Actor 后使用。
                        nonisolated(unsafe) let instance = instance
                        MainActor.assumeIsolated {
                            print("小程序打开成功")
                            self.openGeneration = UUID()
                            self.uniMPInstance = instance
                            callback?(.success(instance))
                        }
                    } else if let error {
                        Self.deliverOnMain {
                            print("小程序打开失败")
                            callback?(.failure(error))
                        }
                    }
                }
                DCUniMPSDKEngine.openUniMP(appid, configuration: config, completed: completion)
            }

        } catch let error as NSError {
            callback?(.failure(error))
            print("❌ 小程序：\(appid) 资源释放失败:\(error)")
        }
    }
}

// MARK: - DCUniMPSDKEngineDelegate
extension UniMPManager: DCUniMPSDKEngineDelegate {
    /// 这个两个实现了就,就把小程序菜单与关闭按钮的实现要自己写了
//    func hookCapsuleMenuButtonClicked(_ appid: String) {
//
//    }
//
//    func hookCapsuleCloseButtonClicked(_ appid: String) {
//
//    }
    
    // 主线程回调保持同步，后台回调只投递宿主可安全持有的值。
    private nonisolated static func deliverOnMain(_ action: @escaping @MainActor @Sendable () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated { action() }
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    nonisolated func closeButtonClicked(_ appid: String) {
        Self.deliverOnMain {
            print("closeButtonClicked appid:\(appid)")
            if let instance = self.uniMPInstance {
                let closingGeneration = self.openGeneration
                instance.close { [weak self] _, _ in
                    Self.deliverOnMain { [weak self] in
                        guard let self, self.openGeneration == closingGeneration else { return }
                        self.uniMPInstance = nil
                    }
                }
            }
            self.closeButtonClickedCallback?(appid)
        }
    }

    nonisolated func defaultMenuItemClicked(_ appid: String, identifier: String) {
        Self.deliverOnMain {
            print("defaultMenuItemClicked：\(appid) \(identifier)")
            self.uniMPInstance?.sendUniMPEvent("NativeEvent", data: ["msg": "native message"])
            self.defaultMenuItemClickedCallback?(appid, identifier)
        }
    }

    nonisolated func splashView(forApp appid: String) -> UIView {
        MainActor.assumeIsolated {
            if let customSplashViewCallback {
                return customSplashViewCallback(appid)
            }
            return LoadingView()
        }
    }

    nonisolated func uniMP(onClose appid: String) {
        Self.deliverOnMain {
            print("小程序：\(appid) closed")
            self.uniMPOnCloseCallback?(appid)
        }
    }

    nonisolated func onUniMPEventReceive(_ appid: String, event: String, data: Any, callback: @escaping DCUniMPKeepAliveCallback) {
        print("Receive UniMP appid:\(appid) event: \(event) data: \(data)")
        
        // 回传数据给小程序
        // DCUniMPKeepAliveCallback 用法请查看定义说明
        callback("native callback message", false)
        
        let observer = eventObserver.withLock { $0 }
        observer?(appid, event, data, callback)
    }
}
