//
//  PropertyWrapper.swift
//  RxStudy
//
//  Created by dy on 2022/8/26.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

@propertyWrapper
public struct ReplaceHtmlElement {
    public var wrappedValue: String? {
        didSet {
            wrappedValue = wrappedValue?.replaceHtmlElement
        }
    }

    public init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue?.replaceHtmlElement
    }
}

/// 通过$,将Int转为String
@propertyWrapper
public struct IntToStringFactory {
    public var wrappedValue: Int

    public var projectedValue: String { String(wrappedValue) }

    public init(wrappedValue: Int) {
        self.wrappedValue = wrappedValue
    }
}

/// 定义的时候,入参一个闭包,$拿到的就是闭包处理后的数据
@propertyWrapper
public struct FunctionFactory<Input, Output> {
    public var wrappedValue: Input

    let function: (Input) -> Output

    public var projectedValue: Output { function(wrappedValue) }

    public init(wrappedValue: Input, function: @escaping (Input) -> Output) {
        self.wrappedValue = wrappedValue
        self.function = function
    }
}

/// 其实和IntToStringFactory逻辑相似
@propertyWrapper
public struct StringFactory {
    public var wrappedValue: Int

    var aNum: Int

    public var projectedValue: String { String("\(wrappedValue * aNum)") }

    public init(wrappedValue: Int, aNum: Int) {
        self.wrappedValue = wrappedValue
        self.aNum = aNum
    }
}

/// 和FunctionFactory类似,这里只是将赋值的变为闭包,而入参变成普通参数而已
@propertyWrapper
public class AFunction {
    public var wrappedValue: (String) -> String

    private let input: String

    public init(wrappedValue: @escaping ((String) -> String), input: String) {
        self.wrappedValue = wrappedValue
        self.input = input
    }

    public var projectedValue: String { aFuntion(aString: wrappedValue(input)) }

    public func aFuntion(aString: String) -> String {
        aString + "哈哈"
    }
}

/// 使用结构体做属性包装器的好处是 构造函数已经隐式写好了
@propertyWrapper
public struct A<T> {
    public var wrappedValue: T

    public var projectedValue: Int? {
        if let num = wrappedValue as? Int {
            return num * 10
        } else {
            return nil
        }
    }

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public class B<T> {
    public var wrappedValue: A<T>

    public init(wrappedValue: A<T>) {
        self.wrappedValue = wrappedValue
    }

    public var projectedValue: Int? {
        if let num = wrappedValue.projectedValue {
            return num * 100
        } else {
            return nil
        }
    }
}

public protocol Copyable: AnyObject {
    func copy() -> Self
}

/// 写时复制
@propertyWrapper
struct CopyOnWrite<Value: Copyable> {
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public private(set) var wrappedValue: Value

    public var projectedValue: Value {
        mutating get {
            if !isKnownUniquelyReferenced(&wrappedValue) {
                wrappedValue = wrappedValue.copy()
            }
            return wrappedValue
        }
        set {
            wrappedValue = newValue
        }
    }
}
