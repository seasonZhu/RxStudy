//
//  SwiftUICombineCoinRankListPage.swift
//  RxStudy
//
//  Created by dy on 2022/9/26.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI
import Combine

class ClassCoinRank : ObservableObject, Identifiable, Codable {

    let coinCount : Int?
    let level : Int?
    let nickname : String?
    let rank : String?
    let userId : Int?
    let username : String?
    
    var myInfo: String {
        guard let rank,
              let level,
              let coinCount else {
            return "排名: -- 等级: -- 积分: --"
        }
        return "排名: \(rank) 等级: \(level) 积分: \(coinCount)"
    }
    
    var rankInfo: String {
        if let username = username {
            return "\(username)\n\n\(myInfo)"
        } else {
            return myInfo
        }
    }
}

class CoinRankListPageViewModel: ObservableObject {

    var cancellable: AnyCancellable?
    
    @Published var dataSource = [ClassCoinRank]()
    
    init() {
        getMyCoinList(page: 1)
    }
    
    func getMyCoinList(page: Int) {
        cancellable = myProvider.requestPublisher(MyService.coinRank((page)))
            .map(BaseModel<Page<ClassCoinRank>>.self)
            .map{ $0.data }
            .compactMap { $0 }
            /// 将事件从 Publisher<Output, MoyaError> 转换为 Publisher<Event<Output, MoyaError>, Never> 从而避免了错误发生,进而整个订阅会被结束掉，后续新的通知并不会被转化为请求。
            //.materialize()
            .sink { completion in
                print(completion)
                guard case let .failure(error) = completion else { return }
                print(error)
            } receiveValue: { pageModel in
                print(pageModel)
                self.dataSource = pageModel.datas ?? []
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

struct CoinRankListPage: View {
    
    @StateObject var viewModel = CoinRankListPageViewModel()
    
    var body: some View {
        if viewModel.dataSource.isEmpty {
            Text("暂无数据")
        } else {
            List(viewModel.dataSource) { data in
                Text(data.rankInfo)
            }
        }
    }
}
