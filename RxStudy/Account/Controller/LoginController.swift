//
//  LoginController.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class LoginController: BaseViewController {
    
    /// 这个没有用呀
    private lazy var stackView: UIStackView = {
        let sView = UIStackView(arrangedSubviews: [usernameFiled, passwordField, loginButton])
        sView.axis = .vertical
        sView.distribution = .equalSpacing
        sView.alignment = .fill
        sView.spacing = 16
        return sView
    }()
    
    private lazy var usernameFiled: UITextField = {
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
    
    private lazy var passwordField: UITextField = {
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
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("登录", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var toRegisterButton: UIButton = {
        let button = UIButton(type: .custom)
        let attString = NSAttributedString(string: "还没有注册?", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor: UIColor.systemBlue, .font: UIFont.systemFont(ofSize: 15)])
        button.setAttributedTitle(attString, for: .normal)
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
        
        view.addSubview(toRegisterButton)
        toRegisterButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(16)
            make.trailing.equalTo(usernameFiled)
        }
        
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(toRegisterButton.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(usernameFiled)
        }
        
        let usernameValid = usernameFiled.rx.text.orEmpty
            .map { [weak self] text -> Bool in
                if text.count >= 11 {
                    print("超出了,进行截取")
                    self?.usernameFiled.text = String(text.prefix(11))
                    return true
                }else {
                    return false
                }
            }
            .share(replay: 1) // without this map would be executed once for each binding, rx is stateless by default

        let passwordValid = passwordField.rx.text.orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)

        let everythingValid = Observable.combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .share(replay: 1)

        usernameValid
            .bind(to: passwordField.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        usernameValid.map { $0 ? UIColor.white : UIColor.gray.withAlphaComponent(0.5) }
            .bind(to: passwordField.rx.backgroundColor)
            .disposed(by: rx.disposeBag)

        everythingValid
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        everythingValid.map { $0 ? UIColor.systemBlue : UIColor.systemBlue.withAlphaComponent(0.5) }
            .bind(to: loginButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
//        usernameFiled.rx.text.orEmpty.changed
//            .subscribe(onNext: { [weak self] text in
//                if text.count > 11 {
//                    print("超出了,进行截取")
//                    self?.usernameFiled.text = String(text.prefix(11))
//                }
//            })
//            .disposed(by: rx.disposeBag)

        loginButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("按钮的点击事件")
            })
            .disposed(by: rx.disposeBag)
    }
}
