//
//  loading-hud-spy.swift
//  RxStudy - 请求集成测试
//
//  Created by Codex on 2026/11/18.
//  Copyright © 2026 season. All rights reserved.
//

/// 集成测试只替换 UI 渲染边界；活动管理器与 Provider 使用应用原始源码。
@MainActor
public enum SVProgressHUD {
    // MARK: - 渲染事件

    /// 按实际执行顺序记录主 Actor 的 HUD 操作。
    public static var events: [String] = []
    // MARK: - HUD 渲染边界

    /// 记录加载开始。
    public static func beginLoading() { events.append("开始") }
    /// 记录加载结束。
    public static func stopLoading() { events.append("结束") }
    /// 记录错误提示。
    public static func showText(_ text: String) { events.append(text) }
}
