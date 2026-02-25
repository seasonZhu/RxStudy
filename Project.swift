import ProjectDescription

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
                // ========== SwiftGen 生成的代码 ==========
                "RxStudy/Generated/**/*.swift",
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
                "RxStudy/Assets.xcassets/**",
                "RxStudy/Base.lproj/LaunchScreen.storyboard",
                "RxStudy/Base.lproj/Main.storyboard",
                "Packages/ThirdParty/SVProgressHUD/Sources/SVProgressHUD.bundle/**",
                "Packages/ThirdParty/MJRefresh/Sources/MJRefresh/MJRefresh.bundle/**"
            ],
            dependencies: [
                // ========== RxSwift 生态 ==========
                TargetDependency.external(name: "RxSwift"),
                TargetDependency.external(name: "RxCocoa"),
                TargetDependency.external(name: "RxRelay"),
                TargetDependency.external(name: "RxDataSources"),
                TargetDependency.external(name: "RxGesture"),
                TargetDependency.external(name: "RxTheme"),
                TargetDependency.external(name: "RxSwiftExt"),
                TargetDependency.external(name: "RxOptional"),
                TargetDependency.external(name: "RxBlocking"),

                // ========== 网络层 ==========
                // 使用 Moya 的 RxMoya 模块（SPM 自带，不需要自定义扩展）
                TargetDependency.external(name: "RxMoya"),
                TargetDependency.external(name: "Alamofire"),

                // ========== 图片加载 ==========
                TargetDependency.external(name: "Kingfisher"),

                // ========== 布局 ==========
                TargetDependency.external(name: "SnapKit"),

                // ========== 工具 ==========
                TargetDependency.external(name: "KeychainAccess"),
                TargetDependency.external(name: "CocoaLumberjack"),
                TargetDependency.external(name: "MarqueeLabel"),
                TargetDependency.external(name: "SFSafeSymbols"),
                TargetDependency.external(name: "ZipArchive"),
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
