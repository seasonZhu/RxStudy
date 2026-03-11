//
//  String+Extension.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

extension String {
    var html: NSAttributedString {
        guard let data = data(using: .unicode) else {
            return NSAttributedString(string: replaceHtmlElement, attributes: [NSAttributedString.Key.foregroundColor: UIColor.playAndroidTitle])
        }
        
        guard let mutableAttributedString = try? NSMutableAttributedString(data: data,
                                                             options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                                             documentAttributes: nil) else {
            return NSAttributedString(string: replaceHtmlElement, attributes: [NSAttributedString.Key.foregroundColor: UIColor.playAndroidTitle])
        }

        mutableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.playAndroidTitle], range: (mutableAttributedString.string as NSString).range(of: mutableAttributedString.string))
        
        return NSAttributedString(attributedString: mutableAttributedString)
    }
    
    mutating func filterHTML() -> String? {
        let scanner = Scanner(string: self)
        var text: NSString?
        while !scanner.isAtEnd {
            /// 这方法过期了,但是不知道用什么新方法去代替
            scanner.scanUpTo("<", into: nil)
            scanner.scanUpTo(">", into: &text)
            self = replacingOccurrences(of: "\(text == nil ? "" : text!)>", with: "").replaceHtmlElement
        }
        return self
    }
}

import RegexBuilder
