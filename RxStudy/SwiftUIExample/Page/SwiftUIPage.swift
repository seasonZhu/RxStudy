//
//  SwiftUICombineCoinRankListPage.swift
//  RxStudy
//
//  Created by dy on 2022/9/26.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI
import Combine

struct CoinRankListPage: View {
    
    @StateObject var viewModel = CoinRankListPageViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.dataSource.isNotEmpty {
                RefreshHeader(refreshing: $viewModel.headerRefreshing, action: {
                    viewModel.refreshAction()
                }) { progress in
                    if viewModel.headerRefreshing {
                        SimpleRefreshingView()
                    } else {
                        SimplePullToRefreshView(progress: progress)
                    }
                }
            }
            
            ForEach(viewModel.dataSource) { data in
                CoinRankListPageCell(rank: data)
            }
            
            if viewModel.dataSource.isNotEmpty{
                RefreshFooter(refreshing: $viewModel.footerRefreshing, action: {
                    viewModel.loadMoreAction()
                }) {
                    if viewModel.isNoMoreData {
                        Text("No more data !")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        SimpleRefreshingView()
                            .padding()
                    }
                }
                .noMore(viewModel.isNoMoreData)
                .preload(offset: 50)
            }
        }
        .enableRefresh()
        .overlay(Group {
            if viewModel.dataSource.isEmpty {
                ActivityIndicator(style: .large)
            } else {
                EmptyView()
            }
        })
        .padding(.top, 20)
        .navigationBarTitle("SwiftUI例子", displayMode: .inline)
    }
}

struct CoinRankListPageCell: View {
    let rank: ClassCoinRank?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let username = rank?.username {
                Text(username)
                    .padding(.leading, 15)
            }
            
            if let myInfo = rank?.myInfo {
                Text(myInfo)
                    .padding(.leading, 15)
            }
            
            Divider()
        }
    }
}
