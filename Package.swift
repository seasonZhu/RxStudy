// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RxStudyDeps",
    platforms: [.iOS(.v17)],
    dependencies: [
        // ========== RxSwift 生态 ==========
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "4.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxTheme.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxOptional.git", from: "5.0.0"),
        // RxViewController 移除 - 与 RxSwift 6.x 不兼容
        // .package(url: "https://github.com/devxoul/RxViewController.git", from: "1.0.0"),

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

        // ========== 日志与调试 ==========
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "2.5.0"),

        // ========== 本地 Package ==========
        .package(path: "./Packages/ThirdParty/MBProgressHUD"),
        .package(path: "./Packages/ThirdParty/SVProgressHUD"),
        .package(path: "./Packages/ThirdParty/MJRefresh"),
        .package(path: "./Packages/ThirdParty/FSPagerView"),
        .package(path: "./Packages/ThirdParty/JXSegmentedView"),
        .package(path: "./Packages/ThirdParty/DZNEmptyDataSet"),

        // ========== 以下库暂时不支持 SPM 或需要特殊处理 ==========
        // R.swift - 需要使用 Xcode 插件
        // SVProgressHUD - 需要封装为本地 Package
        // MJRefresh - 需要封装为本地 Package
        // FSPagerView - 需要封装为本地 Package
        // JXSegmentedView - 需要封装为本地 Package
        // DZNEmptyDataSet - 需要封装为本地 Package
        // AcknowList - 需要封装为本地 Package
        // FlexLayout - Yoga 布局库，可能不支持 SPM
        // PinLayout - 需要检查 SPM 支持
        // KSCrash - 需要封装为本地 Package
        // LookinServer - Debug 专用
        // CocoaDebug - Debug 专用
        // FunnyButton - Debug 专用
        // LifetimeTracker - Debug 专用
        // TheRouter - 需要检查 SPM 支持
        // IQKeyboardManagerSwift - 使用 Git tag，需要特殊处理
        // NSObject+Rx - 已弃用
    ]
)
