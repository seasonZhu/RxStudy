//
//  HUDView.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

/// SwiftUI版本的HUD加载提示组件
/// 替代MBProgressHUD和SVProgressHUD
struct HUDView: View {

    var isPresented: Bool = false
    var message: String?
    var delay: TimeInterval = 0

    var body: some View {
        if isPresented {
            ZStack {
                // 半透明背景
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                // 内容
                VStack(spacing: 16) {
                    if let message = message {
                        Text(message)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    }

                    SwiftUIActivityIndicator(isAnimating: true, style: .large)
                        .frame(width: 40, height: 40)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                )
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - 便捷视图扩展
extension HUDView {
    /// 创建纯加载HUD
    static func loading(isPresented: Bool = true) -> HUDView {
        HUDView(isPresented: isPresented)
    }

    /// 创建带文字的HUD
    static func loading(_ message: String, isPresented: Bool = true) -> HUDView {
        HUDView(isPresented: isPresented, message: message)
    }
}

// MARK: - 预览
#if DEBUG
struct HUDView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3)

            VStack(spacing: 20) {
                // 纯加载
                HUDView.loading()
                    .padding()
                    .previewDisplayName("纯加载")

                // 带文字
                HUDView.loading("正在加载...", isPresented: true)
                    .padding()
                    .previewDisplayName("带文字")

                // 无状态
                HUDView.loading(isPresented: false)
                    .padding()
                    .previewDisplayName("隐藏")
            }
        }
    }
}
#endif
