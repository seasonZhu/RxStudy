// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RxStudyUtils",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "RxStudyUtils",
            targets: ["RxStudyUtils"]
        )
    ],
    dependencies: [
        // Phase 2: 将在 Project.swift 中配置 RxSwift 依赖
        // .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0")
    ],
    targets: [
        .target(
            name: "RxStudyUtils",
            dependencies: [
                // .product(name: "RxSwift", package: "RxSwift"),
                // .product(name: "RxCocoa", package: "RxSwift"),
                // .product(name: "RxRelay", package: "RxSwift"),
            ],
            path: "Sources"
        )
    ]
)
