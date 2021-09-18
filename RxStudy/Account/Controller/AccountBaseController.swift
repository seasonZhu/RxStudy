//
//  AccountBaseController.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import MBProgressHUD
import SVProgressHUD

class AccountBaseController: BaseViewController {
    
    lazy var usernameFiled: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.backgroundColor = .white
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.attributedPlaceholder = NSAttributedString(string: "请输入用户名", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.textColor = .black
        
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
        textField.attributedPlaceholder = NSAttributedString(string: "请输入密码", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.textColor = .black
        
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
        view.backgroundColor = .playAndroidBg
        
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
    func login(username: String, password: String, showLoading: Bool = true) {
        AccountManager.shared.optimizeLogin(username: username, password: password, showLoading: showLoading) {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func registerAndLogin(username: String, password: String, repassword: String) {
        accountProvider.rx.request(AccountService.register(username, password, repassword))
            .map(BaseModel<AccountInfo>.self)
            .subscribe { event in
                switch event {
                case .success(let baseModel):
                    if baseModel.isSuccess {
                        DispatchQueue.main.async {
                            SVProgressHUD.showText("注册成功")
                        }
                        self.login(username: username, password: password)
                    }
                case .error(_):
                    break
                }
            }.disposed(by: rx.disposeBag)
    }
}
