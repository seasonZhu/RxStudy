//
//  TabsViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/26.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import Moya

typealias TreeViewModel = TabsViewModel

class TabsViewModel: BaseViewModel {
    
    private let type: TagType

    private let disposeBag: DisposeBag
    
    init(type: TagType, disposeBag: DisposeBag) {
        self.type = type
        self.disposeBag = disposeBag
    }
    
    /// outputs    
    let dataSource = BehaviorRelay<[Tab]>(value: [])
    
    // inputs
    func loadData() {
        requestData()
            .map{ $0.data }
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            .subscribe(onSuccess: { items in
                self.dataSource.accept(items)
            }, onError: { error in
                
            })
        .disposed(by: disposeBag)
    }
}

//MARK:- 网络请求
private extension TabsViewModel {
    func requestData() -> Single<BaseModel<[Tab]>> {
        let result: Single<BaseModel<[Tab]>>
        switch type {
        case .project:
            result = projectProvider.rx.request(ProjectService.tags)
                .map(BaseModel<[Tab]>.self)
                /// 转为Observable
                .asObservable().asSingle()
        case .publicNumber:
            result = publicNumberProvider.rx.request(PublicNumberService.tags)
                .map(BaseModel<[Tab]>.self)
                /// 转为Observable
                .asObservable().asSingle()
        case .tree:
            result = treeProvider.rx.request(TreeService.tags)
                .map(BaseModel<[Tab]>.self)
                /// 转为Observable
                .asObservable().asSingle()
        }
        
        return result
    }
}
