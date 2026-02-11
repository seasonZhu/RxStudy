//
//  AppDelegate+RouterConfig.swift
//  RxStudy
//
//  Created by dy on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import TheRouter

extension AppDelegate {

    /// 设置路由配置
    func setupRouterConfiguration() {
        // 日志回调
        TheRouter.logcat { url, logType, errorMsg in
            debugLog("TheRouter: logMsg- \(url) \(logType.rawValue) \(errorMsg)")
        }

        // 路由懒加载注册
        TheRouterManager.loadRouterClass(excludeCocoapods: true, useCache: true)

        TheRouter.lazyRegisterRouterHandle { url, userInfo in
            self.injectRouterServiceConfig(self.webRouterUrl, self.serivceHost)
            return TheRouterManager.addGloableRouter(true, url, userInfo, forceCheckEnable: true)
        }

        // 动态注册服务
        TheRouterManager.registerServices(excludeCocoapods: true)
    }

    private func injectRouterServiceConfig(_ webRouterUrl: String, _ serivceHost: String) {
        TheRouterManager.injectRouterServiceConfig(webRouterUrl, serivceHost)
    }
}
