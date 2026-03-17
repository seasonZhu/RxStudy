//
//  EmptyStateView.swift
//  RxStudy - SwiftUIApp
//
//  空状态视图组件
//

import SwiftUI

struct EmptyStateView: View {
    var icon: String = "tray"
    var message: String = "暂无内容"
    var showRetry: Bool = false
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(message)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)

            if showRetry, let onRetry = onRetry {
                Button("重新加载") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 预览

#Preview {
    EmptyStateView(
        icon: "bookmark",
        message: "暂无收藏",
        showRetry: true
    ) {
        print("retry")
    }
}
