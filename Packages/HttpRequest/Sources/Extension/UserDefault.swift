//
//  UserDefault.swift
//  HttpRequest
//
//  Created by dy on 2022/11/24.
//

import Foundation

/// UserDefaults.standard的简化写法
@propertyWrapper
public struct UserDefault<T> {
    let key: String

    let defaultValue: T

    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue

        } set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    /// 这里如果不定义projectedValue,那么外部要获取UserDefault<T> 类型,只能使用_some,定义了就可以使用$some
    public var projectedValue: Self { self }

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
