//
//  AppDelegate+NetworkConfig.swift
//  RxStudy
//
//  Created by code optimization on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Alamofire

extension AppDelegate {

    /// 设置网络监听
    func setupNetworkMonitoring() {
        // 使用原生 NWPathMonitor 进行监听 (iOS17.4+)
        setupNativeNetworkMonitor()
    }

    // MARK: - 使用 Alamofire NetworkReachabilityManager

    private func setupLegacyNetworkMonitor() {
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { _ in
            let value = NetworkReachabilityManager.default?.isReachable == true
            AccountManager.shared.networkIsReachableRelay.accept(value)
        })
    }

    // MARK: - 使用原生 NWPathMonitor

    private func setupNativeNetworkMonitor() {
        NetworkMonitor.shared.addListener { status in
            print("isConnected=\(status.isConnected), interface=\(status.interface)")
            let value = status.isConnected
            AccountManager.shared.networkIsReachableRelay.accept(value)
        }

        NetworkMonitor.shared.start()

        NetworkMonitor.shared.statusObservable
            .distinctUntilChanged()
            .subscribe(onNext: { status in
                print("Rx: isConnected=\(status.isConnected), interface=\(status.interface)")
                let value = status.isConnected
                AccountManager.shared.networkIsReachableRelay.accept(value)
            })
            .disposed(by: rx.disposeBag)
    }
}
