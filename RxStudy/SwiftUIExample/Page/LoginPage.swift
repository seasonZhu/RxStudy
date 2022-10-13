//
//  LoginPage.swift
//  RxStudy
//
//  Created by dy on 2022/9/28.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI

struct LoginPage: View {
    
    @StateObject private var viewModel = LoginPageViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("请输入用户名", text: $viewModel.userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if viewModel.showUserNameError {
                HStack {
                    Text("用户名不能为空")
                        .foregroundColor(Color.red)
                    Spacer()
                }
            }
            
            /// 这货没有onEditingChanged这个方法
            SecureField("请输入密码", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if viewModel.showPasswordError {
                HStack {
                    Text("密码不能为空")
                        .foregroundColor(Color.red)
                    Spacer()
                }
            }

            GeometryReader { geometry in
                Button(action: {
                    viewModel.showAlert.toggle()
                }) {
                    Text("登录")
                        .foregroundColor(viewModel.buttonEnable ? Color.white : Color.white.opacity(0.3))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(viewModel.buttonEnable ? Color.blue : Color.gray)
                        .clipShape(Capsule())
                }
                .disabled(!viewModel.buttonEnable)
            }
            .frame(height: 35)
            
            Spacer()
        }
        .padding()
        //.border(Color.green)
        .padding()
        .animation(.easeInOut)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("登录成功"),
                  message: Text("\(viewModel.userName) \n \(viewModel.password)"),
                  dismissButton: nil)
        }
        .onDisappear {
            /// 这里必须要clear,否则就引用循环了,原因未知
            /// 解决了viewModel的循环引用,不用clear了
            //viewModel.clear()
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
