//
//  Project.swift
//  Tuist iOS 项目模板
//
//  这是一个带完整注释的 Tuist 项目配置模板
//  根据你的需求取消注释相应的配置即可
//

import ProjectDescription

// MARK: - 项目基本配置

/// 项目配置
let project = Project(
    // ========== 项目信息 ==========
    name: "AppTemplate",                    // 项目名称
    organizationName: "com.example",  // 组织标识符

    // ========== 项目选项 ==========
    options: .options(
        textSettings: .textSettings(
            indentWidth: 4,              // 缩进宽度
            tabWidth: 4                  // Tab 宽度
        )
    ),

    // ========== 项目设置 ==========
    settings: .settings(
        base: [
            // iOS 部署目标
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            // Bitcode 配置
            "ENABLE_BITCODE": "NO",
            // Swift 版本
            "SWIFT_VERSION": "5.9",
            // 开发团队（从 Apple Developer 获取）
            "DEVELOPMENT_TEAM": .string("YOUR_TEAM_ID"),
        ],
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ],
        defaultSettings: .recommended
    ),

    // ========== Targets ==========
    targets: [
        // ---------- 主 App Target ----------
        .target(
            name: "AppTemplate",
            destinations: .iOS,
            product: .app,
            bundleId: "com.example.AppTemplate",
            deploymentTargets: .iOS("17.0"),

            // Info.plist 配置
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "我的应用",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                    "UILaunchStoryboardName": "LaunchScreen",

                    // 屏幕方向
                    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],

                    // 网络安全配置（允许 HTTP）
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],

                    // 隐私权限描述（根据需要添加）
                    // "NSPhotoLibraryUsageDescription": "需要访问相册",
                    // "NSCameraUsageDescription": "需要访问相机",
                    // "NSMicrophoneUsageDescription": "需要访问麦克风",
                    // "NSLocationWhenInUseUsageDescription": "需要访问位置",
                ]
            ),

            // 源码文件
            sources: [
                "AppTemplate/Sources/**",
            ],

            // 资源文件
            resources: [
                "AppTemplate/Resources/**",
            ],

            // ========== 依赖配置 ==========
            // 取消注释你需要的依赖
            dependencies: [
                // ---------- RxSwift 生态 ----------
                // 注意：使用 RxSwift 需要在 Tuist/Package.swift 中添加对应依赖

                // .external(name: "RxSwift"),
                // .external(name: "RxCocoa"),
                // .external(name: "RxRelay"),
                // .external(name: "RxDataSources"),
                // .external(name: "RxGesture"),
                // .external(name: "RxTheme"),

                // ---------- 网络层 ----------

                // Moya + Alamofire (RxSwift 版本)
                // .external(name: "RxMoya"),

                // Moya + Alamofire (async/await 版本)
                // .external(name: "Moya"),
                // .external(name: "Alamofire"),

                // ---------- 图片加载 ----------

                // .external(name: "Kingfisher"),

                // ---------- 布局 ----------

                // .external(name: "SnapKit"),

                // ---------- 工具类 ----------

                // Keychain 钥匙串存储
                // .external(name: "KeychainAccess"),

                // SF Symbols 图标
                // .external(name: "SFSafeSymbols"),

                // ---------- 日志调试 ----------

                // .external(name: "CocoaLumberjack"),
            ],

            // ========== Target 设置 ==========
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",

                    // 代码签名
                    "CODE_SIGN_STYLE": "Automatic",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.example.AppTemplate",

                    // Swift 预览（需要时启用）
                    "ENABLE_PREVIEWS": "YES",
                ],
                configurations: [
                    .debug(name: .debug),
                    .release(name: .release)
                ],
                defaultSettings: .recommended
            )
        ),

        // ========== 添加更多 Targets ==========
        // 根据需要取消注释和修改

        // // SwiftUI Target（独立 SwiftUI 应用）
        // .target(
        //     name: "SwiftUIApp",
        //     destinations: .iOS,
        //     product: .app,
        //     bundleId: "com.example.SwiftUIApp",
        //     deploymentTargets: .iOS("17.0"),
        //     infoPlist: .extendingDefault(
        //         with: [
        //             "CFBundleDisplayName": "我的应用(SwiftUI)",
        //             "NSAppTransportSecurity": ["NSAllowsArbitraryLoads": true],
        //         ]
        //     ),
        //     sources: ["SwiftUIApp/Sources/**"],
        //     resources: ["AppTemplate/Resources/**"],
        //     dependencies: [
        //         .external(name: "Moya"),
        //         .external(name: "Alamofire"),
        //     ],
        //     settings: .settings(
        //         base: [
        //             "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        //             "ENABLE_PREVIEWS": "YES",
        //         ],
        //         configurations: [
        //             .debug(name: .debug),
        //             .release(name: .release)
        //         ],
        //         defaultSettings: .recommended
        //     )
        // ),

        // // 测试 Target
        // .target(
        //     name: "AppTemplateTests",
        //     destinations: .iOS,
        //     product: .unitTests,
        //     bundleId: "com.example.AppTemplateTests",
        //     sources: ["Tests/**"],
        //     dependencies: [
        //         .target(name: "AppTemplate"),
        //     ]
        // ),
    ],

    // ========== Schemes ==========
    schemes: [
        .scheme(
            name: "AppTemplate",
            shared: true,
            buildAction: .buildAction(targets: ["AppTemplate"]),
            runAction: .runAction(executable: "AppTemplate"),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        ),

        // 添加更多 Schemes（根据需要取消注释）
        // .scheme(
        //     name: "SwiftUIApp",
        //     shared: true,
        //     buildAction: .buildAction(targets: ["SwiftUIApp"]),
        //     runAction: .runAction(executable: "SwiftUIApp"),
        // ),
    ],

    // ========== 额外文件 ==========
    additionalFiles: [
        ".tuist-supported-version",
        "Tuist/**",
    ]
)
