//
//  Codable+Extension.swift
//  RxStudy
//
//  Created by dy on 2022/5/23.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation
import RxCocoa

/// iOS-Swift 独孤九剑：十四、Codable 的基本应用及源码浅析:
/// https://juejin.cn/post/7100194774656745480

/// 可以同时Codable 字符串和Int类型
struct StringInt: Codable {
    var stringValue: String

    var intValue: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            stringValue = value
            intValue = 0
        } else if let value = try? container.decode(Int.self) {
            stringValue = ""
            intValue = value
        } else {
            stringValue = ""
            intValue = 0
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if !stringValue.isEmpty {
            try? container.encode(stringValue)
        } else {
            try? container.encode(intValue)
        }
    }
}

/// 拥有 DefaultValue 协议和 Codable 协议的组合协议，目的是使 SingleValueDecodingContainer 的 decode 保证语法上正确！
typealias DefaultCodableValue = DefaultValue & Codable

/// 属性包装器
@propertyWrapper
struct Default<T: DefaultCodableValue> {
    var wrappedValue: T
}

/// 包装器遵守 Codable 协议，实现默认的 decoder 和 encoder 方法
extension Default: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.self)) ?? T.defaultValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

/// 对于 key 不存在或者意外输入不同类型时使用默认的值
extension KeyedDecodingContainer {
    func decode<T>(
        _ type: Default<T>.Type,
        forKey key: Key
    ) throws -> Default<T> where T: DefaultCodableValue {
        if let value = try decodeIfPresent(type, forKey: key) {
            return value
            
        } else {
            return Default(wrappedValue: T.defaultValue)
        }
    }
}

/// 数组相关的处理，含义和 KeyedDecodingContainer 的处理一样
extension UnkeyedDecodingContainer {
    mutating func decode<T>(
        _ type: Default<T>.Type
    ) throws -> Default<T> where T : DefaultCodableValue {
            try decodeIfPresent(type) ?? Default(wrappedValue: T.defaultValue)
    }
}

/// 默认值协议
protocol DefaultValue {
    static var defaultValue: Self { get }
}

/// 可以给某个可能为 nil 的类型遵守 DefaultValue，使其拥有 defaultValue
extension Bool: DefaultValue { static let defaultValue = false }

extension String: DefaultValue { static let defaultValue = "" }

extension Int: DefaultValue { static let defaultValue = 0 }

extension Double: DefaultValue { static let defaultValue: Double = 0.0 }

extension Float: DefaultValue { static let defaultValue: Float  = 0.0  }

extension Array: DefaultValue { static var defaultValue: Array<Element> { [] } }

extension Dictionary: DefaultValue { static var defaultValue: Dictionary<Key, Value> { [:] } }


//MARK: -  我进行的一些思考
/// 想要将Int和String展平为一种类型,然后来替换rank的类型,但是失败了,最后网上的一种思路成功了

protocol MixinTypeConvertible: Codable {}

//extension MixinTypeConvertible where Self == Int {}
//
//extension MixinTypeConvertible where Self == String {}
//
//extension MixinTypeConvertible where Self == Bool {}

extension Int: MixinTypeConvertible {}

extension String: MixinTypeConvertible {}

extension Bool: MixinTypeConvertible {}


@propertyWrapper
struct MixinType<Wrapper: MixinTypeConvertible>: Codable {
    var wrappedValue: Wrapper?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            wrappedValue = value as? Wrapper
        } else if let value = try? container.decode(Int.self) {
            wrappedValue = value as? Wrapper
        } else if let value = try? container.decode(Bool.self) {
            wrappedValue = value as? Wrapper
        } else {
            wrappedValue = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = wrappedValue as? String {
            try? container.encode(value)
        } else if let value = wrappedValue as? Int {
            try? container.encode(value)
        } else if let value = wrappedValue as? Bool {
            try? container.encode(value)
        } else {
            
        }
    }
}
