//
//  AppDelegate+SecurityConfig.swift
//  RxStudy
//
//  Created by dy on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation

extension AppDelegate {

    /// 设置安全配置（API密钥管理）
    func setupSecurityConfiguration() {
        loadAPIKeysFromInfoPlist()
        loadAPIKeysFromOnDemandResources()
        loadObfuscatedKeys()
    }

    // MARK: - 方案一：使用 Info.plist

    private func loadAPIKeysFromInfoPlist() {
        if let amapApiKey = Bundle.main.object(forInfoDictionaryKey: "AMAP_API_KEY") as? String {
            print("amapApiKey:\(amapApiKey)")
        }

        if let umApiKey = Bundle.main.object(forInfoDictionaryKey: "UM_API_KEY") as? String {
            print("umApiKey:\(umApiKey)")
        }
    }

    // MARK: - 方案二：按需资源

    private func loadAPIKeysFromOnDemandResources() {
        KeyConstants.loadAPIKeys { result in
            switch result {
            case .success:
                print("myServiceXKey:\(KeyConstants.APIKeys.myServiceXKey)")
                print("myServiceYKey:\(KeyConstants.APIKeys.myServiceYKey)")
            case .failure:
                break
            }
        }
    }

    // MARK: - 方案五：混淆技术

    private func loadObfuscatedKeys() {
    }
}
