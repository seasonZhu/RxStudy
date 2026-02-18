//
//  AnyConvertible.swift
//  RxStudy
//
//  Created by dy on 2025/6/3.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

/**
 看Swift周报写的类
 https://mp.weixin.qq.com/s/GdQE-ajZRbr3r_aPrHf2Yg
 
 讨论关于 type(of: s.foo) 的陷阱[12]该帖子指出一个关于 type(of:) 函数在访问实例属性时可能引发误解的语义陷阱。开发者可能直觉地认为 type(of: s.foo) 会返回属性 foo 的运行时类型，尤其当 foo 是协议类型或有类型擦除时。但实际上，它返回的是编译时静态类型，这可能导致结果与预期不符。示例代码：protocol P {}
 struct S: P {}

 struct Wrapper {
   var value: P
 }

 let s = Wrapper(value: S())
 print(type(of: s.value))  // 输出 P，而不是 S
 虽然 s.value 在运行时中实际保存的是 S 类型的实例，但 type(of:) 返回的是 P，即属性声明时的静态类型。这是因为 Swift 中 type(of:) 是泛型函数，它的类型参数是在编译时推导的。讨论指出该行为虽符合语言设计，但易误导开发者。若想获取实际底层类型，应显式使用 Swift.type(of:) 和 any 关键字或结合类型转换，例如：print(type(of: s.value as Any))  // 输出 S
 社区讨论建议可能通过改进文档或静态警告提升此类易错用法的可发现性，避免初学者或跨语言用户踩坑。
 
 */

protocol AnyConvertible {
    func asAny() -> Any
}

extension AnyConvertible {
    func asAny() -> Any {
        self as Any
    }
}

extension NSObject: AnyConvertible {}
