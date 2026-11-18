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
import SVProgressHUD

private enum Endpoint: TargetType {
    case probe, hidden, businessError
    var baseURL: URL { URL(string: "https://request-cancellation.invalid")! }
    var path: String { "/probe" }
    var method: Moya.Method { .get }
    var task: Moya.Task { .requestPlain }
    var headers: [String: String]? { self == .hidden ? ["showLoading": "false"] : nil }
    var sampleData: Data { self == .businessError ? Data(#"{"errorMsg":"业务错误"}"#.utf8) : Data() }
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
    /// 同一真实 Provider 接缝覆盖发送前取消、并行请求和同步完成。
    @MainActor
    static func verifyLoadingLifecycle() async {
        var pending: [MoyaProvider<Endpoint>.RequestResultClosure] = []
        let provider = LoadingProvider<Endpoint>(requestClosure: { _, completion in
            pending.append(completion)
        })
        let first = provider.request(.probe) { _ in }
        let second = provider.request(.probe) { _ in }
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始"])
        first.cancel()
        first.cancel()
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始"], "单个取消不能结束其他请求的加载")
        second.cancel()
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始", "结束"])
        let request = URLRequest(url: URL(string: "https://request-cancellation.invalid/probe")!)
        for completion in pending { completion(.success(request)) }
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始", "结束"], "发送前取消的迟到回调必须幂等")

        SVProgressHUD.events = []
        let success = LoadingProvider<Endpoint>(stubClosure: MoyaProvider.immediatelyStub)
        let completed = success.request(.probe) { result in
            guard case .success = result else { preconditionFailure("stub 必须成功") }
        }
        completed.cancel()
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始", "结束"], "同步完成后取消不能重复收尾")

        SVProgressHUD.events = []
        let failure = LoadingProvider<Endpoint>(requestClosure: { _, completion in
            completion(.failure(.underlying(URLError(.notConnectedToInternet), nil)))
        })
        _ = failure.request(.probe) { result in
            guard case .failure = result else { preconditionFailure("请求构造失败必须保留") }
        }
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始", "结束"], "发送前失败同样必须收尾")
        SVProgressHUD.events = []
        _ = success.request(.hidden) { _ in }
        await flushHUD()
        precondition(SVProgressHUD.events.isEmpty, "显式关闭 loading 的请求不能触碰 HUD")

        let business = LoadingProvider<Endpoint>(stubClosure: MoyaProvider.immediatelyStub,
                                                  plugins: [ResponseInterceptorPlugin()])
        _ = business.request(.businessError) { result in
            guard case .failure(.statusCode) = result else { preconditionFailure("必须保留业务失败语义") }
        }
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始", "结束", "业务错误"], "错误提示必须在加载收尾后展示")
        SVProgressHUD.events = []
        pending = []
        let failed = provider.request(.probe) { _ in }
        let remaining = provider.request(.probe) { _ in }
        pending[0](.failure(.statusCode(Response(statusCode: 200,
                                               data: Endpoint.businessError.sampleData))))
        remaining.cancel()
        await flushHUD()
        precondition(SVProgressHUD.events == ["开始", "结束", "业务错误"],
                     "并行请求中先失败的提示必须在最后一个请求收尾后展示")
        failed.cancel()
        print("加载生命周期集成测试通过：并行、成功、失败、发送前取消和重复取消")
    }

    static func waitForStart() -> Bool {
        CancellationProtocol.started.wait(timeout: .now() + 10) == .success
    }

    @MainActor
    static func flushHUD() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    @MainActor
    static func main() async {
        await verifyLoadingLifecycle()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CancellationProtocol.self]
        let session = Session(configuration: configuration, startRequestsImmediately: false)
        let provider = LoadingProvider<Endpoint>(callbackQueue: DispatchQueue.global(), session: session)
        let task = _Concurrency.Task { @MainActor in
            try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self)
        }
        let started = await _Concurrency.Task.detached {
            waitForStart()
        }.value
        precondition(started)
        task.cancel()
        guard case .failure(let error) = await task.result, error is CancellationError else {
            preconditionFailure("真实 Moya 请求取消必须返回 CancellationError")
        }
        precondition(CancellationProtocol.stopped.wait(timeout: .now() + 5) == .success,
                     "Task 取消必须传递到真实 URLSession 的 stopLoading")
        print("真实 Moya/Alamofire 取消集成测试通过：URLSession 已调用 URLProtocol.stopLoading")
    }
}
