//
//  BaseViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import NSObject_Rx
import Moya

class BaseViewModel {
    /// 修饰前缀
    var inputs: Self { return self }

    var outputs: Self { return self }
    
    var networkError = PublishSubject<Void>()
    
    deinit {
        print("\(type(of: self))被销毁了")
    }
}

extension BaseViewModel: HasDisposeBag {}
