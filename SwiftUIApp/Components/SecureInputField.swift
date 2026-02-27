//
//  SecureInputField.swift
//  RxStudy - SwiftUIApp
//
//  带明文/密文切换的密码输入框
//

import SwiftUI

// MARK: - 密码输入框组件

/// 带可见性切换的密码输入框
struct SecureInputField: View {
    /// 标题
    let title: String

    /// 文本绑定
    @Binding var text: String

    /// 是否显示明文
    @State private var isVisible: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isVisible {
                    TextField(title, text: $text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .id(isVisible)  // 切换时改变 ID 以重置焦点
                } else {
                    SecureField(title, text: $text)
                        .id(isVisible)  // 切换时改变 ID 以重置焦点
                }
            }

            // 可见性切换按钮
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isVisible.toggle()
                }
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - 预览

#Preview("密码输入框") {
    Form {
        SecureInputField(
            title: "密码",
            text: .constant("")
        )

        SecureInputField(
            title: "确认密码",
            text: .constant("123456")
        )

        Text("点击右侧眼睛图标可切换明文/密文显示")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
    }
}
