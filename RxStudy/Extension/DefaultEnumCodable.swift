//
//  DefaultEnumCodable.swift
//  RxStudy
//
//  Created by dy on 2023/10/13.
//  Copyright © 2023 season. All rights reserved.
//

import Foundation

/// https://github.com/line/line-sdk-ios-swift/blob/master/LineSDK/LineSDK/Networking/Model/CustomizeCoding/CodingExtension.swift

/// A data structure that can be parsed to a `RawRepresentable` type, with a default case to be used if the received
/// data cannot be represented by any value in the type.
protocol DefaultEnumCodable: RawRepresentable, Codable {
    /// The default value to use when the parsing fails due to the received data not being representable by any value
    /// in the type.
    static var defaultCase: Self { get }
}

/// The default implementation of `DefaultEnumCodable` when the `Self.RawValue` is decodable. It tries to parse a single
/// value in the decoder container and initialize `Self` with the value. If the decoded value is not convertible to
/// `Self`, it will be initialized as the `defaultCase`.
extension DefaultEnumCodable where Self.RawValue: Decodable {
    /// :nodoc:
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        self = Self.init(rawValue: rawValue) ?? Self.defaultCase
    }
}

enum SexEnum: String {
   case man
   case women
}

extension SexEnum: DefaultEnumCodable {
    static let defaultCase: SexEnum = .man
}
