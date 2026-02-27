//
//  LoginView.swift
//  RxStudy - SwiftUIApp
//
//  登录页面视图
//  使用 @Bindable 实现表单编辑
//

import SwiftUI

// MARK: - 登录表单模型

@Observable
class LoginFormData {
    var username: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isRegisterMode: Bool = false

    var isValid: Bool {
        if isRegisterMode {
            return !username.isEmpty && !password.isEmpty && password == confirmPassword
        } else {
            return !username.isEmpty && !password.isEmpty
        }
    }
}

// MARK: - 登录视图

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var formData = LoginFormData()
    @State private var accountService = AccountAPIService.shared

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                // 模式切换
                Picker("模式", selection: $formData.isRegisterMode) {
                    Text("登录").tag(false)
                    Text("注册").tag(true)
                }
                .pickerStyle(.segmented)

                // 使用 @Bindable 实现双向绑定
                formContent
            }
            .navigationTitle(formData.isRegisterMode ? "注册" : "登录")
            .navigationBarTitleDisplayMode(.inline)
            .hideTabBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(formData.isRegisterMode ? "注册" : "登录") {
                        Task {
                            await submit()
                        }
                    }
                    .disabled(!formData.isValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
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
        @Bindable var form = formData

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
            if formData.isRegisterMode {
                SecureInputField(
                    title: "确认密码",
                    text: $form.confirmPassword
                )
            }
        } header: {
            Text("账号信息")
        } footer: {
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }

        // 说明文字
        Section {
            if formData.isRegisterMode {
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
        isLoading = true
        errorMessage = nil

        do {
            if formData.isRegisterMode {
                // 注册
                _ = try await accountService.register(
                    username: formData.username,
                    password: formData.password,
                    repassword: formData.confirmPassword
                )
            } else {
                // 登录
                _ = try await accountService.login(
                    username: formData.username,
                    password: formData.password
                )
            }

            // 成功后关闭
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - 预览

#Preview {
    LoginView()
}
