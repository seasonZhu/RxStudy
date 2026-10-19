#!/usr/bin/env python3
"""以可控传输替身运行真实 SwiftUI 会话、SwiftUI 登录及响应解码，不启动模拟器。"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCES = [
    "Shared/Business/AccountCookie.swift",
    "SwiftUIStudy/Network/AccountSession.swift",
    "Shared/Models/BaseModel.swift",
    "Shared/API/Api.swift",
    "SwiftUIStudy/Models/CommonModels.swift",
    "SwiftUIStudy/Models/EmptyModel.swift",
    "SwiftUIStudy/Network/APIService.swift",
    "SwiftUIStudy/Network/AccountAPIService.swift",
    "scripts/tests/account-session-tests.swift",
]
# 替身只提供 Moya 的传输入口；认证、失败分类、状态和解码均执行应用源码。
MOYA_TRANSPORT = """
import Foundation
public enum Method { case get, post }
public enum ValidationType { case successCodes }
public enum URLEncoding { case `default` }
public enum Task {
    case requestPlain
    case requestParameters(parameters: [String: String], encoding: URLEncoding)
}
public protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: Method { get }
    var validationType: ValidationType { get }
    var task: Task { get }
    var headers: [String: String]? { get }
}
public struct Response {
    public let data: Data
    public init(data: Data) { self.data = data }
    public func map<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
}
public enum MoyaError: LocalizedError {
    case underlying(Error)
    public var errorDescription: String? {
        switch self { case .underlying(let error): return error.localizedDescription }
    }
}
public protocol Cancellable {
    var isCancelled: Bool { get }
    func cancel()
}
public final class NoopCancellable: Cancellable {
    public var isCancelled = false
    public init() {}
    public func cancel() { isCancelled = true }
}
public final class MoyaProvider<Target: TargetType> {
    private let handler: (Target, @escaping (Result<Response, MoyaError>) -> Void) -> Void
    private let makeCancellable: () -> Cancellable
    public init(makeCancellable: @escaping () -> Cancellable = { NoopCancellable() }, handler: @escaping (Target, @escaping (Result<Response, MoyaError>) -> Void) -> Void = {
        _, completion in completion(.failure(.underlying(URLError(.unsupportedURL))))
    }) { self.handler = handler; self.makeCancellable = makeCancellable }
    @discardableResult
    public func request(_ target: Target, completion: @escaping (Result<Response, MoyaError>) -> Void) -> Cancellable {
        let token = makeCancellable()
        handler(target, completion)
        return token
    }
}
"""


def main():
    with tempfile.TemporaryDirectory(prefix="rxstudy-session-") as directory:
        temporary = Path(directory)
        transport = temporary / "Moya.swift"
        transport.write_text(MOYA_TRANSPORT)
        compiler = ["xcrun", "swiftc", "-swift-version", "5", "-module-cache-path", str(temporary / "ModuleCache")]
        subprocess.run(compiler + ["-emit-library", "-emit-module", "-module-name", "Moya", str(transport),
                                   "-emit-module-path", str(temporary / "Moya.swiftmodule"),
                                   "-o", str(temporary / "libMoya.dylib")], check=True)
        executable = temporary / "account-session-tests"
        subprocess.run(compiler + ["-parse-as-library", "-I", str(temporary), "-L", str(temporary), "-lMoya",
                                   "-Xlinker", "-rpath", "-Xlinker", str(temporary)] +
                       [str(ROOT / source) for source in SOURCES] + ["-o", str(executable)], check=True)
        subprocess.run([str(executable)], check=True, timeout=45)


if __name__ == "__main__":
    main()
