//
//  ViemModelProtocol.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxCocoa
import NSObject_Rx

/// 页面的下拉刷新和上拉加载更多行为
enum ScrollViewActionType {
    case refresh
    case loadMore
}

/// vm接受页面输入行为
protocol ViemModelInputs {
    /// 加载数据
    /// - Parameter actionType: 操作行为
    func loadData(actionType: ScrollViewActionType)
}

/// vm输出数据行为
protocol ViemModelOutputs: Refreshable {
    
    associatedtype T
            
    /// 数据源数组
    var dataSource: BehaviorRelay<[T]> { get }
}


class BaseViewModel {
    /// 修饰前缀
    var inputs: Self { return self }

    var outputs: Self { return self }
    
    deinit {
        print("\(type(of: self))被销毁了")
    }
}

extension BaseViewModel: HasDisposeBag {}
