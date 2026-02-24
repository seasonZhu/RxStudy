//
//  EmptyStateView.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

/// SwiftUI版本的空状态视图组件
/// 替代DZNEmptyDataSet
struct EmptyStateView: View {

    var imageName: String?
    var title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if let imageName = imageName {
                Image(systemName: imageName)
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            }

            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)

            if let message = message {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 预定义样式
extension EmptyStateView {
    /// 无数据状态
    static func noData(message: String? = nil) -> EmptyStateView {
        EmptyStateView(
            imageName: "tray",
            title: "暂无数据",
            message: message ?? "暂时没有内容"
        )
    }

    /// 网络错误状态
    static func networkError(message: String? = nil) -> EmptyStateView {
        EmptyStateView(
            imageName: "wifi.slash",
            title: "网络连接失败",
            message: message ?? "请检查网络连接后重试",
            actionTitle: "重试"
        )
    }

    /// 加载失败状态
    static func loadError(message: String? = nil) -> EmptyStateView {
        EmptyStateView(
            imageName: "exclamationmark.triangle",
            title: "加载失败",
            message: message ?? "数据加载失败，请稍后重试"
        )
    }

    /// 空搜索结果
    static func emptySearch(keyword: String? = nil) -> EmptyStateView {
        EmptyStateView(
            imageName: "magnifyingglass",
            title: "无搜索结果",
            message: keyword.map { "未找到\"\($0)\"相关的内容" } ?? "没有找到相关内容"
        )
    }
}

// MARK: - 预览
#if DEBUG
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 无数据
            EmptyStateView.noData()
                .padding()
                .previewDisplayName("无数据")

            // 网络错误
            EmptyStateView.networkError()
                .padding()
                .previewDisplayName("网络错误")

            // 加载失败
            EmptyStateView.loadError()
                .padding()
                .previewDisplayName("加载失败")

            // 空搜索
            EmptyStateView.emptySearch(keyword: "Swift")
                .padding()
                .previewDisplayName("空搜索")
        }
    }
}
#endif
