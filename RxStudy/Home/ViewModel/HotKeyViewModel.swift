//
//  HotKeyViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya

class HotKeyViewModel: BaseViewModel {
    
    private let disposeBag: DisposeBag
    
    init(disposeBag: DisposeBag) {
        self.disposeBag = disposeBag
        super.init()
    }
    
    /// outputs
    let dataSource = BehaviorRelay<[HotKey]>(value: [])
    
    /// inputs
    func loadData() {
        requestData()
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

//MARK:- 网络请求
private extension HotKeyViewModel {
    func requestData() -> Single<BaseModel<[HotKey]>> {
        let result = homeProvider.rx.request(HomeService.hotKey)
            .map(BaseModel<[HotKey]>.self)
            /// 转为Observable
            .asObservable().asSingle()
        
        return result
    }
}

