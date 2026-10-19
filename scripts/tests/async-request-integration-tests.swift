//
//  async-request-integration-tests.swift
//  RxStudy - 真实 Moya 请求取消集成测试
//
//  Created by Codex on 2026/10/19.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import Moya
import Alamofire

private enum Endpoint: TargetType {
    case probe
    var baseURL: URL { URL(string: "https://request-cancellation.invalid")! }
    var path: String { "/probe" }
    var method: Moya.Method { .get }
    var task: Moya.Task { .requestPlain }
    var headers: [String: String]? { nil }
}

private struct Payload: Codable { let value: Int }

/// 由真实 URLSession 启动和取消，既不访问网络，也不使用 Moya stub。
private final class CancellationProtocol: URLProtocol {
    static let started = DispatchSemaphore(value: 0)
    static let stopped = DispatchSemaphore(value: 0)
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() { Self.started.signal() }
    override func stopLoading() { Self.stopped.signal() }
}

@main
struct AsyncRequestIntegrationTests {
    static func main() async {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CancellationProtocol.self]
        let session = Session(configuration: configuration, startRequestsImmediately: false)
        let provider = MoyaProvider<Endpoint>(callbackQueue: DispatchQueue.global(), session: session)
        let task = _Concurrency.Task.detached {
            try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self)
        }
        precondition(CancellationProtocol.started.wait(timeout: .now() + 10) == .success)
        task.cancel()
        guard case .failure(let error) = await task.result, error is CancellationError else {
            preconditionFailure("真实 Moya 请求取消必须返回 CancellationError")
        }
        precondition(CancellationProtocol.stopped.wait(timeout: .now() + 5) == .success,
                     "Task 取消必须传递到真实 URLSession 的 stopLoading")
        print("真实 Moya/Alamofire 取消集成测试通过：URLSession 已调用 URLProtocol.stopLoading")
    }
}
