import ProjectDescription
import ProjectDescriptionHelpers

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
            infoPlist: .file(path: "RxStudy/Info.plist"),
            sources: [
                .glob("RxStudy/**", excluding: ["RxStudy/Generated/**", "RxStudy/**/*.playground/**"]),
                // ========== SwiftGen 生成的代码 ==========
                "Shared/Generated/**/*.swift",
                // ========== 共享代码 ==========
                "Shared/ACarousel/**",
                "Shared/API/**",
                "Shared/Business/**",
                "Shared/Models/**",
                // TheRouter 保留源码集成，旧实验依赖由 LocalDependencies 定义。
                "Packages/ThirdParty/TheRouter/Sources/**",
            ],
            resources: [
                "Shared/Resources/Assets.xcassets/**",
                "Shared/Resources/Base.lproj/LaunchScreen.storyboard",
                "RxStudy/zh-Hans.lproj/**",
                "RxStudy/en.lproj/**",
                "Shared/Resources/Base.lproj/Main.storyboard",
                // ========== 许可证列表 ==========
                "RxStudy/Pods-RxStudy-acknowledgements.plist",
                "Shared/Resources/JavaScript/**",
                "RxStudy/UniMP/Apps/*.wgt",
                "JSONS/APIKeys.json",
                "Packages/ThirdParty/unimp/UniMPSDK/Core/Resources/**",
                // 以下库的 bundle 已通过 SPM 自动管理：
                // - SVProgressHUD.bundle
                // - MJRefresh.bundle
            ],
            dependencies: [
                .sdk(name: "CoreMotion", type: .framework),
.sdk(name: "CoreTelephony", type: .framework),
.sdk(name: "CoreText", type: .framework),
.sdk(name: "CoreServices", type: .framework),
.sdk(name: "MediaPlayer", type: .framework),
.sdk(name: "JavaScriptCore", type: .framework),
.sdk(name: "QuickLook", type: .framework),
.sdk(name: "WebKit", type: .framework),
.sdk(name: "CFNetwork", type: .framework),
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
                TargetDependency.target(name: "FlexLayout"),
                TargetDependency.target(name: "FlexLayoutYogaKit"),
                TargetDependency.target(name: "PinLayout"),
                TargetDependency.target(name: "KSCrash"),
                TargetDependency.target(name: "CocoaDebug"),
                TargetDependency.target(name: "FunnyButton"),
                TargetDependency.target(name: "LifetimeTracker"),
                TargetDependency.target(name: "JWNetAutoCache"),
                TargetDependency.target(name: "CombineExt"),
                TargetDependency.external(name: "CombineMoya"),
                TargetDependency.target(name: "SDWebImage"),

                // ========== 工具 ==========
                TargetDependency.external(name: "KeychainAccess"),
                TargetDependency.external(name: "CocoaLumberjack"),
                TargetDependency.external(name: "CocoaLumberjackSwift"),
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
                
                // ========== 键盘管理 ==========
                TargetDependency.target(name: "IQKeyboardManagerSwift"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "ENABLE_PREVIEWS": "YES",
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC", "-lcoreSupport", "-llibNativeObj", "-llibNativeUI", "-llibNavigator", "-llibPDRCore", "-llibStorage", "-llibUI", "-llibWeex", "-llibIO", "-framework", "storage", "-lc++", "-liconv"],
                    "FRAMEWORK_SEARCH_PATHS": ["$(inherited)", "$(SRCROOT)/Packages/ThirdParty/unimp/UniMPSDK/Core/Libs"],
                    "LIBRARY_SEARCH_PATHS": ["$(inherited)", "$(SRCROOT)/Packages/ThirdParty/unimp/UniMPSDK/Core/Libs", "$(SRCROOT)/Packages/ThirdParty/unimp/UniMPSDK/File/Libs"],
                    "ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES": ["AppIcon-Swift", "AppIcon-Flutter"],
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
                        "$(SRCROOT)/Packages/ThirdParty/unimp/UniMPSDK/Core/Headers/**",
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
            infoPlist: .file(path: "SwiftUIStudy/Info.plist"),
            sources: [
                // ========== SwiftUIStudy 独立代码 ==========
                "SwiftUIStudy/**/*.swift",
                // ========== SwiftGen 生成的代码 ==========
                "Shared/Generated/**/*.swift",
                // ========== 共享代码 ==========
                "Shared/ACarousel/**",
                "Shared/API/**",
                "Shared/Business/**",
                "Shared/Models/**",
            ],
            resources: [
                // ========== 资源（共享主项目的 Assets）==========
                "Shared/Resources/Assets.xcassets/**",
                "Shared/Resources/Base.lproj/LaunchScreen.storyboard",
                "RxStudy/zh-Hans.lproj/**",
                "RxStudy/en.lproj/**",
            ],
            dependencies: [
                // ========== 网络层（使用 async/await）==========
                TargetDependency.external(name: "Moya"),
                TargetDependency.external(name: "Alamofire"),

                // ========== 图片加载 ==========
                TargetDependency.external(name: "Kingfisher"),

                // ========== WebView ==========

                // ========== TabView 组件 ==========
                //TargetDependency.external(name: "PagerTabStripView"),

                // ========== UI 工具 ==========
                TargetDependency.external(name: "ProgressHUD"),
                
                // ========== 键盘管理 ==========
                TargetDependency.target(name: "IQKeyboardManagerSwift"),
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
    ] + localDependencyTargets,
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
        "mise.toml",
        "Project.swift",
        "Tuist.swift",
        "swiftgen.yml",
        "scripts/**",
        "RxStudy/**/*.h",
        "RxStudy/Info.plist",
        "SwiftUIStudy/Info.plist",
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
