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

class LoginController: AccountBaseController {
    
    private lazy var toRegisterButton: UIButton = {
        let button = UIButton(type: .custom)
        let attString = NSAttributedString(string: "还没有注册?", attributes: [
                                            .underlineStyle: NSUnderlineStyle.single.rawValue,
                                            .foregroundColor: UIColor.systemBlue,
                                            .font: UIFont.systemFont(ofSize: 15)])
        button.setAttributedTitle(attString, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        inputTextFieldRxSubscribe()
    }
    
    private func setupUI() {
        
        title = "登录"
        actionButton.setTitle(title, for: .normal)
        
        view.addSubview(toRegisterButton)
        toRegisterButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(16)
            make.trailing.equalTo(usernameFiled)
        }
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(toRegisterButton.snp.bottom).offset(16)
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
            .map { $0.isNotEmpty}
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
            .bind(to: actionButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        everythingValid.map { $0 ? UIColor.systemBlue : UIColor.systemBlue.withAlphaComponent(0.5) }
            .bind(to: actionButton.rx.backgroundColor)
            .disposed(by: rx.disposeBag)
        
        toRegisterButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.pushViewController(RegisterController(), animated: true)
            })
            .disposed(by: rx.disposeBag)

        actionButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let username = self?.usernameFiled.text,
                      let password = self?.passwordField.text else {
                    return
                }
                self?.login(username: username, password: password)
            })
            .disposed(by: rx.disposeBag)
    }
}

extension LoginController {
    func inputTextFieldRxSubscribe() {
        /// RxSwift学习插曲--UITextField的两次输出,这里使用skip(2)的缘由
        /// https://juejin.cn/post/6844903905386577928
        usernameFiled.rx.text
            .skip(2)
            .subscribe(onNext: { (text) in
                print("你输入的是： \(text)")
            })
            .disposed(by: rx.disposeBag)
    }
}
