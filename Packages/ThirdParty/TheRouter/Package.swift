// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TheRouter",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "TheRouter",
            targets: ["TheRouter"]
        ),
    ],
    targets: [
        .target(
            name: "TheRouter",
            path: "Sources",
            sources: ["."],
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
            ]
        ),
    ]
)
