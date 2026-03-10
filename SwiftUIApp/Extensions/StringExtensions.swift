//
//  StringExtensions.swift
//  SwiftUIStudy
//
//  Created by dy on 2026/3/10.
//  Copyright © 2026 com.lostsakura. All rights reserved.
//

import Foundation

// MARK: - HTML 字符串扩展
extension String {
  var swiftUIReplaceHtmlElement: String {
      // 先使用正则表达式移除所有 HTML 标签
      let result = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

      // 再替换 HTML 实体字符
      return result
          .replacingOccurrences(of: "&ndash;", with: "–")
          .replacingOccurrences(of: "&mdash;", with: "—")
          .replacingOccurrences(of: "&lsquo;", with: "'")
          .replacingOccurrences(of: "&rsquo;", with: "'")
          .replacingOccurrences(of: "&sbquo;", with: "‚")
          .replacingOccurrences(of: "&ldquo;", with: "\u{201C}")
          .replacingOccurrences(of: "&rdquo;", with: "\u{201D}")
          .replacingOccurrences(of: "&bdquo;", with: "„")
          .replacingOccurrences(of: "&permil;", with: "‰")
          .replacingOccurrences(of: "&lsaquo;", with: "‹")
          .replacingOccurrences(of: "&rsaquo;", with: "›")
          .replacingOccurrences(of: "&euro;", with: "€")
          .replacingOccurrences(of: "&lt;", with: "<")
          .replacingOccurrences(of: "&gt;", with: ">")
          .replacingOccurrences(of: "&nbsp;", with: " ")
          .replacingOccurrences(of: "&amp;", with: "&")
          .replacingOccurrences(of: "&quot;", with: "\"")
          .replacingOccurrences(of: "&yen;", with: "¥")
    }
}
