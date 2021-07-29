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
    
    init(type: TagType) {
        self.type = type
        super.init()
    }
    
    /// outputs    
    let dataSource = BehaviorRelay<[Tab]>(value: [])
    
    /// inputs
    func loadData() {
        requestData()
    }
}

//MARK:- 网络请求
private extension TabsViewModel {
    func requestData() {
        let result: Single<Response>
        switch type {
        case .project:
            result = projectProvider.rx.request(ProjectService.tags)
        case .publicNumber:
            result = publicNumberProvider.rx.request(PublicNumberService.tags)
        case .tree:
            result = treeProvider.rx.request(TreeService.tags)
        }
        
        result
            .map(BaseModel<[Tab]>.self)
            .map{ $0.data }
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            .subscribe(onSuccess: { items in
                self.networkError.onNext(nil)
                self.dataSource.accept(items)
            }, onError: { error in
                guard let moyarror = error as? MoyaError else { return }
                self.networkError.onNext(moyarror)
            })
        .disposed(by: disposeBag)
    }
}
