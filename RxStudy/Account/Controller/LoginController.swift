//
//  LoginController.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

class LoginController: BaseViewController {
    
    private lazy var stackView: UIStackView = {
        let sView = UIStackView(arrangedSubviews: [usernameFiled, passwordField, loginButton])
        sView.axis = .vertical
        sView.distribution = .equalSpacing
        sView.alignment = .fill
        sView.spacing = 16
        return sView
    }()
    
    private lazy var usernameFiled: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 32, height: 44))
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = textField.bounds.height / 2.0
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.placeholder = "请输入用户名"
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 16, width: 10, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var passwordField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 32, height: 44))
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = textField.bounds.height / 2.0
        textField.layer.masksToBounds = true
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
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 32, height: 44)
        button.setTitle("登录", for: [.normal, .selected, .highlighted])
        button.setTitleColor(.white, for: [.normal, .selected, .highlighted])
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = button.bounds.height / 2.0
        button.layer.masksToBounds = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        /// 不知道是我不会用StackView,还是这货真的不够智能
        /*
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        */
    }
}
