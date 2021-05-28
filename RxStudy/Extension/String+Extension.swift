//
//  String+Extension.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

extension String {
//    var html: NSAttributedString {
//        return NSAttributedString(string: self, attributes: [.documentType: NSAttributedString.DocumentType.html])
//    }
    
    mutating func filterHTML() -> String? {
        let scanner = Scanner(string: self)
        var text: NSString?
        while !scanner.isAtEnd {
          scanner.scanUpTo("<", into: nil)
          scanner.scanUpTo(">", into: &text)
          self = self.replacingOccurrences(of: "\(text == nil ? "" : text!)>", with: "")
        }
        return self
    }
}
