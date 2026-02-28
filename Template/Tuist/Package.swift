// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // 产品类型配置
        // 默认为 .staticFramework，如需动态框架可修改
        productTypes: [
            // ========== RxSwift 生态 ==========
            // "RxSwift": .staticFramework,
            // "RxCocoa": .staticFramework,
            // "RxRelay": .staticFramework,
            // "RxDataSources": .staticFramework,
            // "RxGesture": .staticFramework,
            // "RxTheme": .staticFramework,
            // "RxSwiftExt": .staticFramework,
            // "RxOptional": .staticFramework,
            // "RxBlocking": .staticFramework,
            // "RxMoya": .staticFramework,

            // ========== 网络层 ==========
            // "Moya": .staticFramework,
            // "Alamofire": .staticFramework,

            // ========== 图片加载 ==========
            // "Kingfisher": .staticFramework,

            // ========== 布局 ==========
            // "SnapKit": .staticFramework,
            // "FlexLayout": .staticFramework,

            // ========== 工具 ==========
            // "KeychainAccess": .staticFramework,
            // "SFSafeSymbols": .staticFramework,

            // ========== 日志 ==========
            // "CocoaLumberjack": .staticFramework,

            // ========== WebView (SwiftUI) ==========
            // "WebUI": .staticFramework,
            // "ProgressHUD": .staticFramework,

            // ========== UI 工具 ==========
            // "MBProgressHUD": .staticFramework,
            // "SVProgressHUD": .staticFramework,
            // "MJRefresh": .staticFramework,
            // "JXSegmentedView": .staticFramework,
            // "DZNEmptyDataSet": .staticFramework,

            // ========== 轮播图 ==========
            // "FSPagerView": .staticFramework,

            // ========== 许可证列表 ==========
            // "AcknowList": .staticFramework,
        ]
    )
#endif

let package = Package(
    name: "AppTemplate",
    dependencies: [
        // ========== SPM 包依赖 ==========
        // 取消注释你需要使用的依赖

        // ---------- RxSwift 生态 ----------
        // .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.9.0"),
        // .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),
        // .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "4.0.0"),
        // .package(url: "https://github.com/RxSwiftCommunity/RxTheme.git", from: "6.0.0"),
        // .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", from: "6.0.0"),
        // .package(url: "https://github.com/RxSwiftCommunity/RxOptional.git", from: "5.0.0"),

        // ---------- 网络层 ----------
        // .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),

        // ---------- 图片加载 ----------
        // .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.3"),

        // ---------- 布局 ----------
        // .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        // .package(url: "https://github.com/layoutBox/FlexLayout.git", from: "2.2.3"),

        // ---------- 工具 ----------
        // .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        // .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "6.2.0"),

        // ---------- 日志调试 ----------
        // .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.9.0"),

        // ---------- WebView (SwiftUI) ----------
        // .package(url: "https://github.com/cybozu/WebUI.git", from: "4.0.0"),
        // .package(url: "https://github.com/relatedcode/ProgressHUD.git", from: "15.0.1"),

        // ---------- UI 工具 ----------
        // .package(url: "https://github.com/jdg/MBProgressHUD.git", from: "1.2.0"),
        // .package(url: "https://github.com/SVProgressHUD/SVProgressHUD.git", from: "2.3.1"),
        // .package(url: "https://github.com/CoderMJLee/MJRefresh.git", from: "3.7.9"),
        // .package(url: "https://github.com/pujiaxin33/JXSegmentedView.git", from: "1.4.1"),
        // .package(url: "https://github.com/dzenbot/DZNEmptyDataSet.git", branch: "master"),  // 使用主分支最新代码

        // ---------- 本地依赖（远程 Package.swift 格式错误）----------
        // .package(path: "../Packages/ThirdParty/FSPagerView"),

        // ---------- 许可证列表 ----------
        // .package(url: "https://github.com/vtourraine/AcknowList.git", from: "3.4.0"),
    ]
)

// MARK: - 依赖添加指南

/*
如何添加新的第三方依赖：

1. 在 dependencies 数组中添加 .package()
   .package(url: "https://github.com/user/Repo.git", from: "1.0.0")

2. 在 productTypes 中添加产品类型
   "Repo": .staticFramework,

3. 在 Project.swift 的 dependencies 中引用
   .external(name: "Repo"),

4. 运行 tuist fetch 安装依赖

常用版本要求：
- from: "1.0.0"       # 指定最低版本
- .upToNextMajor(from: "1.0.0")    # 允许次版本和修订版本更新
- .upToNextMinor(from: "1.0.0")    # 只允许修订版本更新
- .exact(Version("1.0.0"))      # 精确版本
*/
