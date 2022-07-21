//
//  Moya+BlockingObservable.swift
//  RxStudy
//
//  Created by dy on 2022/7/21.
//  Copyright © 2022 season. All rights reserved.
//

import Moya

import RxSwift
import RxBlocking

extension BlockingObservable {
    
    /// 将Single序列转为只有单元素的Result类型
    var toSingleResult: Result<Element, Swift.Error> {
        do {
            let result = try single()
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    /// 将Observable序列转为包含数组的Result类型
    var toArrayResult: Result<[Element], Swift.Error> {
        do {
            let result = try toArray()
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}

extension Reactive where Base: MoyaProviderType {

    func blockingRequest(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Result<Response, Moya.MoyaError> {
        let blocking = request(token, callbackQueue: callbackQueue).asObservable().toBlocking()
        
        do {
            let response = try blocking.single()
            return .success(response)
        } catch {
            let moyaError = error as! MoyaError
            return .failure(moyaError)
        }
    }

}
