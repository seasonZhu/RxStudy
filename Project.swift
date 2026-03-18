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
                // ========== 共享代码 ==========
                "Shared/ACarousel/**",
                "Shared/Models/**",
                "Shared/Extensions/**",
                // ========== 本地依赖（源码集成 → 本地 SPM 包迁移）==========
                // 以下库已改为使用本地 SPM 包：
                // - FSPagerView → 本地 SPM 包（Package.swift 手动创建）
                // 以下库不支持 SPM，保持源码集成：
                // - TheRouter → 已改回源码直接集成
                "Packages/ThirdParty/TheRouter/Sources/**",
                // 已清理的本地源码：
                // - FlexLayout → 已通过官方 SPM 集成（本地源码已清理）
            ],
            resources: [
                "RxStudy/Assets.xcassets/**",
                "RxStudy/Base.lproj/LaunchScreen.storyboard",
                "RxStudy/Base.lproj/Main.storyboard",
                // ========== 许可证列表 ==========
                "RxStudy/Pods-RxStudy-acknowledgements.plist",
                // 以下库的 bundle 已通过 SPM 自动管理：
                // - SVProgressHUD.bundle
                // - MJRefresh.bundle
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
                TargetDependency.external(name: "NSObject-Rx"),

                // ========== 网络层 ==========
                // 使用 Moya 的 RxMoya 模块（SPM 自带，不需要自定义扩展）
                TargetDependency.external(name: "RxMoya"),
                TargetDependency.external(name: "Alamofire"),

                // ========== 图片加载 ==========
                TargetDependency.external(name: "Kingfisher"),

                // ========== 布局 ==========
                TargetDependency.external(name: "SnapKit"),
                //TargetDependency.external(name: "FlexLayout"),

                // ========== 工具 ==========
                TargetDependency.external(name: "KeychainAccess"),
                TargetDependency.external(name: "CocoaLumberjack"),
                TargetDependency.external(name: "MarqueeLabel"),
                TargetDependency.external(name: "SFSafeSymbols"),
                TargetDependency.external(name: "ZipArchive"),

                // ========== UI 工具 ==========
                TargetDependency.external(name: "MBProgressHUD"),
                TargetDependency.external(name: "SVProgressHUD"),
                TargetDependency.external(name: "MJRefresh"),

                // ========== 分段控制器 ==========
                TargetDependency.external(name: "JXSegmentedView"),

                // ========== 空数据展示 ==========
                TargetDependency.external(name: "DZNEmptyDataSet"),

                // ========== 轮播图 ==========
                TargetDependency.external(name: "FSPagerView"),

                // ========== 许可证列表 ==========
                TargetDependency.external(name: "AcknowList"),
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
                        // 以下库已改为使用本地 SPM 依赖，头文件由 SPM 自动管理：
                        // - FSPagerView
                        // 以下库已改为使用官方 SPM 依赖，头文件由 SPM 自动管理：
                        // - MBProgressHUD
                        // - SVProgressHUD
                        // - MJRefresh
                        // - DZNEmptyDataSet
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

        // ========== SwiftUI Study Target（UIKit → SwiftUI 迁移专用）==========
        .target(
            name: "SwiftUIStudy",
            destinations: .iOS,
            product: .app,
            bundleId: "com.lostsakura.RxStudy.SwiftUIStudy",
            deploymentTargets: .iOS("17.6"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "玩安卓(SwiftUI)",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UILaunchStoryboardName": "LaunchScreen",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "NSPhotoLibraryUsageDescription": "访问相册用于选择图片",
                    "NSCameraUsageDescription": "访问相机用于拍摄图片",
                    "NSPhotoLibraryAddUsageDescription": "保存图片到相册"
                ]
            ),
            sources: [
                // ========== SwiftUIApp 独立代码 ==========
                "SwiftUIApp/**/*.swift",
                // ========== SwiftGen 生成的代码 ==========
                "RxStudy/Generated/**/*.swift",
                // ========== 共享代码 ==========
                "Shared/ACarousel/**",
                "Shared/Models/**",
                "Shared/Extensions/**",
            ],
            resources: [
                // ========== 资源（共享主项目的 Assets）==========
                "RxStudy/Assets.xcassets/**",
                "RxStudy/Base.lproj/LaunchScreen.storyboard",
            ],
            dependencies: [
                // ========== 网络层（使用 async/await）==========
                TargetDependency.external(name: "Moya"),
                TargetDependency.external(name: "Alamofire"),

                // ========== 图片加载 ==========
                TargetDependency.external(name: "Kingfisher"),

                // ========== WebView ==========
                TargetDependency.external(name: "WebUI"),

                // ========== TabView 组件 ==========
                //TargetDependency.external(name: "PagerTabStripView"),

                // ========== UI 工具 ==========
                TargetDependency.external(name: "ProgressHUD"),
                
                TargetDependency.external(name: "SwiftUIIntrospect"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "ENABLE_PREVIEWS": "YES",
                    "DEVELOPMENT_TEAM": .string(teamId),
                    "CODE_SIGN_STYLE": "Automatic",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.lostsakura.RxStudy.SwiftUIStudy",
                ],
                configurations: [
                    .debug(name: .debug),
                    .release(name: .release)
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
        ),
        .scheme(
            name: "SwiftUIStudy",
            shared: true,
            buildAction: .buildAction(targets: ["SwiftUIStudy"]),
            runAction: .runAction(executable: "SwiftUIStudy"),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        )
    ],
    additionalFiles: [
        ".tuist-supported-version",
        "Tuist/**"
    ],
    // ========== 禁用 Plist 资源合成器 ==========
    // 手动指定需要的合成器，不包含 .plist() 以避免生成 TuistPlists+RxStudy.swift
    // 这样我们就可以使用自己的 Pods-RxStudy-acknowledgements.plist + AcknowList
    resourceSynthesizers: [
        .assets(),   // ✅ 保留：Assets 合成器
        .strings(),  // ✅ 保留：Strings 合成器
    ]
)
