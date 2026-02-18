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

/// 自己写的,对Result的扩展写法
extension Result where Success == Moya.Response, Failure == MoyaError {
    func map<Model: Codable>() -> Result<Model, Failure> {
        switch self {
            case .success(let response):
                do {
                    let model = try JSONDecoder().decode(Model.self, from: response.data)
                    return .success(model)
                } catch {
                    let error = MoyaError.objectMapping(error, response)
                    return .failure(error)
                }
                
            case .failure(let error):
                return .failure(error)
        }
    }
    
    func map<D: Decodable>(_ type: D.Type) -> Result<D, MoyaError> {
        switch self {
            case .success(let response):
                do {
                    let model = try JSONDecoder().decode(D.self, from: response.data)
                    return .success(model)
                } catch {
                    let error = MoyaError.objectMapping(error, response)
                    return .failure(error)
                }
                
            case .failure(let error):
                return .failure(error)
        }
    }
}

extension Result where Success == Any?, Failure == Moya.MoyaError {
    
    /// Result类型为Optional的去除nil普通写法
    /// - Returns: Result
    func filterNil() -> Result<Any, Moya.MoyaError> {
        switch self {
        case .success(let optional):
            switch optional {
            case .none:
                return .failure(.jsonMapping(emptyDataResponse))
            case .some(let wrapped):
                return .success(wrapped)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Result类型为Optional,需要显示写出Result的数据类型,去除nil的写法
    /// - Returns: Result
    func filterNil<T>() -> Result<T, Moya.MoyaError> {
        switch self {
        case .success(let optional):
            switch optional {
            case .none:
                return .failure(.jsonMapping(emptyDataResponse))
            case .some(let wrapped):
                if let model = wrapped as? T {
                    return .success(model)
                } else {
                    return .failure(.jsonMapping(emptyDataResponse))
                }
                
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Result类型为Optional,需要在入参中明确Wrapped的类型,去除nil的写法
    /// - Parameter type: Wrapped的类型
    /// - Returns: Result
    func filterNil<T>(_ type: T.Type) -> Result<T, Moya.MoyaError> {
        switch self {
        case .success(let optional):
            switch optional {
            case .none:
                let newResponse = Response(statusCode: 200, data: Data())
                return .failure(MoyaError.jsonMapping(newResponse))
            case .some(let wrapped):
                if let model = wrapped as? T {
                    return .success(model)
                } else {
                    return .failure(.jsonMapping(emptyDataResponse))
                }
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    var emptyDataResponse: Moya.Response {
        Response(statusCode: 200, data: Data())
    }
}
