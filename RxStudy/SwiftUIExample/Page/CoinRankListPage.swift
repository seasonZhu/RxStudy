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
            refreshHeader
            listView
            loadMoreFooter
        }
        .enableRefresh()
        .overlay(HUD)
        /// 防止页面向上顶
        .padding(.top, 20)
        .navigationBarTitle("SwiftUI例子", displayMode: .inline)
        .onAppear{ viewModel.refreshAction() } 
    }
}

extension CoinRankListPage {
    private var refreshHeader: some View {
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
    
    private var loadMoreFooter: some View {
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
    
    private var listView: some View {
        ForEach(viewModel.dataSource) { data in
            CoinRankListPageCell(rank: data)
        }
    }
    
    private var HUD: some View {
        Group {
            if viewModel.dataSource.isEmpty {
                ActivityIndicator(style: .large)
            } else {
                EmptyView()
            }
        }
    }
}
