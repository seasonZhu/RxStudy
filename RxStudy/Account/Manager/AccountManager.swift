//
//  AccountManager.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import Moya
import RxSwift
import RxCocoa
import NSObject_Rx
import MBProgressHUD
import SVProgressHUD

final class AccountManager {
    
    /// 默认是有联网的
    let networkIsReachableRelay = BehaviorRelay(value: true)
    
    /// 是否登录的BehaviorRelay属性
    let isLoginRelay = BehaviorRelay(value: false)
    
    /// 这个是尝试在一个接口调用另一个接口获取的模型
    let myCoinRelay = BehaviorRelay<CoinRank?>(value: nil)
    
    let myUnreadMessageCountRelay = BehaviorRelay<Int>(value: 0)
    
    /// 本地保存用户名
    @UserDefault(key: kUsername, defaultValue: nil)
    var username: String?
    
    /// 本地保存密码
    @UserDefault(key: kPassword, defaultValue: nil)
    var password: String?
    
    var isGrayModeRelay = BehaviorRelay(value: false)
    
    /// 单例
    static let shared = AccountManager()
        
    /// 对外只读用户信息属性
    private(set) var accountInfo: AccountInfo?
    
    /// 私有化初始化方法
    private init() {}
    
}

extension AccountManager {
    /// 已登录请求头处理
    var cookieHeaderValue: String {
        if let username = accountInfo?.username,
           let password = accountInfo?.password {
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
                
        self.username = username
        self.password = password
        
        /// 需要注意赋值顺序,将info赋值给单例后,再改变isLogin的状态才能获取正确的请求头
        isLoginRelay.accept(true)
    }
    
    /// 登出成功,清理登录信息
    func clearAccountInfo() {
        isLoginRelay.accept(false)
        accountInfo = nil
        myCoinRelay.accept(nil)
        myUnreadMessageCountRelay.accept(0)
        /// 不仅要清除内存,也要清除本地UserDefault保存的数据
        $username.remove()
        $password.remove()
        
    }
}

extension AccountManager {
    /// 更新收藏夹
    func updateCollectIds(_ collectIds: [Int]) {
        AccountManager.shared.accountInfo?.collectIds = collectIds
    }
}

extension AccountManager {    
    /// 自动登录
    func autoLogin() {
        guard let username = self.username,
              let password = self.password else {
            return
        }
        optimizeLogin(username: username, password: password, showLoading: false)
    }
    
    /// 调用登录接口
    func login(username: String, password: String, showLoading: Bool = true) {
        provider.rx.request(MultiTarget(AccountService.login(username, password, showLoading)))
            .map(BaseModel<AccountInfo>.self)
            .subscribe { event in
                let message: String
                switch event {
                case .success(let baseModel):
                    if baseModel.isSuccess {
                        AccountManager.shared.saveLoginUsernameAndPassword(info: baseModel.data, username: username, password: password)
                    }
                    message = "登录成功"
                case .failure:
                    message = "登录失败"
                }
                
                guard showLoading else {
                    return
                }
                
                DispatchQueue.main.async {
                    SVProgressHUD.showText(message)
                }
                
            }.disposed(by: disposeBag)
    }
}

/// 尝试调用一个接口后再调用另外一个接口
extension AccountManager {
    
    /// 优化后的登录接口,将登录与获取个人积分的接口进行串行
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - showLoading: 是否使用SV
    ///   - completion: 完成后的回调
    func optimizeLogin(username: String, password: String, showLoading: Bool = true, completion: (() -> Void)? = nil) {
        provider.rx.request(MultiTarget(AccountService.login(username, password, showLoading)))
            .retry(2)
            .map(BaseModel<AccountInfo>.self)
            .asObservable()
            .flatMapLatest { (baseModel) -> Single<(CoinRank, Int)> in
                if baseModel.isSuccess {
                    AccountManager.shared.saveLoginUsernameAndPassword(info: baseModel.data, username: username, password: password)
                }
                return Single.zip(self.getMyCoin(), self.getMyUnreadMessageCount())
            }
            .asSingle()
            .subscribe { event in
                switch event {
                case .success((let myCoin, let count)):
     
                    self.myCoinRelay.accept(myCoin)
                    self.myUnreadMessageCountRelay.accept(count)
                    
                case .failure(_):
                    self.myCoinRelay.accept(nil)
                    self.myUnreadMessageCountRelay.accept(0)
                }
                completion?()
            }.disposed(by: disposeBag)
    }
}

extension AccountManager {
    
    private func getMyCoin() -> Single<CoinRank> {
        provider.rx.request(MultiTarget(MyService.userCoinInfo))
            .map(BaseModel<CoinRank>.self)
            .map{ $0.data }
            .compactMap{ $0 }
            .asObservable()
            .asSingle()
    }
    
    private func getMyUnreadMessageCount()  -> Single<Int> {
        provider.rx.request(MultiTarget(MyService.unreadCount))
            .map(BaseModel<Int>.self)
            .map{ $0.data }
            .compactMap{ $0 }
            .asObservable()
            .asSingle()
    }
}

extension AccountManager: HasDisposeBag {}
