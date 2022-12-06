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
        
        if self.type == .tree {
            refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)
        }
        
        super.init()
    }
    
    /// outputs    
    let dataSource = BehaviorRelay<[Tab]>(value: [])
    
    /// 仅仅针对体系页面有用
    var refreshSubject: BehaviorSubject<MJRefreshAction>?
    
    /// inputs
    func loadData() {
        requestData()
    }
}

//MARK: - 网络请求
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
        case .course:
            result = provider.rx.request(MultiTarget(CourseService.tags))
        }
        
        result
            .map(BaseModel<[Tab]>.self)
            .map{ $0.data }
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            .asObservable()
            .asSingle()
            .subscribe { event in
                
                if self.type == .tree {
                    self.refreshSubject?.onNext(.stopRefresh)
                }
                
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
