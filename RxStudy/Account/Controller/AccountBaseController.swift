//
//  AccountBaseController.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import MBProgressHUD

class AccountBaseController: BaseViewController {
    
    lazy var usernameFiled: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.backgroundColor = .white
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.placeholder = "请输入用户名"
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    lazy var passwordField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.isSecureTextEntry = true
        textField.placeholder = "请输入密码"
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(usernameFiled)
        usernameFiled.snp.makeConstraints { make in
            make.top.equalTo(view).offset(kTopMargin + 16)
            make.leading.equalTo(view).offset(16)
            make.trailing.equalTo(view).offset(-16)
            make.height.equalTo(44)
        }
        usernameFiled.layer.cornerRadius = 22
        usernameFiled.layer.masksToBounds = true
        
        view.addSubview(passwordField)
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameFiled.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(usernameFiled)
        }
        passwordField.layer.cornerRadius = 22
        passwordField.layer.masksToBounds = true
    }
}

extension AccountBaseController {
    func login(username: String, password: String) {
        accountProvider.rx.request(AccountService.login(username, password))
            .map(BaseModel<AccountInfo>.self)
            .subscribe { baseModel in
                if baseModel.isSuccess {
                    AccountManager.shared.saveLoginUsernameAndPassword(info: baseModel.data, username: username, password: password)
                    DispatchQueue.main.async {
                        MBProgressHUD.showText("登录成功")
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } onError: { _ in
                
            }.disposed(by: rx.disposeBag)
    }
    
    func registerAndLogin(username: String, password: String, repassword: String) {
        accountProvider.rx.request(AccountService.register(username, password, repassword))
            .map(BaseModel<AccountInfo>.self)
            .subscribe { baseModel in
                if baseModel.isSuccess {
                    DispatchQueue.main.async {
                        MBProgressHUD.showText("注册成功")
                    }
                    self.login(username: username, password: password)
                }
            } onError: { _ in
                
            }.disposed(by: rx.disposeBag)
    }
}
