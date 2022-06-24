//
//  ToolViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

class ToolViewModel: BaseViewModel {
    
    /// outputs
    let dataSource = BehaviorRelay<[Tool]>(value: [])
    
    let refreshSubject = PublishSubject<MJRefreshAction>()
    
    /// inputs
    func loadData() {
        requestData()
    }
}

//MARK: - 网络请求
private extension ToolViewModel {
    func requestData() {
        otherProvider.rx.request(OtherService.tools)
            .map(BaseModel<[Tool]>.self)
            .map{ $0.data }
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            .asObservable()
            .asSingle()
            .subscribe { event in
                
                self.refreshSubject.onNext(.stopRefresh)
                
                switch event {
                case .success(let items):
                    self.dataSource.accept(items)
                case .failure:
                    break
                }
                self.processRxMoyaRequestEvent(event: event)
            }
            .disposed(by: disposeBag)
    }
}


