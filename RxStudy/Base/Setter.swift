//
//  Setter.swift
//  RxStudy
//
//  Created by dy on 2021/9/9.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

@dynamicMemberLookup
public struct Setter<This> {
    public let this: This
    
    public init(_ this: This) {
        self.this = this
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<This, Value>) -> ((Value) -> Setter<This>) {
        
        // 获取到真正的对象
        var that = this
        
        return { value in
            // 把 value 指派给 subject
            that[keyPath: keyPath] = value
            // 回传的类型是 Setter 而不是 Subject
            // 因为使用Setter来链式，而不是 Subject 本身
            return Setter(that)
        }
    }
}

/// A type that has setter extensions.
/// 仿写的rx
public protocol SetterCompatible {
    /// Extended type
    associatedtype This

    /// Setter extensions.
    static var setter: Setter<This>.Type { get set }

    /// Setter extensions.
    var setter: Setter<This> { get set }
}

extension SetterCompatible {
    /// Setter extensions.
    public static var setter: Setter<Self>.Type {
        get {
            return Setter<Self>.self
        }
        // swiftlint:disable:next unused_setter_value
        set {
            // this enables using Reactive to "mutate" base type
        }
    }

    /// Setter extensions.
    public var setter: Setter<Self> {
        get {
            return Setter(self)
        }
        // swiftlint:disable:next unused_setter_value
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}

import class Foundation.NSObject

/// Extend NSObject with `setter` proxy.
extension NSObject: SetterCompatible { }

let view: UIView =
    UIView()
    .setter
    .backgroundColor(.white)
    .alpha(0.5)
    .frame(CGRect(x: 0, y: 0, width: 100, height: 500))
    .this
