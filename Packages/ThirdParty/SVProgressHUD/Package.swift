// swift-tools-version: 5.9
// This package is not used as a standalone SPM package
// Source files are directly included in the main project
import PackageDescription

let package = Package(
    name: "SVProgressHUDSPM",
    platforms: [.iOS(.v13)],
    targets: [
        .target(
            name: "SVProgressHUDSPM",
            sources: ["Sources/**"],
            publicHeadersPath: "Sources/include"
        )
    ]
)
