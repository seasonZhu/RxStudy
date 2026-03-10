//
//  APIService.swift
//  RxStudy - SwiftUIApp
//
//  网络服务基类
//  使用 async/await + Moya
//

import Foundation
import Moya

// MARK: - API 服务协议

/// API 服务基础协议
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

// MARK: - 响应模型

/// 标准 API 响应模型
struct StandardResponse<T: Codable>: Codable {
    let data: T?
    let errorCode: Int?
    let errorMsg: String?

    /// 判断请求是否成功
    var isSuccess: Bool {
        return errorCode == 0
    }

    /// 获取数据或抛出错误
    func getData() throws -> T {
        guard isSuccess, let data = data else {
            throw APIError.businessError(code: errorCode, message: errorMsg)
        }
        return data
    }
}

// MARK: - MoyaProvider 扩展

extension MoyaProvider {
    /// async/await 包装方法（内部使用）
    private func requestAsync(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: APIError.networkError(error))
                }
            }
        }
    }

    /// 带类型解析的 async/await 请求
    func requestDecoded<T: Codable>(
        _ target: Target,
        responseType: StandardResponse<T>.Type
    ) async throws -> T {
        let decoded = try await requestAsync(target).map(StandardResponse<T>.self)
        return try decoded.getData()
    }
}
