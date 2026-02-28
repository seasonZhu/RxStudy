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
            "NSObject-Rx": .staticFramework,
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
            "PagerTabStripView": .staticFramework,
            "ProgressHUD": .staticFramework,
            "MBProgressHUD": .staticFramework,
            "SVProgressHUD": .staticFramework,
            "MJRefresh": .staticFramework,
            "JXSegmentedView": .staticFramework,
            "DZNEmptyDataSet": .staticFramework,
            "FlexLayout": .staticFramework,
            "FSPagerView": .staticFramework,
            "AcknowList": .staticFramework,
        ]
    )
#endif

let package = Package(
    name: "RxStudy",
    dependencies: [
        // ========== RxSwift 生态 ==========
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.9.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "4.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxTheme.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxOptional.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/NSObject-Rx.git", from: "5.2.2"),

        // ========== 网络层 ==========
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),

        // ========== 图片加载 ==========
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.3"),

        // ========== 布局 ==========
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        //.package(url: "https://github.com/layoutBox/FlexLayout.git", from: "2.2.3"),

        // ========== 工具 ==========
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.9.0"),
        .package(url: "https://github.com/cbpowell/MarqueeLabel.git", from: "4.5.3"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "6.2.0"),
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "2.5.0"),

        // ========== WebView ==========
        .package(url: "https://github.com/cybozu/WebUI.git", from: "4.0.0"),

        // ========== TabView 组件 ==========
        .package(url: "https://github.com/xmartlabs/PagerTabStripView.git", from: "3.0.0"),

        // ========== UI 工具 ==========
        .package(url: "https://github.com/relatedcode/ProgressHUD.git", from: "15.0.1"),
        .package(url: "https://github.com/jdg/MBProgressHUD.git", from: "1.2.0"),
        .package(url: "https://github.com/SVProgressHUD/SVProgressHUD.git", from: "2.3.1"),
        .package(url: "https://github.com/CoderMJLee/MJRefresh.git", from: "3.7.9"),
        .package(url: "https://github.com/pujiaxin33/JXSegmentedView.git", from: "1.4.1"),

        // ========== 空数据展示（使用主分支最新代码）==========
        .package(url: "https://github.com/dzenbot/DZNEmptyDataSet.git", branch: "master"),

        // ========== 本地依赖（Package.swift 格式错误的库）==========
        .package(path: "../Packages/ThirdParty/FSPagerView"),

        // ========== 许可证列表 ==========
        .package(url: "https://github.com/vtourraine/AcknowList.git", from: "3.4.0"),
    ]
)
