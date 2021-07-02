//
//  ViemModelProtocol.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

/// 上下拉行为类型
enum ScrollViewActionType {
    case refresh
    case loadMore
}

/// vm接受页面输入行为
protocol VMInputs {
    /// 加载数据
    /// - Parameter actionType: 操作行为
    func loadData(actionType: ScrollViewActionType)
}

/// vm输出数据行为
protocol VMOutputs {
    
    associatedtype T
            
    /// 数据源数组
    var dataSource: BehaviorRelay<[T]> { get }
}

/// 包含分页的PageVM设置
protocol PageVMSetting {
    /// 页码数
    var pageNum: Int { set get }
    
    /// 刷新状态值
    var refreshSubject: BehaviorSubject<MJRefreshAction> { get }
    
    /// 重置刷新状态与页码数
    func resetCurrentPageAndMjFooter()
}
