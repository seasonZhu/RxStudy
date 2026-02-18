// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HttpRequest",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "HttpRequest",
            targets: ["HttpRequest"]
        )
    ],
    dependencies: [
        // Phase 2: 将在 Project.swift 中配置依赖
        // .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        // .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        // .package(path: "../RxStudyUtils"),
    ],
    targets: [
        .target(
            name: "HttpRequest",
            dependencies: [
                // .product(name: "RxSwift", package: "RxSwift"),
                // .product(name: "RxCocoa", package: "RxSwift"),
                // .product(name: "RxRelay", package: "RxSwift"),
                // .product(name: "Moya", package: "Moya"),
                // .product(name: "RxStudyUtils", package: "RxStudyUtils"),
            ],
            path: "Sources"
        )
    ]
)
