//
//  BaseViewModel.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import NSObject_Rx

class BaseViewModel {
    /// 修饰前缀
    var inputs: Self { return self }

    var outputs: Self { return self }
    
    deinit {
        print("\(type(of: self))被销毁了")
    }
}

extension BaseViewModel: HasDisposeBag {}
