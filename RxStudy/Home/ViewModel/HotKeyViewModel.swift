//
//  HotKeyViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import Moya

class HotKeyViewModel: BaseViewModel {
    
    /// outputs
    let dataSource = BehaviorRelay<[HotKey]>(value: [])
    
    /// inputs
    func loadData() {
        requestData()
    }
}

//MARK:- 网络请求
private extension HotKeyViewModel {
    func requestData() {
        homeProvider.rx.request(HomeService.hotKey)
            .map(BaseModel<[HotKey]>.self)
            .map{ $0.data }
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            .subscribe(onSuccess: { items in
                self.dataSource.accept(items)
            }, onError: { error in
                guard let _ = error as? MoyaError else { return }
                self.networkError.onNext(())
            })
            .disposed(by: disposeBag)
    }
}

