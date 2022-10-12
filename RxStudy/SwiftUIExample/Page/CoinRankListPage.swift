//
//  SwiftUICombineCoinRankListPage.swift
//  RxStudy
//
//  Created by dy on 2022/9/26.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI
import Combine
import Kingfisher

struct CoinRankListPage: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel = CoinRankListPageViewModel()
    
    var body: some View {
        //normalView
        stateView
    }
    
    var normalView: some View {
        NavigationView {
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
        }
        .onLoad {
            viewModel.refreshAction()
            //UINavigationBar.appearance().isHidden = true
        }
    }
    
    var stateView: some View {
        NavigationView {
            ViewMaker(viewState: $viewModel.state) { dataSource in
                ScrollView(showsIndicators: false) {
                    refreshHeader
                    bannerView
                    ForEach(dataSource) { data in
                        CoinRankListPageCell(rank: data)
                    }
                    loadMoreFooter
                }
                .enableRefresh()
                /// 防止页面向上顶
                .padding(.top, 20)
                
            }
            .navigationBarTitle("SwiftUI例子", displayMode: .inline)
        }
        .onLoad {
            viewModel.refreshAction()
        }
    }
}

extension CoinRankListPage {
    private var refreshHeader: some View {
        RefreshHeader(refreshing: $viewModel.headerRefreshing, action: {
            /// 在stateView中添加了bannerView之后,会出现下拉刷新时,排名接口与轮播接口都刷2次的情况
            /// 其实目前还没有找到具体的原因
            /// 但是删除bannerView又好了,感觉就是第一次请求数据驱动了bannerView,bannerView有导致更新了一次
            /// 通过之前RxSwift的经验,通过防抖解决了
            print("下拉刷新")
            viewModel.action.send()
            //viewModel.refreshAction()
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
    
    private var bannerView: some View {
        ACarousel(viewModel.banners,
                  spacing: 0,
                  headspace: 0,
                  sidesScaling: 1,
                  autoScroll: .active(1.5)) { model in
            if let path = model.imagePath {
                if #available(iOS 14.0, *) {
                    KFImage(URL(string: path))
                        .resizable()
                        .scaledToFill()
                        .frame(height: UIScreen.main.bounds.width * (9.0 / 16.0))
                }
            }
        }
                  .frame(height: UIScreen.main.bounds.width * (9.0 / 16.0))
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
