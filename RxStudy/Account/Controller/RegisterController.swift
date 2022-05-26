//
//  RegisterController.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class RegisterController: AccountBaseController {
    
    private lazy var repasswordField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: "请再次输入密码", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        textField.textColor = .black
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        
        title = "注册"
        actionButton.setTitle(title, for: .normal)
        
        view.addSubview(repasswordField)
        repasswordField.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(usernameFiled)
        }
        repasswordField.layer.cornerRadius = 22
        repasswordField.layer.masksToBounds = true
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(repasswordField.snp.bottom).offset(16)
            make.leading.trailing.height.equalTo(usernameFiled)
        }
        
        let usernameValid = usernameFiled.rx.text.orEmpty
            .map { [weak self] text -> Bool in
                if text.count >= 11 {
                    debugLog("超出了,进行截取")
                    self?.usernameFiled.text = String(text.prefix(11))
                    return true
                } else {
                    return false
                }
            }
            .share(replay: 1) // without this map would be executed once for each binding, rx is stateless by default

        let passwordValid = passwordField.rx.text.orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)
        
        let repasswordValid = repasswordField.rx.text.orEmpty
            .map { $0.count > 0 }
            .share(replay: 1)
        
        let isSamePassword = Observable.combineLatest(passwordField.rx.text.orEmpty, repasswordField.rx.text.orEmpty) { $0 == $1 }.share(replay: 1)

        let everythingValid = Observable.combineLatest(usernameValid, passwordValid, repasswordValid, isSamePassword) { $0 && $1 && $2 && $3 }
            .share(replay: 1)

        usernameValid
            .bind(to: passwordField.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        usernameValid.map { $0 ? UIColor.white : UIColor.gray.withAlphaComponent(0.5) }
            .bind(to: passwordField.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        usernameValid.map { $0 ? UIColor.white : UIColor.gray.withAlphaComponent(0.5) }
            .bind(to: repasswordField.rx.backgroundColor)
            .disposed(by: rx.disposeBag)

        everythingValid
            .bind(to: actionButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        everythingValid.map { $0 ? UIColor.systemBlue : UIColor.systemBlue.withAlphaComponent(0.5) }
            .bind(to: actionButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)

        actionButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let username = self?.usernameFiled.text,
                      let password = self?.passwordField.text,
                      let repassword = self?.repasswordField.text else {
                    return
                }
                self?.registerAndLogin(username: username, password: password, repassword: repassword)
            })
            .disposed(by: rx.disposeBag)
    }

}
