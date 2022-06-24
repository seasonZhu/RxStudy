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
    
    let myCoin = BehaviorRelay<CoinRank?>(value: nil)
    
    let refreshSubject = PublishSubject<MJRefreshAction>()
    
    override init() {
        super.init()
        /// 单例的myCoin与VM的myCoin进行绑定
        AccountManager.shared.myCoin.bind(to: myCoin).disposed(by: disposeBag)
        
        /// 单例的isLogin通过map后,与VM的currentDataSource进行绑定
        AccountManager.shared.isLoginRelay
            .map { isLogin in
                isLogin ? MyViewModel.loginDataSource : MyViewModel.logoutDataSource
            }
            .bind(to: currentDataSource)
            .disposed(by: disposeBag)
    }
}

extension MyViewModel {
    func getMyCoin() {
        myProvider.rx.request(MyService.userCoinInfo)
            .map(BaseModel<CoinRank>.self)
            .map{ $0.data }
            .compactMap{ $0 }
            .asObservable()
            .asSingle()
            .subscribe { event in
                self.refreshSubject.onNext(.stopRefresh)
                switch event {
                case .success(let myCoin):
                    self.myCoin.accept(myCoin)
                case .failure:
                    self.myCoin.accept(nil)
                }
            }.disposed(by: disposeBag)
    }
    
    func logout() -> Single<BaseModel<String>> {
        return accountProvider.rx.request(AccountService.logout)
            .map(BaseModel<String>.self)
    }
}

extension MyViewModel {
    static let logoutDataSource: [My] = [.myGitHub, .myJueJin, .openSource, .tools, .course, .ranking, .login]
    
    static let loginDataSource: [My] = [.myGitHub, .myJueJin, .openSource, .tools, .course, .ranking, .myCoin, .myCollect, .logout]
}
