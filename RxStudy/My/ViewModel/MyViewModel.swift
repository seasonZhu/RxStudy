//
//  MyViewModel.swift
//  RxStudy
//
//  Created by season on 2021/6/16.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class MyViewModel: BaseViewModel {
    
    let currentDataSource = BehaviorRelay<[My]>(value: [])
    
    let refreshSubject = PublishSubject<MJRefreshAction>()
    
    override init() {
        super.init()

        /// 单例的isLogin通过map后,与VM的currentDataSource进行绑定
        AccountManager.shared.isLoginRelay
            .map { isLogin in
                isLogin ? MyViewModel.loginDataSource : MyViewModel.logoutDataSource
            }
            .bind(to: currentDataSource)
            .disposed(by: disposeBag)
    }
    
    func loadData() {
        Single.zip(getMyCoin(), getMyUnreadMessageCount())
            .subscribe { event in
                self.refreshSubject.onNext(.stopRefresh)
                switch event {
                case .success((let myCoin, let count)):
                    
                    /// 同步到单例
                    AccountManager.shared.myCoinRelay.accept(myCoin)
                    AccountManager.shared.myUnreadMessageCountRelay.accept(count)
                    
                case .failure(_):

                    /// 同步到单例
                    AccountManager.shared.myCoinRelay.accept(nil)
                    AccountManager.shared.myUnreadMessageCountRelay.accept(0)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension MyViewModel {
    
    private func getMyCoin() -> Single<CoinRank> {
        myProvider.rx.request(MyService.userCoinInfo)
            .map(BaseModel<CoinRank>.self)
            .map{ $0.data }
            .compactMap{ $0 }
            .asObservable()
            .asSingle()
    }
    
    private func getMyUnreadMessageCount()  -> Single<Int> {
        myProvider.rx.request(MyService.unreadCount)
            .map(BaseModel<Int>.self)
            .map{ $0.data }
            .compactMap{ $0 }
            .asObservable()
            .asSingle()
    }
    
    func logout() -> Single<BaseModel<String>> {
        accountProvider.rx.request(AccountService.logout)
            .map(BaseModel<String>.self)
    }
}

extension MyViewModel {
    static let logoutDataSource: [My] = [.myGitHub, .myJueJin, .aSwiftUI, .openSource, .tools, .course, .ranking, .login]
    
    static let loginDataSource: [My] = [.myGitHub, .myJueJin, .aSwiftUI, .openSource, .tools, .course, .ranking, .myCoin, .myCollect, .myMessage, .logout]
}

import RxBlocking

extension MyViewModel {
    func testRxBlocking() {
        
        /// 使用自己写的BlockingObservable分类进行处理
        let some = myProvider.rx.request(MyService.userCoinInfo)
            .map(BaseModel<CoinRank>.self)
            .map{ $0.data }
            .compactMap{ $0 }
            .toBlocking()
            .toSingleResult
        switch some {
        case .success(let data):
            print(data)
        case .failure(let error):
            print(error)
        }
        
        /// 使用自己写的MoyaProviderType分类进行处理
        let result: Result<CoinRank, MoyaError> = myProvider.rx.blockingRequest(MyService.userCoinInfo)
            .map(BaseModel<CoinRank>.self)
            .map{ $0.data }
            .filterNil(CoinRank.self)
        
        switch result {
            
        case .success(let data):
            print("哈哈")
            print(data)
        case .failure(let error):
            print(error)
        }
        
        let anotherResult: Result<CoinRank, MoyaError> = myProvider.rx.blockingRequest(MyService.userCoinInfo)
            .map(BaseModel<CoinRank>.self)
            .map{ $0.data }
            .filterNil()
        
        switch anotherResult {
            
        case .success(let data):
            print("哈哈")
            print(data)
        case .failure(let error):
            print(error)
        }
    }
}
