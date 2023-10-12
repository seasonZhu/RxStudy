//
//  TypeNameProtocol.swift
//  RxStudy
//
//  Created by dy on 2022/7/1.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation


protocol TypeNameProtocol {
    
    var className: String { get }
    
    static var className: String { get }
    
}

extension TypeNameProtocol {
    
    var className: String { String(describing: self) }
    
    static var className: String { String(describing: self) }
    
    /// 用于非继承NSObject的class\enum\struct去掉命名空间的名称打印
    var classNameWithoutNamespace: String {
        
        if self is NSObject {
            return className
        } else {
            return className.replacingOccurrences(of: "\(nameSpace ?? "").", with: "")
        }
    }
    
    static var classNameWithoutNamespace: String {
        if self is NSObject.Type {
            return className
        } else {
            return String(className.split(separator: ".").last!)
        }
    }
    
}

extension TypeNameProtocol where Self: AnyObject {
    /// 获取对象的内存地址(class类才有)
    var memoryAddress: String {
        return "<\(classNameWithoutNamespace): \(Unmanaged.passUnretained(self).toOpaque())>"
    }
}

class Student {}

class Teacher: NSObject {}

extension Student: TypeNameProtocol {}

extension NSObject: TypeNameProtocol {}
