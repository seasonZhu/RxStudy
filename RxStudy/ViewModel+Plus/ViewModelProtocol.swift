//
//  ViewModelProtocol.swift
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

protocol PageVMBaseSetting {
    /// 页码数
    var pageNum: Int { set get }
    
    /// 重置刷新状态与页码数
    func resetCurrentPageAndMjFooter()
    
    /// 加载更多失败,回退页面数
    func loadMoreFailureResetCurrentPage()
}

/// 包含分页的PageVM设置
protocol PageVMSetting: PageVMBaseSetting {
    /// 刷新状态值
    var refreshSubject: BehaviorSubject<MJRefreshAction> { get }
}

/// 针对SingleTabListViewModel与SingleTabListController专门优化的协议,
/// 其实可以全部替换为这个协议,只是改动量会比较大,需要在每个控制器都主动设置下拉刷新
/// 我最初的想法是refreshSubject遵守某个协议来抹平BehaviorSubject与PublishSubject,于是我特地去看了两者的公共集成,但是都是基于associatedtype的协议,于是失败了
protocol PageVM2Setting: PageVMBaseSetting {
    /// 刷新状态值
    var refreshSubject: PublishSubject<MJRefreshAction> { get }
}

/// 下面这种展平方式也不行
protocol RelayProtocol {
    
}

extension BehaviorSubject: RelayProtocol {
    
}

extension PublishSubject: RelayProtocol {
    
}

/// 这种方式也不行
typealias Mixin<Element> = Observable<Element> & SubjectType & Cancelable & ObserverType
