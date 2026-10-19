//
//  async-request-tests.swift
//  RxStudy - SwiftUI 请求取消测试
//
//  Created by Codex on 2026/10/19.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import Moya

private struct Payload: Codable { let value: Int }
private enum Endpoint: TargetType {
    case probe
    var baseURL: URL { URL(string: "https://test.invalid")! }
    var path: String { "/probe" }
    var method: Moya.Method { .get }
    var validationType: ValidationType { .successCodes }
    var task: Moya.Task { .requestPlain }
    var headers: [String: String]? { nil }
}

private final class Token: Cancellable {
    private let lock = NSLock()
    private var count = 0
    var onCancel: (() -> Void)?
    var isCancelled: Bool { cancellations > 0 }
    var cancellations: Int { lock.lock(); defer { lock.unlock() }; return count }
    func cancel() {
        lock.lock()
        count += 1
        lock.unlock()
        onCancel?()
    }
}

/// 回调槽由锁保护，信号量仅用于协调测试时序。
private final class Probe: @unchecked Sendable {
    let started = DispatchSemaphore(value: 0)
    let returnHandle = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var completion: ((Result<Response, MoyaError>) -> Void)?
    var reply: (Result<Response, MoyaError>) -> Void {
        lock.lock(); defer { lock.unlock() }
        return completion!
    }
    func capture(_ completion: @escaping (Result<Response, MoyaError>) -> Void) {
        lock.lock()
        self.completion = completion
        lock.unlock()
        started.signal()
    }
}

@main
struct AsyncRequestTests {
    private static let response = Response(data: Data("{\"errorCode\":0,\"data\":{\"value\":7}}".utf8))

    static func main() async throws {
        try await testNormalCompletion()
        try await testAlreadyCancelled()
        try await testCancellationWithoutCallback()
        try await testCancellationBeforeHandle()
        try await testSynchronousCancelCallback()
        try await testFailureBeforeCancellation()
        try await testConcurrentCompletion()
        print("请求取消测试通过：正常响应、错误保留、预先取消、无回调取消、晚返回句柄、同步回调、重复回调和并发竞态")
    }

    private static func expectCancellation<T>(_ result: Result<T, Error>) {
        guard case .failure(let error) = result, error is CancellationError else {
            preconditionFailure("取消必须返回 CancellationError")
        }
    }

    private static func wait(_ semaphore: DispatchSemaphore) {
        precondition(semaphore.wait(timeout: .now() + 5) == .success, "测试请求未按期执行")
    }

    private static func testNormalCompletion() async throws {
        let token = Token()
        let provider = MoyaProvider<Endpoint>(makeCancellable: { token }, handler: { _, completion in
            completion(.success(response))
            completion(.failure(.underlying(URLError(.timedOut))))
        })
        let payload = try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self)
        precondition(payload.value == 7 && token.cancellations == 0, "同步完成不能误取消返回的句柄")
        let failing = MoyaProvider<Endpoint>(handler: { _, completion in
            completion(.failure(.underlying(URLError(.timedOut))))
        })
        do {
            _ = try await failing.requestDecoded(.probe, responseType: BaseModel<Payload>.self)
            preconditionFailure("网络错误不能成功")
        } catch APIError.networkError { } catch { preconditionFailure("非取消错误应保持网络错误分类") }
        let rejected = MoyaProvider<Endpoint>(handler: { _, completion in
            completion(.success(Response(data: Data("{\"errorCode\":-1,\"errorMsg\":\"业务拒绝\"}".utf8))))
        })
        do {
            _ = try await rejected.requestDecoded(.probe, responseType: BaseModel<Payload>.self)
            preconditionFailure("业务错误不能成功")
        } catch APIError.businessError { } catch { preconditionFailure("业务错误分类必须保留") }
    }

    private static func testAlreadyCancelled() async throws {
        let provider = MoyaProvider<Endpoint>(handler: { _, _ in preconditionFailure("已取消任务不能创建请求") })
        let task = _Concurrency.Task.detached {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self)
        }
        expectCancellation(await task.result)
    }

    private static func testCancellationWithoutCallback() async throws {
        let probe = Probe()
        let token = Token()
        let provider = MoyaProvider<Endpoint>(makeCancellable: { token }, handler: { _, completion in probe.capture(completion) })
        let task = _Concurrency.Task.detached { try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self) }
        wait(probe.started)
        task.cancel()
        task.cancel()
        expectCancellation(await task.result)
        precondition(token.cancellations == 1, "取消无需等待底层回调，重复取消也只传递一次")
        probe.reply(.success(response))
        probe.reply(.failure(.underlying(URLError(.cancelled))))
    }

    private static func testCancellationBeforeHandle() async throws {
        let probe = Probe()
        let token = Token()
        let provider = MoyaProvider<Endpoint>(makeCancellable: { token }, handler: { _, completion in
            probe.capture(completion)
            wait(probe.returnHandle)
        })
        let task = _Concurrency.Task.detached { try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self) }
        wait(probe.started)
        task.cancel()
        precondition(token.cancellations == 0, "句柄尚未返回")
        probe.returnHandle.signal()
        expectCancellation(await task.result)
        precondition(token.cancellations == 1)
        probe.reply(.success(response))
    }

    private static func testSynchronousCancelCallback() async throws {
        let probe = Probe()
        let token = Token()
        token.onCancel = { probe.reply(.failure(.underlying(URLError(.cancelled)))) }
        let provider = MoyaProvider<Endpoint>(makeCancellable: { token }, handler: { _, completion in probe.capture(completion) })
        let task = _Concurrency.Task.detached { try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self) }
        wait(probe.started)
        task.cancel()
        expectCancellation(await task.result)
        precondition(token.cancellations == 1, "同步取消回调不能死锁或重复结束")
    }

    private static func testFailureBeforeCancellation() async throws {
        let probe = Probe()
        let token = Token()
        let provider = MoyaProvider<Endpoint>(makeCancellable: { token }, handler: { _, completion in
            completion(.failure(.underlying(URLError(.timedOut))))
            probe.capture(completion)
            wait(probe.returnHandle)
        })
        let task = _Concurrency.Task.detached { try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self) }
        wait(probe.started)
        task.cancel()
        probe.returnHandle.signal()
        expectCancellation(await task.result)
        precondition(token.cancellations == 0, "已完成的底层失败请求无需再次取消")
    }

    private static func testConcurrentCompletion() async throws {
        for _ in 0..<100 {
            let probe = Probe()
            let token = Token()
            let provider = MoyaProvider<Endpoint>(makeCancellable: { token }, handler: { _, completion in probe.capture(completion) })
            let task = _Concurrency.Task.detached { try await provider.requestDecoded(.probe, responseType: BaseModel<Payload>.self) }
            wait(probe.started)
            DispatchQueue.concurrentPerform(iterations: 2) { index in
                if index == 0 { task.cancel() } else { probe.reply(.success(response)) }
            }
            switch await task.result {
            case .success(let payload): precondition(payload.value == 7)
            case .failure(let error): precondition(error is CancellationError)
            }
            precondition(token.cancellations <= 1)
            probe.reply(.success(response))
        }
    }
}
