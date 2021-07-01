//
//  WebViewModel.swift
//  RxStudy
//
//  Created by season on 2021/6/22.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class WebViewModel: BaseViewModel {
    
    let collectSuccess = BehaviorRelay(value: false)
    
    let unCollectSuccess = BehaviorRelay(value: false)
    
}

extension WebViewModel {
    
    func collectAction(collectId: Int){
        myProvider.rx.request(MyService.collectArticle(collectId))
            .map(BaseModel<String>.self)
            .map { $0.isSuccess }
            .subscribe { isSucces in
                self.collectSuccess.accept(isSucces)
                
                guard var collectIds = AccountManager.shared.accountInfo?.collectIds else {
                    return
                }
                
                collectIds.append(collectId)
                
                AccountManager.shared.updateCollectIds(collectIds)
                
            } onError: { _ in
                self.collectSuccess.accept(false)
            }.disposed(by: disposeBag)

    }
    
    func unCollectAction(collectId: Int) {
        myProvider.rx.request(MyService.unCollectArticle(collectId))
            .map(BaseModel<String>.self)
            .map { $0.isSuccess }
            .subscribe { isSucces in
                self.unCollectSuccess.accept(isSucces)
                
                guard var collectIds = AccountManager.shared.accountInfo?.collectIds else {
                    return
                }
                
                if collectIds.contains(collectId), let index = collectIds.index(of: collectId) {
                    collectIds.remove(at: index)
                }
                
                AccountManager.shared.updateCollectIds(collectIds)
            } onError: { _ in
                self.unCollectSuccess.accept(false)
            }.disposed(by: disposeBag)
    }
}
