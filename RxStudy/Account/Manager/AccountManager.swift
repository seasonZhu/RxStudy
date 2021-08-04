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
import SVProgressHUD

final class AccountManager {
    
    /// 单例
    static let shared = AccountManager()
    
    /// 对外只读是否登录属性
    private(set) var isLogin = BehaviorRelay(value: false)
        
    /// 对外只读用户信息属性
    private(set) var accountInfo: AccountInfo?
    
    /// 私有化初始化方法
    private init() {}
    
    let myCoin = BehaviorRelay<CoinRank?>(value: nil)
    
}

extension AccountManager {
    /// 已登录请求头处理
    var cookieHeaderValue: String {
        if let username = accountInfo?.username, let password = accountInfo?.password {
          return "loginUserName=\(username);loginUserPassword=\(password)";
        } else {
          return ""
        }
    }
}

extension AccountManager {
    /// 登录成功,保存登录信息
    func saveLoginUsernameAndPassword(info: AccountInfo?, username: String, password: String) {
        accountInfo = info
        accountInfo?.username = username
        accountInfo?.password = password
        
        UserDefaults.standard.setValue(username, forKey: kUsername)
        UserDefaults.standard.setValue(password, forKey: kPassword)
        /// 需要注意赋值顺序,将info赋值给单例后,再改变isLogin的状态才能获取正确的请求头
        isLogin.accept(true)
    }
    
    /// 登出成功,清理登录信息
    func clearAccountInfo() {
        isLogin.accept(false)
        accountInfo = nil
    }
}

extension AccountManager {
    /// 更新收藏夹
    func updateCollectIds(_ collectIds: [Int]) {
        AccountManager.shared.accountInfo?.collectIds = collectIds
    }
}

extension AccountManager {
    /// 获取本地保存用户名
    func getUsername() -> String? {
        return UserDefaults.standard.value(forKey: kUsername) as? String
    }
    
    /// 获取本地保存密码
    func getPassword() -> String? {
        return UserDefaults.standard.value(forKey: kPassword) as? String
    }
    
    /// 自动登录
    func autoLogin() {
        if !isLogin.value {
            guard let username = getUsername(), let password = getPassword() else {
                return
            }
            login(username: username, password: password)
        }
    }
    
    /// 调用登录接口
    func login(username: String, password: String) {
        accountProvider.rx.request(AccountService.login(username, password))
            .map(BaseModel<AccountInfo>.self)
            /// 转为Observable
            .subscribe { baseModel in
                if baseModel.isSuccess {
                    AccountManager.shared.saveLoginUsernameAndPassword(info: baseModel.data, username: username, password: password)
                    DispatchQueue.main.async {
                        SVProgressHUD.showText("登录成功")
                    }
                }
            } onError: { _ in
                
            }.disposed(by: disposeBag)
    }
}

/// 尝试调用一个接口后再调用另外一个接口
extension AccountManager {
    func login1(username: String, password: String) {
        accountProvider.rx.request(AccountService.login(username, password))
            .retry(2)
            .map(BaseModel<AccountInfo>.self)
            .asObservable()
            .flatMapLatest { (baseModel) -> Observable<CoinRank> in
                if baseModel.isSuccess {
                    AccountManager.shared.saveLoginUsernameAndPassword(info: baseModel.data, username: username, password: password)
                }
                return myProvider.rx.request(MyService.userCoinInfo).map(BaseModel<CoinRank>.self).map{ $0.data}.compactMap{ $0}.asObservable()
            }.asSingle().subscribe { myCoin in
                self.myCoin.accept(myCoin)
            } onError: { _ in
                self.myCoin.accept(nil)
            }.disposed(by: disposeBag)


    }
}

extension AccountManager: HasDisposeBag {}
