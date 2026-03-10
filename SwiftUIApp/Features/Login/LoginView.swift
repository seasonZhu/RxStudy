//
//  LoginView.swift
//  RxStudy - SwiftUIApp
//
//  登录页面视图
//  使用 @Bindable 实现表单编辑
//

import SwiftUI

// MARK: - 登录视图

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = LoginViewModel()

    var body: some View {
        NavigationView {
            Form {
                // 模式切换
                Picker("模式", selection: $viewModel.formData.isRegisterMode) {
                    Text("登录").tag(false)
                    Text("注册").tag(true)
                }
                .pickerStyle(.segmented)

                // 使用 @Bindable 实现双向绑定
                formContent
            }
            .navigationTitle(viewModel.formData.isRegisterMode ? "注册" : "登录")
            .navigationBarTitleDisplayMode(.inline)
            .hideTabBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.formData.isRegisterMode ? "注册" : "登录") {
                        Task {
                            await submit()
                        }
                    }
                    .disabled(!viewModel.formData.isValid || viewModel.state == .loading)
                }
            }
            .overlay {
                if viewModel.state == .loading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - 表单内容

    @ViewBuilder
    private var formContent: some View {
        // 使用 @Bindable 获取绑定能力
        @Bindable var form = viewModel.formData

        Section {
            // 用户名
            TextField("用户名", text: $form.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            // 密码（支持明文/密文切换）
            SecureInputField(
                title: "密码",
                text: $form.password
            )

            // 确认密码（仅注册模式）
            if viewModel.formData.isRegisterMode {
                SecureInputField(
                    title: "确认密码",
                    text: $form.confirmPassword
                )
            }
        } header: {
            Text("账号信息")
        } footer: {
            if case .error(let message) = viewModel.state {
                Text(message)
                    .foregroundColor(.red)
            }
        }

        // 说明文字
        Section {
            if viewModel.formData.isRegisterMode {
                Text("注册后可使用玩安卓的所有功能")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            } else {
                Text("首次使用？请先注册账号")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - 提交

    private func submit() async {
        let success = await viewModel.submit()
        if success {
            dismiss()
        }
    }
}

// MARK: - 预览

#Preview {
    LoginView()
}
