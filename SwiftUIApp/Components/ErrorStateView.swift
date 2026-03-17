//
//  ErrorStateView.swift
//  RxStudy - SwiftUIApp
//
//  错误状态视图组件
//

import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)

            Button("重新加载") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 预览

#Preview {
    ErrorStateView(message: "网络错误，请检查网络连接") {
        print("retry")
    }
}
