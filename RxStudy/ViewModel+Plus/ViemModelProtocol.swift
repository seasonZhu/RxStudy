//
//  ViemModelProtocol.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxCocoa

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
protocol ViemModelOutputs {
    
    associatedtype T
            
    /// 数据源数组
    var dataSource: BehaviorRelay<[T]> { get }
}
