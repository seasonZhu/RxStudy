//
//  State.swift
//  RxStudy
//
//  Created by dy on 2022/10/10.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI

/// D代表数据,目前没有去约束,V代码是构建的View
typealias BuilderWidget<D, V: View> = (D) -> V

enum ViewState<D> {
    case loading
    case error(_ retry: (() -> Void)?)
    case success(_ success: ViewSuccess)
    
    enum ViewSuccess {
        case noData
        case content(_ dataSource: D)
    }
}

struct ViewMaker<D, V: View>: View {
    
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

/*
struct State {
    var products: [String] = []
    var isLoading = false
}

enum Action {
    case fetch
}

@dynamicMemberLookup
final class Store<State, Action>: ObservableObject {
    
    typealias ReduceFunction = (State, Action) -> State

    @Published private var state: State
    private let reduce: ReduceFunction

    init(
        initialState state: State,
        reduce: @escaping ReduceFunction
    ) {
        self.state = state
        self.reduce = reduce
    }

    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }

    func send(_ action: Action) {
        state = reduce(state, action)
    }

}

let store: Store<State, Action> = .init(initialState: .init()) { state, action in
    var state = state
    switch action {
        case .fetch:
        state.isLoading = true
    }
    return state
}

/*
print(store.isLoading)
print(store.products)
print(store.favorites)
*/
*/
