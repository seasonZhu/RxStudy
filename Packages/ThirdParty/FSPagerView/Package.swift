// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FSPagerView",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "FSPagerView",
            targets: ["FSPagerView"]
        ),
    ],
    targets: [
        .target(
            name: "FSPagerView",
            path: "Sources",
            sources: [
                ".",  // 包含当前目录下的所有 Swift 和 Objective-C 文件
            ],
            publicHeadersPath: "include"  // 公开头文件路径
        ),
    ]
)
