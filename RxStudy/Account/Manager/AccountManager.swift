//
//  AccountManager.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx
import MBProgressHUD

final class AccountManager {
    static let shared = AccountManager()
    
    private(set) var isLogin = BehaviorRelay(value: false)
        
    private(set) var accountInfo: AccountInfo?
    
    var cookieHeaderValue: String {
        if let username = accountInfo?.username, let password = accountInfo?.password {
          return "loginUserName=\(username);loginUserPassword=\(password)";
        } else {
          return ""
        }
      }
    
    private init() {}
    
    func saveLoginUsernameAndPassword(info: AccountInfo?, username: String, password: String) {
        accountInfo = info
        accountInfo?.username = username
        accountInfo?.password = password
        
        UserDefaults.standard.setValue(username, forKey: kUsername)
        UserDefaults.standard.setValue(password, forKey: kPassword)
        /// 需要注意赋值顺序,将info赋值给单例后,再改变isLogin的状态才能获取正确的请求头
        isLogin.accept(true)
    }
    
    func clearAccountInfo() {
        isLogin.accept(false)
        accountInfo = nil
    }
    
    func getUsername() -> String? {
        return UserDefaults.standard.value(forKey: kUsername) as? String
    }
    
    func getPassword() -> String? {
        return UserDefaults.standard.value(forKey: kPassword) as? String
    }
    
    func updateCollectIds(_ collectIds: [Int]) {
        AccountManager.shared.accountInfo?.collectIds = collectIds
    }
    
    func autoLogin() {
        if !isLogin.value {
            guard let username = getUsername(), let password = getPassword() else {
                return
            }
            login(username: username, password: password)
        }
    }
    
    func login(username: String, password: String) {
        accountProvider.rx.request(AccountService.login(username, password))
            .map(BaseModel<AccountInfo>.self)
            /// 转为Observable
            .subscribe { baseModel in
                if baseModel.isSuccess {
                    AccountManager.shared.saveLoginUsernameAndPassword(info: baseModel.data, username: username, password: password)
                    DispatchQueue.main.async {
                        MBProgressHUD.showText("登录成功")
                    }
                }
            } onError: { _ in
                
            }.disposed(by: disposeBag)
    }
}

extension AccountManager: HasDisposeBag {}
