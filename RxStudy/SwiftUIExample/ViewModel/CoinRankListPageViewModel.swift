//
//  SwiftUIViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/9/26.
//  Copyright © 2022 season. All rights reserved.
//

import Combine

import HttpRequest

class CoinRankListPageViewModel: ObservableObject {
    
    /// 初始化page为1
    private var page: Int = 1

    /// 和 Cancellable 这个抽象的协议不同，AnyCancellable 是一个 class，这也赋予了它对自身的生命周期进行管理的能力。对于一般的 Cancellable，例如 connect 的返回值，我们需要显式地调用 cancel() 来停止活动，但 AnyCancellable 则在自己的 deinit 中帮我们做了这件事。换句话说，当 sink 或 assign 返回的 AnyCancellable 被释放时，它对应的订阅操作也将停止。在实际里，我们一般会把这个 AnyCancellable 设置为所在实例 (比如 UIViewController) 的存储属性。这样，当该实例 deinit 时，AnyCancellable 的 deinit 也会被触发，并自动释放资源。如果你对 RxSwift 有了解的话，它的行为和 DisposeBag 很类似
    private var cancellable: AnyCancellable?
    
    /// 使用垃圾袋进行回收处理
    private var cancellables: Set<AnyCancellable> = []
    
    /// 用了一个Subject进行防抖
    var action = PassthroughSubject<Void, Never>()
    
    /// 这几个@Published不要也可以
    @Published var headerRefreshing = false
    
    @Published var footerRefreshing = false
    
    @Published var isNoMoreData = false
    
    /// 数据驱动
    @Published var dataSource: [ClassCoinRank] = []
    
    @Published var banners: [ClassBanner] = []
    
    /// 状态驱动
    var state: ViewState<[ClassCoinRank]> = .loading
    
    init() {
        /// 防抖的订阅
        action
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshAction()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("\(className)被销毁了")
        
        /// 这里从理论上说就算不cancel,应该也可以自己释放
        //cancellable?.cancel()
        
        //clear()
    }
}

extension CoinRankListPageViewModel {
    private func clear() {
        let _ = cancellables.map { $0.cancel() }
        cancellables.removeAll()
    }
}

extension CoinRankListPageViewModel {
    /// 下拉刷新行为
    func refreshAction() {
        resetCurrentPageAndMjFooter()
        //getCoinRank(page: page)
        //getBanner()
        zip()
        //rxGetCoinRank(page: page)
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
        
        /// 不注释掉这个就出问题了
        //headerRefreshing = false
        footerRefreshing = false
        isNoMoreData = false
    }
    
    /// 具体的网络请求 Moya+Combine配合使用
    private func getCoinRank(page: Int) {
        /// 这里用不了assgin的原因:
        /// 注意 assign 所接受的第一个参数的类型为 ReferenceWritableKeyPath，也就是说，只有 class 上用 var 声明的属性可以通过 assign 来直接赋值。
        /// assign 的另一个“限制”是，上游 Publisher 的 Failure 的类型必须是 Never。如果上游 Publisher 可能会发生错误，我们则必须先对它进行处理，比如使用 replaceError 或者 catch 来把错误在绑定之前就“消化”掉。
        myProvider.requestPublisher(MyService.coinRank((page)))
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
                    print("CoinRankListPageViewModel getCoin completion: \(completion)")
                case .failure(let error):
                    print("CoinRankListPageViewModel getCoin error: \(error)")
                    self.state = .error(self.refreshAction)
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
                
                if self.dataSource.isEmpty {
                    self.state = .success(.noData)
                } else {
                    self.state = .success(.content(self.dataSource))
                }
            }
            .store(in: &cancellables)
    }
    
    private func getBanner() {
        homeProvider.requestPublisher(HomeService.banner)
            .map(BaseModel<[ClassBanner]>.self)
            .map{ $0.data }
            .compactMap { $0 }
            .sink { completion in
                
                switch completion {
                case .finished:
                    print("CoinRankListPageViewModel getBanner completion: \(completion)")
                case .failure(let error):
                    print("CoinRankListPageViewModel getBanner error: \(error)")
                }
            } receiveValue: { banners in
                self.banners = banners
            }
            .store(in: &cancellables)
    }
    
    private func zip() {
        let p0 = myProvider.requestPublisher(MyService.coinRank((1))).map(BaseModel<Page<ClassCoinRank>>.self)
            .map{ $0.data }
            .compactMap { $0 }
        
        let p1 = homeProvider.requestPublisher(HomeService.banner).map(BaseModel<[ClassBanner]>.self)
            .map{ $0.data }
            .compactMap { $0 }
        
        p0.zip(p1).sink { completion in
            self.headerRefreshing = false
            self.footerRefreshing = false
            
            switch completion {
            case .finished:
                print("CoinRankListPageViewModel refresh completion: \(completion)")
            case .failure(let error):
                print("CoinRankListPageViewModel refresh error: \(error)")
                self.state = .error(self.refreshAction)
            }
        } receiveValue: { pageModel, banners in
            
            if let datas = pageModel.datas {
                if self.page == 1 {
                    self.dataSource = datas
                } else {
                    self.dataSource.append(contentsOf: datas)
                }
            }
            
            self.isNoMoreData = pageModel.isNoMoreData
            
            if self.dataSource.isEmpty {
                self.state = .success(.noData)
            } else {
                self.state = .success(.content(self.dataSource))
            }
            
            self.banners = banners

        }
        .store(in: &cancellables)

    }
}

extension CoinRankListPageViewModel: TypeNameProtocol {}


//MARK: -  RxMoya与SwiftUI的配合使用
import RxSwift
import NSObject_Rx

extension CoinRankListPageViewModel {
    private func rxGetCoinRank(page: Int) {
        myProvider.rx.request(MyService.coinRank(page))
            /// 转Model
            .map(BaseModel<Page<ClassCoinRank>>.self)
            /// 由于需要使用Page,所以return到$0.data这一层,而不是$0.data.datas
            .map{ $0.data }
            /// 解包,这一步Single变成了Maybe
            .compactMap { $0 }
            /// 转换操作, Maybe要先转成Observable
            .asObservable()
            /// 才能再转成Single
            .asSingle()
            /// 订阅
            .subscribe { event in
                
                /// 订阅事件
                /// 通过page的值判断是下拉还是上拉(可以用枚举),不管成功还是失败都结束刷新状态
                self.headerRefreshing = false
                self.footerRefreshing = false
                
                switch event {
                case .success(let pageModel):
                    if let datas = pageModel.datas {
                        if self.page == 1 {
                            self.dataSource = datas
                        } else {
                            self.dataSource.append(contentsOf: datas)
                        }
                    }
                    
                    self.isNoMoreData = pageModel.isNoMoreData
                    
                    if self.dataSource.isEmpty {
                        self.state = .success(.noData)
                    } else {
                        self.state = .success(.content(self.dataSource))
                    }
                    
                case .failure:
                    self.state = .error(self.refreshAction)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension CoinRankListPageViewModel: HasDisposeBag {}
