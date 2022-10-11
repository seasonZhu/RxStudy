//
//  State.swift
//  RxStudy
//
//  Created by dy on 2022/10/10.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI


typealias BuilderWidget<D: Codable, V: View> = (D) -> V

enum ViewState<D: Codable> {
    case loading
    case error(_ retry: (() -> Void)?)
    case success(_ success: ViewSuccess)
    
    enum ViewSuccess {
        case noData
        case content(_ dataSource: D)
    }
}

struct ViewMaker<D: Codable, V: View>: View {
    
    /// 这里一定要用@Binding修饰,否则状态无法改变
    @Binding var viewState: ViewState<D>
    
    let builder: BuilderWidget<D, V>
    
    var body: some View {
        switch viewState {
        case .loading:
            if #available(iOS 14.0, *) {
                ProgressView()
            } else {
                ActivityIndicator(style: .large)
            }
        case .error(let retry):
            VStack {
                Text("Error")
                
                if let retry {
                    Button {
                        retry()
                    } label: {
                        Text("重试")
                    }
                }
            }
        case .success(let viewSuccess):
            switch viewSuccess {
            case .noData:
                Text("no data")
            case .content(let dataSource):
                builder(dataSource)
            }
        }
    }
}

