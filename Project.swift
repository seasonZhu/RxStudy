import ProjectDescription

/// Team ID - 河南灵动汽车销售服务有限公司
/// 这样每次 tuist generate 后就不需要手动设置了
/// https://developer.apple.com/account
let teamId = "GZKK4Y45D3"

let project = Project(
    name: "RxStudy",
    organizationName: "com.lostsakura",
    options: .options(
        textSettings: .textSettings(
            indentWidth: 2,
            tabWidth: 2
        )
    ),
    packages: [
        // ========== 远程 SPM Package ==========
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", from: "4.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxTheme.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git", from: "6.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxOptional.git", from: "5.0.0"),
        // 使用 Moya 15.0.0 + RxMoya（仅使用 RxSwift，不使用 ReactiveSwift）
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0"),
        .package(url: "https://github.com/cbpowell/MarqueeLabel.git", from: "4.0.0"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "2.1.3"),
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", from: "2.5.0"),
    ],
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.6",
            "ENABLE_BITCODE": "NO",
            "SWIFT_VERSION": "5.9",
            "DEVELOPMENT_TEAM": .string(teamId)
        ],
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ],
        defaultSettings: .recommended
    ),
    targets: [
        // ========== 主工程 ==========
        .target(
            name: "RxStudy",
            destinations: .iOS,
            product: .app,
            bundleId: "com.lostsakura.RxStudy",
            deploymentTargets: .iOS("17.6"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "玩安卓",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationPortrait",
                        "UIInterfaceOrientationPortraitUpsideDown",
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ],
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ]
                            ]
                        ]
                    ],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "NSPhotoLibraryUsageDescription": "访问相册用于选择图片",
                    "NSCameraUsageDescription": "访问相机用于拍摄图片",
                    "NSPhotoLibraryAddUsageDescription": "保存图片到相册",
                    "NSDocumentFolderUsageDescription": "需要访问文档文件夹以保存下载的文档",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["wandroid"]
                        ]
                    ],
                    "LSApplicationQueriesSchemes": ["mqq", "csdn", "openjj", "jianshu", "jianshu.hugo", "com.jianshu.Hugo"]
                ]
            ),
            sources: [
                "RxStudy/**",
                // ========== 第三方库源码（不支持SPM）直接引入 ==========
                "Packages/ThirdParty/NSObject+Rx/Sources/**",
                "Packages/ThirdParty/TheRouter/Sources/**",
                // FlexLayout 暂时移除 - 需要 C++ yoga 模块支持，配置较复杂
                // "Packages/ThirdParty/FlexLayout/Sources/**",
                "Packages/ThirdParty/MBProgressHUD/Sources/**",
                "Packages/ThirdParty/SVProgressHUD/Sources/**",
                "Packages/ThirdParty/MJRefresh/Sources/**",
                // FSPagerView: 排除 include 目录（仅头文件，避免重复编译）
                "Packages/ThirdParty/FSPagerView/Sources/**/*.swift",
                "Packages/ThirdParty/FSPagerView/Sources/*.m",
                "Packages/ThirdParty/JXSegmentedView/Sources/**",
                "Packages/ThirdParty/DZNEmptyDataSet/Sources/**"
            ],
            resources: [
                "RxStudy/Assets.xcassets/**"
            ],
            dependencies: [
                // ========== RxSwift 生态 ==========
                .external(name: "RxSwift"),
                .external(name: "RxCocoa"),
                .external(name: "RxRelay"),
                .external(name: "RxDataSources"),
                .external(name: "RxGesture"),
                .external(name: "RxTheme"),
                .external(name: "RxSwiftExt"),
                .external(name: "RxOptional"),
                .external(name: "RxBlocking"),

                // ========== 网络层 ==========
                // 使用 Moya 的 RxMoya 模块（SPM 自带，不需要自定义扩展）
                .external(name: "RxMoya"),
                .external(name: "Alamofire"),

                // ========== 图片加载 ==========
                .external(name: "Kingfisher"),

                // ========== 布局 ==========
                .external(name: "SnapKit"),

                // ========== 工具 ==========
                .external(name: "KeychainAccess"),
                .external(name: "CocoaLumberjack"),
                .external(name: "MarqueeLabel"),
                .external(name: "SFSafeSymbols"),
                .external(name: "ZipArchive"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "ENABLE_PREVIEWS": "YES",
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG",
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"],
                    /// 这里进行同步修改 - 配置签名信息
                    "DEVELOPMENT_TEAM": .string(teamId),
                    "CODE_SIGN_STYLE": "Automatic",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.lostsakura.RxStudy",
                    /// ========== Bridging Header 配置 ==========
                    "SWIFT_OBJC_BRIDGING_HEADER": "$(SRCROOT)/RxStudy/RxStudy-Bridging-Header.h",
                    /// ========== 第三方库头文件搜索路径 ==========
                    "HEADER_SEARCH_PATHS": [
                        "$(inherited)",
                        "$(SRCROOT)/RxStudy",
                        "$(SRCROOT)/RxStudy/Extension/CrashController",
                        "$(SRCROOT)/RxStudy/Extension/NSURLProtocol+WKWebVIew",
                        "$(SRCROOT)/Packages/ThirdParty/TheRouter/Sources",
                        "$(SRCROOT)/Packages/ThirdParty/MBProgressHUD/Sources/include",
                        "$(SRCROOT)/Packages/ThirdParty/SVProgressHUD/Sources/include",
                        "$(SRCROOT)/Packages/ThirdParty/MJRefresh/Sources/MJRefresh",
                        "$(SRCROOT)/Packages/ThirdParty/MJRefresh/Sources/MJRefresh/**",
                        "$(SRCROOT)/Packages/ThirdParty/DZNEmptyDataSet/Sources/include"
                    ]
                ],
                configurations: [
                    .debug(name: .debug, settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG"
                    ]),
                    .release(name: .release, settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited)"
                    ])
                ],
                defaultSettings: .recommended
            )
        ),
    ],
    schemes: [
        .scheme(
            name: "RxStudy",
            shared: true,
            buildAction: .buildAction(targets: ["RxStudy"]),
            runAction: .runAction(executable: "RxStudy"),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        )
    ],
    additionalFiles: [
        ".tuist-supported-version",
        "Tuist/**"
    ]
)
