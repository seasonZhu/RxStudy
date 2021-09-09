//
//  Setter.swift
//  RxStudy
//
//  Created by dy on 2021/9/9.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

@dynamicMemberLookup
public struct Setter<Subject> {
    public let subject: Subject
    
    public init(_ subject: Subject) {
        self.subject = subject
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Subject, Value>) -> ((Value) -> Setter<Subject>) {
        
        // 获取到真正的对象
        var subject = self.subject
        
        return { value in
            // 把 value 指派给 subject
            subject[keyPath: keyPath] = value
            // 回传的类型是 Setter 而不是 Subject
            // 因为使用Setter来链式，而不是 Subject 本身
            return Setter(subject)
        }
    }
}

/// A type that has setter extensions.
/// 仿写的rx
public protocol SetterCompatible {
    /// Extended type
    associatedtype Base

    /// Setter extensions.
    static var setter: Setter<Base>.Type { get set }

    /// Setter extensions.
    var setter: Setter<Base> { get set }
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
    .subject
