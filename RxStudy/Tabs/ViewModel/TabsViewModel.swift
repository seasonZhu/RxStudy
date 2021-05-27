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

class TabsViewModel: BaseViewModel {
    
    private let type: TagType

    private let disposeBag: DisposeBag
    
    init(type: TagType, disposeBag: DisposeBag) {
        self.type = type
        self.disposeBag = disposeBag
    }
    
    /// outputs
    var refreshStauts: BehaviorRelay<RefreshStatus> = BehaviorRelay(value: .header(.begainHeaderRefresh))
    
    let dataSource = BehaviorRelay<[Tab]>(value: [])
    
    // inputs
    func loadData() {
        requestData()
            .map{ $0.data }
        /// 去掉其中为nil的值
            .compactMap{ $0 }
        .drive(onNext: { items in
            self.dataSource.accept(items)
        })
        .disposed(by: disposeBag)
    }
}

//MARK:- 网络请求
private extension TabsViewModel {
    func requestData() -> Driver<BaseModel<[Tab]>> {
        let result: Driver<BaseModel<[Tab]>>
        switch type {
        case .project:
            result = projectProvider.rx.request(ProjectService.tags)
                .map(BaseModel<[Tab]>.self)
                /// 转为Observable
                .asDriver(onErrorDriveWith: Driver.empty())
        case .publicNumber:
            result = projectProvider.rx.request(ProjectService.tags)
                .map(BaseModel<[Tab]>.self)
                /// 转为Observable
                .asDriver(onErrorDriveWith: Driver.empty())
        case .tree:
            result = projectProvider.rx.request(ProjectService.tags)
                .map(BaseModel<[Tab]>.self)
                /// 转为Observable
                .asDriver(onErrorDriveWith: Driver.empty())
        }
        
        return result
    }
}
