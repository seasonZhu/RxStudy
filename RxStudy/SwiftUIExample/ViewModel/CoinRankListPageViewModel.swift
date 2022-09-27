//
//  SwiftUIViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/9/26.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI
import Combine

class CoinRankListPageViewModel: ObservableObject {
    
    /// 初始化page为1
    private var page: Int = 1

    private var cancellable: AnyCancellable?
    
    @Published var dataSource = [ClassCoinRank]()
    
    @Published var headerRefreshing = false
    
    @Published var footerRefreshing = false
    
    @Published var isNoMoreData = false
    
    deinit {
        print("\(className)被销毁了")
        cancellable?.cancel()
    }
}

extension CoinRankListPageViewModel {
    /// 下拉刷新行为
    func refreshAction() {
        resetCurrentPageAndMjFooter()
        getCoinRank(page: page)
    }
    
    /// 上拉加载更多行为
    func loadMoreAction() {
        page = page + 1
        getCoinRank(page: page)
    }
}

extension CoinRankListPageViewModel {
    /// 下拉的参数与状态重置行为
    private func resetCurrentPageAndMjFooter() {
        page = 1
        
        //headerRefreshing = false
        footerRefreshing = false
        isNoMoreData = false
    }
    
    /// 具体的网络请求
    private func getCoinRank(page: Int) {
        cancellable = myProvider.requestPublisher(MyService.coinRank((page)))
            .map(BaseModel<Page<ClassCoinRank>>.self)
            .map{ $0.data }
            .compactMap { $0 }
            /// 将事件从 Publisher<Output, MoyaError> 转换为 Publisher<Event<Output, MoyaError>, Never> 从而避免了错误发生,进而整个订阅会被结束掉，后续新的通知并不会被转化为请求。
            //.materialize()
            .sink { completion in
                
                
                self.headerRefreshing = false
                self.footerRefreshing = false
                
                switch completion {
                case .finished:
                    print("CoinRankListPageViewModel completion: \(completion)")
                case .failure(let error):
                    print("CoinRankListPageViewModel error: \(error)")
                }
                
            } receiveValue: { pageModel in
                if let datas = pageModel.datas {
                    if self.page == 1 {
                        self.dataSource = datas
                        //self.headerRefreshing = false
                    } else {
                        self.dataSource.append(contentsOf: datas)
                        //self.footerRefreshing = false
                    }
                }
                
                self.isNoMoreData = pageModel.isNoMoreData
                //self.noMore = self.dataSource.count > 50
            }
    }
}

extension CoinRankListPageViewModel: TypeNameProtocol {}
