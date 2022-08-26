//
//  PropertyWrapper.swift
//  RxStudy
//
//  Created by dy on 2022/8/26.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

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

@propertyWrapper
struct IntToStringFactory {
    
    var wrappedValue: Int

    var projectedValue: String { String(wrappedValue) }

}


@propertyWrapper
struct FunctionFactory<Input, Output> {
    
    var wrappedValue: Input
    
    let function: (Input) -> Output

    var projectedValue: Output { function(wrappedValue) }
}

@propertyWrapper
struct StringFactory {
    var wrappedValue: Int
    
    var aNum: Int

    var projectedValue: String { String("\(wrappedValue * aNum)") }
}
