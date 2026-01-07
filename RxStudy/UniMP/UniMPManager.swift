//
//  UniMPManager.swift
//  RxStudy
//
//  Created by dy on 2024/11/14.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation

@MainActor
final class UniMPManager: NSObject {
        
    static let shared = UniMPManager()
    
    private(set) var uniMPInstance: DCUniMPInstance?
    
    var closeButtonClickedCallback: ((_ appId: String) -> Void)?
    
    var defaultMenuItemClickedCallback: ((_ appid: String, _ identifier: String) -> Void)?
    
    var customSplashViewCallback: ((_ appId: String) -> UIView)?
    
    var uniMPOnCloseCallback: ((_ appId: String) -> Void)?
    
    var onUniMPEventReceiveCallback: ((_ appid: String, _ event: String, _ data: Any, _ callback: @escaping DCUniMPKeepAliveCallback) -> Void)?
    
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
    
    func openUniApp(appid: String, callback: ((Result<DCUniMPInstance, Error>) -> Void)? = nil) {
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
                DCUniMPSDKEngine.openUniMP(appid, configuration: config) { instance, error in
                    if let instance {
                        print("小程序打开成功")
                        self.uniMPInstance = instance
                        callback?(.success(instance))
                    } else if let error {
                        print("小程序打开失败")
                        callback?(.failure(error))
                    }
                }
            }

        } catch let error as NSError {
            callback?(.failure(error))
            print("❌ 小程序：\(appid) 资源释放失败:\(error)")
        }
    }
}

// MARK: - DCUniMPSDKEngineDelegate
extension UniMPManager: @preconcurrency DCUniMPSDKEngineDelegate {
    /// 这个两个实现了就,就把小程序菜单与关闭按钮的实现要自己写了
//    func hookCapsuleMenuButtonClicked(_ appid: String) {
//
//    }
//
//    func hookCapsuleCloseButtonClicked(_ appid: String) {
//
//    }
    
    func closeButtonClicked(_ appid: String) {
        print("closeButtonClicked appid:\(appid)")
        uniMPInstance?.close(completion: { [weak self] _, _ in
            self?.uniMPInstance = nil
        })
        closeButtonClickedCallback?(appid)
    }
    
    func defaultMenuItemClicked(_ appid: String, identifier: String) {
        print("defaultMenuItemClicked：\(appid) \(identifier)")
        uniMPInstance?.sendUniMPEvent("NativeEvent", data: ["msg": "native message"])
        defaultMenuItemClickedCallback?(appid, identifier)
    }
    
    func splashView(forApp appid: String) -> UIView {
        /// 这里是加载小程序的loading动画,通过appid可以做差异化处理
        if let customSplashViewCallback {
            return customSplashViewCallback(appid)
        } else {
            return LoadingView()
        }
    }
    
    func uniMP(onClose appid: String) {
        print("小程序：\(appid) closed")
        uniMPOnCloseCallback?(appid)
    }
    
    func onUniMPEventReceive(_ appid: String, event: String, data: Any, callback: @escaping DCUniMPKeepAliveCallback) {
        print("Receive UniMP appid:\(appid) event: \(event) data: \(data)")
        
        // 回传数据给小程序
        // DCUniMPKeepAliveCallback 用法请查看定义说明
        callback("native callback message", false)
        
        onUniMPEventReceiveCallback?(appid, event, data, callback)
    }
}
