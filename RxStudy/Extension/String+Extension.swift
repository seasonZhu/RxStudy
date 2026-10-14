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
    
    var replaceHtmlElement: String {
        return
            replacingOccurrences(of: "&ndash;", with: "–")
            .replacingOccurrences(of: "&mdash;", with: "—")
            .replacingOccurrences(of: "&lsquo;", with: "‘")
            .replacingOccurrences(of: "&rsquo;", with: "’")
            .replacingOccurrences(of: "&sbquo;", with: "‚")
            .replacingOccurrences(of: "&ldquo;", with: "“")
            .replacingOccurrences(of: "&rdquo;", with: "”")
            .replacingOccurrences(of: "&bdquo;", with: "„")
            .replacingOccurrences(of: "&permil;", with: "‰")
            .replacingOccurrences(of: "&lsaquo;", with: "‹")
            .replacingOccurrences(of: "&rsaquo;", with: "›")
            .replacingOccurrences(of: "&euro;", with: "€")
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "</p>", with: "")
            .replacingOccurrences(of: "</br>", with: "\n")
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&yen;", with: "¥")
      }
}

import RegexBuilder
