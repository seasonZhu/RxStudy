//
//  LoginPage.swift
//  RxStudy
//
//  Created by dy on 2022/9/28.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI

struct LoginPage: View {
    @StateObject private var dataModel = LoginPageViewModel()
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            TextField("请输入用户名", text: $dataModel.userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if dataModel.showUserNameError {
                Text("用户名不能少于3位！！！")
                    .foregroundColor(Color.red)
            }

            SecureField("请输入密码", text: $dataModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if dataModel.showPasswordError {
                Text("密码不能少于6位！！！")
                    .foregroundColor(Color.red)
            }

            GeometryReader { geometry in
                Button(action: {
                    self.showAlert.toggle()
                }) {
                    Text("登录")
                        .foregroundColor(dataModel.buttonEnable ? Color.white : Color.white.opacity(0.3))
                        .frame(width: geometry.size.width, height: 35)
                        .background(dataModel.buttonEnable ? Color.blue : Color.gray)
                        .clipShape(Capsule())
                }
                .disabled(!dataModel.buttonEnable)

            }
            .frame(height: 35)
        }
        .padding()
        .border(Color.green)
        .padding()
        .animation(.easeInOut)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("登录成功"),
                  message: Text("\(dataModel.userName) \n \(dataModel.password)"),
                  dismissButton: nil)
        }
        .onDisappear {
            dataModel.clear()
        }
    }
}
