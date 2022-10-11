//
//  BasePageViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/10/11.
//  Copyright © 2022 season. All rights reserved.
//

import Combine

protocol BasePageViewModelProtocol: ObservableObject {
    var cancellables: Set<AnyCancellable> { get set }
    
    func clear()
}

extension BasePageViewModelProtocol {
    func clear() {
        let _ = cancellables.map { $0.cancel() }
        cancellables.removeAll()
    }
}


class BasePageViewModel: BasePageViewModelProtocol  {
    var cancellables: Set<AnyCancellable> = []
    
    deinit {
        print("\(className)被销毁了")
        clear()
    }
}

extension BasePageViewModel: TypeNameProtocol {}
