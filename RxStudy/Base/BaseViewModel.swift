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
    /// inputs修饰前缀,这里没有使用rx这种命名空间的思路,并不是我不会,而是不想增加编写和理解成本
    var inputs: Self { return self }

    /// outputs修饰前缀
    var outputs: Self { return self }
    
    /// 网络请求的Moya错误,为空说明走到success里面了,有值的话,并不在乎值是什么,直接显示error画面
    let networkError = PublishSubject<MoyaError?>()
    
    /// 模型名称
    var className: String { String(describing: self) }
    
    deinit {
        debugLog("\(classNameWithoutNamespace)被销毁了")
    }
}

extension BaseViewModel: HasDisposeBag {}

extension BaseViewModel: TypeNameProtocol {}

extension BaseViewModel {
    
    /// 在ViewModel的基类中封装针对网络请求错误的方法,避免在子类中写重复代码
    /// - Parameter event: SingleEvent
    func processRxMoyaRequestEvent<T: Codable>(event: SingleEvent<T>) {
        networkError.onNext(event.moyaError)
    }
}

extension SingleEvent {
    var moyaError: MoyaError? {
        switch self {
        case .success(_):
            return nil
        case .failure(let error):
            guard let moyaError = error as? MoyaError else { return nil }
            
            return moyaError
        }
    }
}
