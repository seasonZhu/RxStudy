//
//  CombineSinkEvent.swift
//  RxStudy
//
//  Created by dy on 2022/10/17.
//  Copyright © 2022 season. All rights reserved.
//

import Combine

/// 将Combine的状态值向RxSwift靠拢
enum CombineSinkEvent<Output, Failure: Error> {
    case next(Output)
    
    case completed
    
    case error(Failure)
}

extension CombineSinkEvent: CustomDebugStringConvertible {

    var debugDescription: String {
        switch self {
        case .next(let value):
            return "next(\(value))"
        case .error(let error):
            return "error(\(error))"
        case .completed:
            return "completed"
        }
    }
}

extension CombineSinkEvent {

    var isStopEvent: Bool {
        switch self {
        case .next: return false
        case .error, .completed: return true
        }
    }
    
    /*
     /// 带参数的枚举判断,并且对值进行判断的写法
     var size: CGSize {
        if case .digit(let value) = self, value == 0 {
            return CGSize(width: 88 * 2 + 8, height: 88)
        }
        return CGSize(width: 88, height: 88)
     }
     */

    var element: Output? {
        if case .next(let value) = self {
            return value
        }
        return nil
    }

    var error: Swift.Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }

    var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}

extension CombineSinkEvent {
    
    func map<Result>(_ transform: (Output) throws -> Result) -> CombineSinkEvent<Result, Swift.Error> {
        do {
            switch self {
            case let .next(element):
                return .next(try transform(element))
            case let .error(error):
                return .error(error)
            case .completed:
                return .completed
            }
        } catch let e {
            return .error(e)
        }
    }
}
