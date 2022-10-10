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

    /// 和 Cancellable 这个抽象的协议不同，AnyCancellable 是一个 class，这也赋予了它对自身的生命周期进行管理的能力。对于一般的 Cancellable，例如 connect 的返回值，我们需要显式地调用 cancel() 来停止活动，但 AnyCancellable 则在自己的 deinit 中帮我们做了这件事。换句话说，当 sink 或 assign 返回的 AnyCancellable 被释放时，它对应的订阅操作也将停止。在实际里，我们一般会把这个 AnyCancellable 设置为所在实例 (比如 UIViewController) 的存储属性。这样，当该实例 deinit 时，AnyCancellable 的 deinit 也会被触发，并自动释放资源。如果你对 RxSwift 有了解的话，它的行为和 DisposeBag 很类似
    private var cancellable: AnyCancellable?
    
    @Published var headerRefreshing = false
    
    @Published var footerRefreshing = false
    
    @Published var isNoMoreData = false
    
    /// 数据驱动(@Published不要好像也可以)
    @Published var dataSource = [ClassCoinRank]()
    
    /// 状态驱动
    var state: ViewState<[ClassCoinRank]> = .loading
    
    deinit {
        print("\(className)被销毁了")
        /// 这里从理论上说就算不cancel,应该也可以自己释放
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
        /// 这里用不了assgin的原因:
        /// 注意 assign 所接受的第一个参数的类型为 ReferenceWritableKeyPath，也就是说，只有 class 上用 var 声明的属性可以通过 assign 来直接赋值。
        /// assign 的另一个“限制”是，上游 Publisher 的 Failure 的类型必须是 Never。如果上游 Publisher 可能会发生错误，我们则必须先对它进行处理，比如使用 replaceError 或者 catch 来把错误在绑定之前就“消化”掉。
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
                    self.state = .error
                }
                
            } receiveValue: { pageModel in
                if let datas = pageModel.datas {
                    if self.page == 1 {
                        self.dataSource = datas
                        //self.headerRefreshing = false
                        
                        if self.dataSource.isEmpty {
                            self.state = .success(.noData)
                        }
                        
                    } else {
                        self.dataSource.append(contentsOf: datas)
                        //self.footerRefreshing = false
                    }
                }
                
                self.isNoMoreData = pageModel.isNoMoreData
                //self.noMore = self.dataSource.count > 50
                
                self.state = .success(.content(self.dataSource))
            }
    }
}

extension CoinRankListPageViewModel: TypeNameProtocol {}
