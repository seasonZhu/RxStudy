//
//  APIService.swift
//  RxStudy - SwiftUIStudy
//
//  网络服务基类
//  使用 async/await + Moya
//

import Foundation
import Moya

// MARK: - API 服务协议

/// API 服务基础协议
@MainActor
protocol APIService {
    associatedtype Target: TargetType

    var provider: MoyaProvider<Target> { get }
}

// MARK: - 通用 API 错误

enum APIError: LocalizedError {
    case networkError(MoyaError)
    case parsingError(Error)
    case businessError(code: Int?, message: String?)
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .parsingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .businessError(_, let message):
            return message ?? "业务错误"
        case .unknown:
            return "未知错误"
        }
    }
}

// MARK: - 响应模型扩展

extension BaseModel {
    /// 获取数据或抛出错误
    public func getData() throws -> T {
        guard isSuccess, let data = data else {
            throw APIError.businessError(code: errorCode, message: errorMsg)
        }
        return data
    }
}

/// 取消处理器与 Moya 回调可能来自不同线程，所有共享状态都由锁保护。
/// 不在持锁期间取消请求或恢复 continuation，允许 cancel 同步触发回调。
private final class AsyncRequestState<Value: Sendable>: @unchecked Sendable {
    private enum Status { case pending, completed, cancelled }
    private let lock = NSLock()
    private var status = Status.pending
    private var continuation: CheckedContinuation<Value, Error>?
    private var cancellable: Cancellable?

    func install(_ continuation: CheckedContinuation<Value, Error>) -> Bool {
        lock.lock()
        if status == .cancelled {
            lock.unlock()
            continuation.resume(throwing: CancellationError())
            return false
        }
        self.continuation = continuation
        lock.unlock()
        return true
    }

    func install(_ cancellable: Cancellable) {
        lock.lock()
        let shouldCancel = status == .cancelled
        if status == .pending { self.cancellable = cancellable }
        lock.unlock()
        // 取消可能发生在 request 返回句柄之前，此时补做底层取消。
        if shouldCancel { cancellable.cancel() }
    }

    func finish(_ result: Result<Value, Error>) {
        lock.lock()
        guard status == .pending else {
            lock.unlock()
            return
        }
        status = .completed
        let continuation = self.continuation
        self.continuation = nil
        cancellable = nil
        lock.unlock()
        continuation?.resume(with: result)
    }

    func cancel() {
        lock.lock()
        guard status == .pending else {
            lock.unlock()
            return
        }
        status = .cancelled
        let continuation = self.continuation
        let cancellable = self.cancellable
        self.continuation = nil
        self.cancellable = nil
        lock.unlock()
        cancellable?.cancel()
        continuation?.resume(throwing: CancellationError())
    }
}

// MARK: - MoyaProvider 扩展

extension MoyaProvider {
    /// 将任务取消传递给底层 Moya 请求，取消不包装为网络错误。
    @MainActor
    private func requestAsync<T: Codable & Sendable>(_ target: Target, responseType: BaseModel<T>.Type) async throws -> T {
        try _Concurrency.Task.checkCancellation()
        let state = AsyncRequestState<T>()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard state.install(continuation) else { return }
                let cancellable = self.request(target) { result in
                    let decoded = result.mapError { APIError.networkError($0) }.flatMap { response in
                        Result { try response.map(responseType).getData() }
                    }
                    state.finish(decoded)
                }
                state.install(cancellable)
            }
        } onCancel: {
            state.cancel()
        }
    }

    /// 带类型解析的 async/await 请求
    @MainActor
    func requestDecoded<T: Codable & Sendable>(
        _ target: Target,
        responseType: BaseModel<T>.Type
    ) async throws -> T {
        do {
            let data = try await requestAsync(target, responseType: responseType)
            try _Concurrency.Task.checkCancellation()
            return data
        } catch {
            // 失败回调可能先于取消到达，但调用任务已经取消时仍按取消处理。
            try _Concurrency.Task.checkCancellation()
            throw error
        }
    }
}
