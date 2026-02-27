// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        productTypes: [
            "RxSwift": .staticFramework,
            "RxCocoa": .staticFramework,
            "RxRelay": .staticFramework,
            "RxDataSources": .staticFramework,
            "RxGesture": .staticFramework,
            "RxTheme": .staticFramework,
            "RxSwiftExt": .staticFramework,
            "RxOptional": .staticFramework,
            "RxBlocking": .staticFramework,
            "RxMoya": .staticFramework,
            "Moya": .staticFramework,
            "Alamofire": .staticFramework,
            "Kingfisher": .staticFramework,
            "SnapKit": .staticFramework,
            "KeychainAccess": .staticFramework,
            "CocoaLumberjack": .staticFramework,
            "MarqueeLabel": .staticFramework,
            "SFSafeSymbols": .staticFramework,
            "ZipArchive": .staticFramework,
            "WebUI": .staticFramework,
            "PagerTabStripView": .staticFramework
        ]
    )
#endif

let package = Package(
    name: "RxStudy",
    dependencies: [
        // ========== RxSwift 生态 ==========
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "4.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxTheme.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxOptional.git", from: "5.0.0"),

        // ========== 网络层 ==========
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),

        // ========== 图片加载 ==========
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),

        // ========== 布局 ==========
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),

        // ========== 工具 ==========
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0"),
        .package(url: "https://github.com/cbpowell/MarqueeLabel.git", from: "4.0.0"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "2.1.3"),
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "2.5.0"),

        // ========== WebView ==========
        .package(url: "https://github.com/cybozu/WebUI.git", from: "4.0.0"),

        // ========== TabView 组件 ==========
        .package(url: "https://github.com/xmartlabs/PagerTabStripView.git", from: "3.0.0"),
    ]
)
