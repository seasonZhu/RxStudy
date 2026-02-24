//
//  ActivityIndicator.swift
//  RxStudy
//
//  Created by Claude on 2025/2/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

/// SwiftUI版本的Activity Indicator组件
/// 替代UIKit的UIActivityIndicatorView
struct SwiftUIActivityIndicator: UIViewRepresentable {

    var isAnimating: Bool = false
    var style: UIActivityIndicatorView.Style = .medium

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.hidesWhenStopped = true
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

// MARK: - 预览
#if DEBUG
struct SwiftUIActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 中等尺寸
            SwiftUIActivityIndicator(style: .medium)
                .frame(width: 30, height: 30)
                .previewDisplayName("Medium")

            // 大尺寸
            SwiftUIActivityIndicator(style: .large)
                .frame(width: 40, height: 40)
                .previewDisplayName("Large")

            // 动画状态
            SwiftUIActivityIndicator(isAnimating: true)
                .frame(width: 30, height: 30)
                .previewDisplayName("Animating")
        }
    }
}
#endif
