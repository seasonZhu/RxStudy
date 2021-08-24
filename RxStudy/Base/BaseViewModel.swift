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
    /// inputs修饰前缀
    var inputs: Self { return self }

    /// outputs修饰前缀
    var outputs: Self { return self }
    
    /// 网络请求的Moya错误,为空说明走到success里面了,有值的话,并不在乎值是什么,直接显示error画面
    let networkError = PublishSubject<MoyaError?>()
    
    /// 模型名称
    var className: String { String(describing: self) }
    
    deinit {
        print("\(className)被销毁了")
    }
}

extension BaseViewModel: HasDisposeBag {}
