// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HUD",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "HUD",
            targets: ["HUD"]
        )
    ],
    dependencies: [
        // Phase 2: 将在 Project.swift 中配置 SVProgressHUD 依赖
        // 在此之前，HUD 的实现可能需要从 RxStudy 主项目中提取
    ],
    targets: [
        .target(
            name: "HUD",
            dependencies: [],
            path: "Sources"
        )
    ]
)
