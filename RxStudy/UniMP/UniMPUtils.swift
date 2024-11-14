//
//  UniMPUtils.swift
//  RxStudy
//
//  Created by dy on 2024/11/14.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation

final class UniMPUtils {
    private init() {}
    
    static func checkUniMPResoutceAndOpen(appid: String) {
        checkUniMPResoutce(appid: appid) {
            openUniMP(appid: appid)
        }
    }
    
    @discardableResult
    static func checkUniMPResoutce(appid: String, success: (() -> Void)?) -> Bool {
        let wgtPath = Bundle.main.path(forResource: appid, ofType: "wgt") ?? ""
#warning ("注意：isExistsUniMP: 方法判断的仅是运行路径中是否有对应的应用资源，宿主还需要做好内置wgt版本的管理，如果更新了内置的wgt也应该执行 releaseAppResourceToRunPathWithAppid 方法应用最新的资源")
        if DCUniMPSDKEngine.isExistsUniMP(appid) {
            let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
            let name = version["code"]!
            let code = version["code"]!
            print("小程序：\(appid) 资源已存在，版本信息：name:\(name) code:\(code)")
            success?()
            return true
        } else {
            do {
                try DCUniMPSDKEngine.installUniMPResource(withAppid: appid, resourceFilePath: wgtPath, password: nil)
                let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
                let name = version["code"]!
                let code = version["code"]!
                print("✅ 小程序：\(appid) 资源释放成功，版本信息：name:\(name) code:\(code)")
                success?()
                return true
            } catch let err as NSError {
                print("❌ 小程序：\(appid) 资源释放失败:\(err)")
                return false
            }
        }
    }
    
    static func openUniMP(appid: String) {
        
        let configuration = DCUniMPConfiguration.init()
        configuration.enableBackground = true
        configuration.openMode = .present
        configuration.enableGestureClose = true
        
        DCUniMPSDKEngine.openUniMP(appid, configuration: configuration) { instance, error in
            if instance != nil {
                print("小程序打开成功")
            } else {
                print(error as Any)
                print("小程序打开出错")
            }
        }
    }
}
