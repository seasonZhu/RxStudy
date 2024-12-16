//
//  Array+URLQueryItem.swift
//  RxStudy
//
//  Created by dy on 2024/12/16.
//  Copyright © 2024 season. All rights reserved.
//

import Foundation

extension Array where Element == URLQueryItem {
    var toDict: [String: String] {
        let dict = reduce(into: [:], { result, next in
            result[next.name] = next.value
        })
    
        return dict
    }
}
