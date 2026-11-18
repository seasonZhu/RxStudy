//
//  NetworkActivityManager.swift
//  RxStudy
//
//  Created by dy on 2025/9/29.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation
import os
import Moya
import SVProgressHUD

/// 锁只保护请求令牌；主队列按锁内提交顺序更新 HUD，不跨域传递请求或响应。
enum NetworkActivityManager {
    // MARK: - 活动令牌与待展示提示

    private struct State {
        var tokens: Set<UUID> = []
        var message: String?
    }
    private static let state = OSAllocatedUnfairLock(initialState: State())

    // MARK: - 请求生命周期

    /// 首次活动开始时提交加载显示。
    static func begin() -> UUID {
        let token = UUID()
        state.withLock { active in
            let wasEmpty = active.tokens.isEmpty
            active.tokens.insert(token)
            if wasEmpty {
                DispatchQueue.main.async { SVProgressHUD.beginLoading() }
            }
        }
        return token
    }

    /// 幂等结束；并行错误保留到最后一个活动结束，避免被随后关闭操作覆盖。
    static func end(_ token: UUID?, message: String? = nil) {
        state.withLock { active in
            if let token {
                guard active.tokens.remove(token) != nil else { return }
            }
            if let message { active.message = message }
            guard active.tokens.isEmpty else { return }
            let text = active.message
            active.message = nil
            let shouldStop = token != nil
            guard shouldStop || text != nil else { return }
            DispatchQueue.main.async {
                if shouldStop { SVProgressHUD.stopLoading() }
                if let text { SVProgressHUD.showText(text) }
            }
        }
    }
}

/// 请求入口创建独立令牌，避免插件在发送前取消时误减其他请求的活动数。
final class LoadingProvider<Target: TargetType>: MoyaProvider<Target> {
    // MARK: - 请求入口

    /// 为每次请求创建独立活动令牌，原样保留结果与底层取消。
    override func request(_ target: Target, callbackQueue: DispatchQueue? = nil,
                          progress: ProgressBlock? = nil,
                          completion: @escaping Completion) -> Cancellable {
        let tracksLoading = ![Api.Home.banner, Api.Home.topArticle, Api.My.unreadCount].contains(target.path)
            && target.headers?["showLoading"] != "false"
        let token = tracksLoading ? NetworkActivityManager.begin() : nil
        let request = super.request(target, callbackQueue: callbackQueue, progress: progress) { result in
            let message: String?
            if case .failure(.statusCode(let response)) = result,
               let text = (try? response.mapJSON() as? [String: Any])?["errorMsg"] as? String, !text.isEmpty {
                message = text
            } else {
                message = nil
            }
            NetworkActivityManager.end(token, message: message)
            completion(result)
        }
        return CancellableToken {
            NetworkActivityManager.end(token)
            request.cancel()
        }
    }
}
