//
//  String+Extension.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

// MARK: - 字符串扩展

public extension String {

    /// 是否为空
    var isNotEmpty: Bool {
        return !isEmpty
    }

    /// 去除首尾空格
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 是否包含空格
    var containsWhitespace: Bool {
        return rangeOfCharacter(from: .whitespaces) != nil
    }

    /// 转换为Int
    var intValue: Int? {
        return Int(self)
    }

    /// 转换为Double
    var doubleValue: Double? {
        return Double(self)
    }

    /// 转换为Float
    var floatValue: Float? {
        return Float(self)
    }

    /// 转换为Bool
    var boolValue: Bool? {
        let lowercase = self.lowercased()
        if lowercase == "true" || lowercase == "1" {
            return true
        } else if lowercase == "false" || lowercase == "0" {
            return false
        }
        return nil
    }
}

// MARK: - HTML处理

public extension String {

    /// HTML实体字符替换
    var replaceHtmlEntities: String {
        return
            replacingOccurrences(of: "&ndash;", with: "–")
                .replacingOccurrences(of: "&mdash;", with: "—")
                .replacingOccurrences(of: "&lsquo;", with: "'")
                .replacingOccurrences(of: "&rsquo;", with: "'")
                .replacingOccurrences(of: "&sbquo;", with: "‚")
                .replacingOccurrences(of: "&ldquo;", with: "\"")
                .replacingOccurrences(of: "&rdquo;", with: "\"")
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

    /// 过滤HTML标签（简单版本）
    func filterHTML() -> String {
        let scanner = Scanner(string: self)
        var result = self
        var text: NSString?

        while !scanner.isAtEnd {
            scanner.scanUpTo("<", into: nil)
            scanner.scanUpTo(">", into: &text)
            if let tag = text {
                result = result.replacingOccurrences(of: "\(tag)>", with: "").replaceHtmlEntities
            }
        }

        return result
    }

    /// 转换为AttributedString（HTML）
    var attributedStringFromHTML: AttributedString? {
        guard let data = self.data(using: .unicode) else {
            return nil
        }

        do {
            let attributedString = try NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )

            // 设置颜色适配深色模式
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.playAndroidTitle,
                range: range
            )

            return AttributedString(attributedString)
        } catch {
            return nil
        }
    }
}

// MARK: - 验证

public extension String {

    /// 是否为有效的邮箱地址
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: self)
    }

    /// 是否为有效的手机号（中国）
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^1[3-9]\\d{9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: self)
    }

    /// 是否为有效的URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    /// 是否只包含数字
    var isNumeric: Bool {
        return Double(self) != nil
    }

    /// 是否只包含字母
    var isAlphabetic: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    /// 是否只包含字母和数字
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

// MARK: - 字符串处理

public extension String {

    /// 截取字符串
    /// - Parameter from: 起始索引
    func substring(from index: Int) -> String {
        guard index >= 0 && index < count else {
            return self
        }
        let startIndex = self.index(startIndex, offsetBy: index)
        return String(self[startIndex...])
    }

    /// 截取字符串
    /// - Parameter to: 结束索引
    func substring(to index: Int) -> String {
        guard index >= 0 && index <= count else {
            return self
        }
        let endIndex = self.index(startIndex, offsetBy: index)
        return String(self[..<endIndex])
    }

    /// 截取字符串
    /// - Parameter range: 范围
    func substring(range: Range<Int>) -> String {
        guard range.lowerBound >= 0 && range.upperBound <= count else {
            return self
        }
        let startIndex = self.index(startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: range.upperBound)
        return String(self[startIndex..<endIndex])
    }

    /// 按分隔符分割并去除空元素
    /// - Parameter separator: 分隔符
    func splitAndRemoveEmpty(separator: Character) -> [String] {
        return split(separator: separator)
            .map { String($0) }
            .filter { !$0.isEmpty }
    }

    /// 移除所有空格
    var removeWhitespace: String {
        return replacingOccurrences(of: " ", with: "")
    }

    /// 移除所有换行符
    var removeNewlines: String {
        return replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }
}

// MARK: - 字符串转Text

public extension String {

    /// 转换为Text
    var text: Text {
        Text(self)
    }

    /// 转换为Text（支持属性）
    func text(attributes: [NSAttributedString.Key: Any]) -> Text {
        if let attributedString = try? NSAttributedString(
            string: self,
            attributes: attributes
        ) {
            return Text(AttributedString(attributedString))
        }
        return Text(self)
    }
}

// MARK: - 本地化

public extension String {

    /// 本地化字符串
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// 带参数的本地化字符串
    /// - Parameter arguments: 参数
    func localized(arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - 预览

#if DEBUG
struct StringSwiftUIExtension_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 基础功能
            VStack(alignment: .leading, spacing: 10) {
                Text("基础功能").font(.headline)

                Text("是否为空: \("Hello".isNotEmpty)")
                Text("去除空格: \("  Hello  ".trimmed)")
                Text("转Int: \("123".intValue ?? 0)")
                Text("转Double: \("123.45".doubleValue ?? 0.0)")
            }
            .padding()
            .previewDisplayName("基础功能")

            // 验证
            VStack(alignment: .leading, spacing: 10) {
                Text("验证").font(.headline)

                Text("邮箱验证: \("test@example.com".isValidEmail)")
                Text("手机号验证: \("13800138000".isValidPhoneNumber)")
                Text("URL验证: \("https://www.apple.com".isValidURL)")
                Text("数字验证: \("12345".isNumeric)")
            }
            .padding()
            .previewDisplayName("验证")

            // HTML处理
            VStack(alignment: .leading, spacing: 10) {
                Text("HTML处理").font(.headline)

                Text("HTML标签过滤:")
                Text("<p>Hello<br>World</p>".filterHTML())
                    .font(.caption)

                Text("HTML实体替换:")
                Text("&lt;Hello&gt;".replaceHtmlEntities)
                    .font(.caption)
            }
            .padding()
            .previewDisplayName("HTML处理")
        }
    }
}
#endif
