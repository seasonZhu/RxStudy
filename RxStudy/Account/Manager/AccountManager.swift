//
//  AccountManager.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxCocoa

final class AccountManager {
    static let shared = AccountManager()
    
    let isLogin = BehaviorRelay(value: false)
    
    var accountInfo: AccountInfo?
    
    var cookieHeaderValue: String {
        if let username = accountInfo?.username, let password = accountInfo?.password {
          return "loginUserName=\(username);loginUserPassword=\(password)";
        } else {
          return ""
        }
      }
    
    private init() {}
    
    func saveLoginUsernameAndPassword(username: String, password: String) {
        isLogin.accept(true)
        
        accountInfo?.username = username
        accountInfo?.password = password
        
        UserDefaults.standard.setValue(username, forKey: kUsername)
        UserDefaults.standard.setValue(password, forKey: kPassword)
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
}
