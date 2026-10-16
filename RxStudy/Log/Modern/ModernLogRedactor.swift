import Foundation

/// 先脱敏后限长；无法结构化脱敏的文本不输出原文。
enum ModernLogRedactor {
    static let bodyLimit = 64 * 1024

    private static func isSensitive(_ key: String) -> Bool {
        let normalized = key.lowercased().filter { $0.isLetter || $0.isNumber }
        return ["authorization", "cookie", "token", "password", "passwd", "pwd", "secret",
                "credential", "phone", "mobile", "email", "session", "apikey", "accesskey",
                "idcard", "username", "account", "姓名", "身份证", "手机号", "密码"]
            .contains { normalized.contains($0) }
    }

    private static func text(_ value: String) -> String {
        var result = value
        let patterns = [
            #"(?i)bearer\s+[^\s"&,]+"#,
            #"(?<![0-9])1[3-9][0-9]{9}(?![0-9])"#,
            #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        ]
        for pattern in patterns {
            result = result.replacingOccurrences(of: pattern, with: "[已脱敏]", options: .regularExpression)
        }
        return result
    }

    private static func redacted(_ object: Any) -> Any {
        if let dictionary = object as? [String: Any] {
            return dictionary.reduce(into: [String: Any]()) { result, entry in
                result[entry.key] = isSensitive(entry.key) ? "[已脱敏]" : redacted(entry.value)
            }
        }
        if let array = object as? [Any] { return array.map { redacted($0) } }
        if let string = object as? String { return text(string) }
        return object
    }

    static func url(_ url: URL?) -> String {
        guard let url, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return "未知" }
        components.user = nil
        components.password = nil
        components.fragment = nil
        components.path = text(components.path)
        components.queryItems = components.queryItems?.map {
            URLQueryItem(name: $0.name, value: isSensitive($0.name) ? "[已脱敏]" : $0.value.map(text))
        }
        return bounded(text(components.string ?? "未知"), limit: 2048)
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }

    static func headers(_ headers: [String: String]) -> String {
        // 仅保留排障需要的无凭据头；未知自定义头同样隐藏。
        let allowed = ["content-type", "content-length", "accept", "accept-encoding"]
        let safe = headers.mapValues { _ in "[已脱敏]" }.merging(
            headers.filter { allowed.contains($0.key.lowercased()) }.mapValues(text),
            uniquingKeysWith: { _, value in value })
        return bounded(json(safe), limit: bodyLimit)
    }

    static func body(_ data: Data?, contentType: String?) -> String {
        guard let data, !data.isEmpty else { return "无正文" }
        let mediaType = contentType?.lowercased().split(separator: ";").first.map(String.init)
        let isBinary = mediaType.map {
            !$0.hasPrefix("text/") && !$0.contains("json")
                && !$0.contains("x-www-form-urlencoded") && !$0.contains("xml")
        } ?? false
        if isBinary {
            return "[二进制正文：类型=\(bounded(text(mediaType ?? "未知"), limit: 256))，大小=\(data.count) 字节]"
        }
        guard data.count <= bodyLimit else {
            // 不截取原始前缀，避免把截断的 JSON 或表单当作安全文本泄露。
            return "[已截断：原始大小=\(data.count) 字节，超过 64 KiB，省略正文]"
        }
        if let object = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) {
            return bounded(json(redacted(object)), limit: bodyLimit)
        }
        if contentType?.lowercased().contains("application/x-www-form-urlencoded") == true,
           let form = String(data: data, encoding: .utf8),
           let items = URLComponents(string: "?" + form)?.queryItems {
            let fields = items.map { item -> [String: String] in
                let name = item.name.replacingOccurrences(of: "+", with: " ")
                let value = item.value?.replacingOccurrences(of: "+", with: " ") ?? ""
                return ["字段": name, "值": isSensitive(name) ? "[已脱敏]" : text(value)]
            }
            return bounded(json(fields), limit: bodyLimit)
        }
        return "[未记录正文：类型=\(text(contentType ?? "未知"))，大小=\(data.count) 字节]"
    }

    private static func json(_ value: Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .fragmentsAllowed]),
              let string = String(data: data, encoding: .utf8) else { return "[无法编码]" }
        return string
    }

    private static func bounded(_ string: String, limit: Int) -> String {
        guard string.utf8.count > limit else { return string }
        let suffix = "[已截断：原始大小=\(string.utf8.count) 字节]"
        let prefix = String(decoding: string.utf8.prefix(limit - suffix.utf8.count - 3), as: UTF8.self)
        return prefix + suffix
    }
}
