//
//  CoinRankListViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

class CoinRankListViewModel {
    
        //表格数据序列
        let tableData = BehaviorRelay<[CoinRank]>(value: [])
         
        //停止头部刷新状态
        let endHeaderRefreshing: Driver<Bool>
         
        //停止尾部刷新状态
        let endFooterRefreshing: Driver<Bool>
         
        //ViewModel初始化（根据输入实现对应的输出）
    init(input: (headerRefresh: Driver<Void>, footerRefresh: Driver<Void>, scrollView: UIScrollView), disposeBag: DisposeBag) {
             
            //下拉结果序列
            let headerRefreshData = input.headerRefresh
                .startWith(()) //初始化时会先自动加载一次数据
                .flatMapLatest { _ in  //也可考虑使用flatMapFirst
                    return myProvider.rx.request(MyService.coinRank(1)).map(BaseModel<Page<CoinRank>>.self)
                        /// 将BaseModel<Page<CoinRank>转为[CoinRank]
                        .map{ $0.data?.datas?.map{ $0 }}
                        /// 去掉其中为nil的值
                        .compactMap{ $0 }
                        /// 转为Observable
                        .asDriver(onErrorDriveWith: Driver.empty())
                }
             
            //上拉结果序列
            let footerRefreshData = input.footerRefresh
                .flatMapLatest { _ in  //也可考虑使用flatMapFirst
                    return myProvider.rx.request(MyService.coinRank(1)).map(BaseModel<Page<CoinRank>>.self)
                        /// 将BaseModel<Page<CoinRank>转为[CoinRank]
                        .map{ $0.data?.datas?.map{ $0 }}
                        /// 去掉其中为nil的值
                        .compactMap{ $0 }
                        /// 转为Observable
                        .asDriver(onErrorDriveWith: Driver.empty())
                }
        
            
             
            //生成停止头部刷新状态序列
            endHeaderRefreshing = headerRefreshData.map{ _ in true }
             
            //生成停止尾部刷新状态序列
            endFooterRefreshing = footerRefreshData.map{ _ in true }
             
            //下拉刷新时，直接将查询到的结果替换原数据
            headerRefreshData.drive(onNext: { items in
                self.tableData.accept(items)
            }).disposed(by: disposeBag)
             
            //上拉加载时，将查询到的结果拼接到原数据底部
            footerRefreshData.drive(onNext: { items in
                self.tableData.accept(self.tableData.value + items )
            }).disposed(by: disposeBag)
        }
}
