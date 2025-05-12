//
//  PropertyWrapper.swift
//  RxStudy
//
//  Created by dy on 2022/8/26.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

import RxRelay

/// https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md

@propertyWrapper
struct ReplaceHtmlElement {
    var wrappedValue: String? {
        didSet {
            wrappedValue = wrappedValue?.replaceHtmlElement
        }
    }

    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue?.replaceHtmlElement
    }
}

/// 通过$,将Int转为String
@propertyWrapper
struct IntToStringFactory {
    
    var wrappedValue: Int

    var projectedValue: String { String(wrappedValue) }

}

/// 定义的时候,入参一个闭包,$拿到的就是闭包处理后的数据
@propertyWrapper
struct FunctionFactory<Input, Output> {
    
    var wrappedValue: Input
    
    let function: (Input) -> Output

    var projectedValue: Output { function(wrappedValue) }
}

/// 其实和IntToStringFactory逻辑相似
@propertyWrapper
struct StringFactory {
    var wrappedValue: Int
    
    var aNum: Int

    var projectedValue: String { String("\(wrappedValue * aNum)") }
}

/// RxCocoa's BehaviorRelay replays the most recent value provided to it for each of the subscribed observers. It is created with an initial value, has wrappedValue property to access the current value and a projectedValue to expose a projection providing API to subscribe a new observer: (Thanks to Adrian Zubarev for pointing this out)
/// Combine's Published property wrapper is similar in spirit, allowing clients to subscribe to @Published properties (via the $ projection) to receive updates when the value changes.
@propertyWrapper
class RxBehaviorRelay<T> {
    var wrappedValue: T {
        set {
            projectedValue.accept(newValue)
        }
        
        get {
            projectedValue.value
        }
    }
    
    var projectedValue: BehaviorRelay<T>
    
    init(wrappedValue: T) {
        self.projectedValue = BehaviorRelay(value: wrappedValue)
        self.wrappedValue = wrappedValue
    }
}

/// 和FunctionFactory类似,这里只是将赋值的变为闭包,而入参变成普通参数而已
@propertyWrapper
class AFunction {
    var wrappedValue: ((String) -> String)
    
    private let input: String
    
    init(wrappedValue: @escaping ((String) -> String), input: String) {
        self.wrappedValue = wrappedValue
        self.input = input
    }
    
    var projectedValue: String { aFuntion(aString: (wrappedValue(input))) }
    
    func aFuntion(aString: String) -> String {
        aString + "哈哈"
    }
}

/// 使用结构体做属性包装器的好处是 构造函数已经隐式写好了
@propertyWrapper
struct A<T> {
    var wrappedValue: T
    
    var projectedValue: Int? {
        if let num = wrappedValue as? Int {
            return num * 10
        } else {
            return nil
        }
    }
}

@propertyWrapper
class B<T> {
    var wrappedValue: A<T>
    
    init(wrappedValue: A<T>) {
        self.wrappedValue = wrappedValue
    }
    
    var projectedValue: Int? {
        if let num = wrappedValue.projectedValue {
            return num * 100
        } else {
            return nil
        }
    }
}

/// UserDefaults.standard的简化写法
@propertyWrapper
struct UserDefault<T> {
    let key: String
    
    let defaultValue: T
  
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
            
        } set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    /// 这里如果不定义projectedValue,那么外部要获取UserDefault<T> 类型,只能使用_some,定义了就可以使用$some
    var projectedValue: Self { self }
    
    /// 移除
    func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

protocol Copyable: AnyObject {
    func copy() -> Self
}

/// 写时复制
@propertyWrapper
struct CopyOnWrite<Value: Copyable> {
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
  
    private(set) var wrappedValue: Value
  
    var projectedValue: Value {
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
