import Foundation

/// WanAndroid 登录请求使用的 Cookie 头。
enum AccountCookie {
    static func header(username: String?, password: String?) -> String {
        guard let username, let password else { return "" }
        return "loginUserName=\(username);loginUserPassword=\(password)"
    }
}
