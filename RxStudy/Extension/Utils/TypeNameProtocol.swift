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
            //return className.replacingOccurrences(of: "\(nameSpace ?? "").", with: "")
            return ""
        }
    }
    
    static var classNameWithoutNamespace: String {
        if self is NSObject.Type {
            return className
        } else {
            //return className.replacingOccurrences(of: "\(nameSpace ?? "").", with: "")
            return ""
        }
    }
    
}

extension TypeNameProtocol where Self: AnyObject {
    /// 获取对象的内存地址(class类才有)
    var memoryAddress: String {
        return "<\(classNameWithoutNamespace): \(Unmanaged.passUnretained(self).toOpaque())>"
    }
}

extension NSObject: TypeNameProtocol {}

// MARK: - 测试使用

class Student {}

class Teacher: NSObject {}

extension Student: TypeNameProtocol {}

/// https://mp.weixin.qq.com/s/h17dwmKSCNLQdWHUe_pYDQ
@DebugDescription
struct Book {
    let title: String
    let author: String
    let pageCount: Int
}

extension Book: CustomDebugStringConvertible {
    var debugDescription: String {
        "《\(title)》- \(author) [\(pageCount)页]"
    }
}
