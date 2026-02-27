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
        // 自动生成 Scheme 选项（默认启用）
        // automaticSchemesOptions: .enabled(
        //     defaultScheme: .schemeName("AppTemplate"),
        //     testTarget: .testableTarget(
        //         target: "AppTemplateTests",
        //         parallelization: .enabled
        //     )
        // ),

        // 或者禁用自动 Scheme，手动在 schemes 中配置
        // automaticSchemesOptions: .disabled,

        textSettings: .textSettings(
            indentWidth: 4,              // 缩进宽度
            tabWidth: 4                  // Tab 宽度
        )
    ),

    // ========== 项目设置 ==========
    settings: .settings(
        // ========== 基础设置 ==========
        base: [
            // iOS 部署目标
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
            // Bitcode 配置
            "ENABLE_BITCODE": "NO",
            // Swift 版本
            "SWIFT_VERSION": "5.9",
            // 开发团队（从 Apple Developer 获取）
            "DEVELOPMENT_TEAM": .string("YOUR_TEAM_ID"),

            // ========== 代码签名设置 ==========
            "CODE_SIGN_STYLE": "Automatic",           // 自动/手动代码签名
            "CODE_SIGN_IDENTITY": "Apple Development", // 代码签名身份

            // ========== Swift 编译器设置 ==========
            // "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING",  // 添加编译条件

            // ========== 其他常用设置 ==========
            "TARGETED_DEVICE_FAMILY": "1,2",           // 1=iPhone, 2=iPad
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
            "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",

            // ========== SwiftUI 预览（需要时启用）==========
            "ENABLE_PREVIEWS": "YES",
        ],

        // ========== 配置列表 ==========
        configurations: [
            // Debug 配置
            .debug(
                name: .debug,
                settings: [
                    // 启用测试能力（用于单元测试访问 internal 方法）
                    "ENABLE_TESTABILITY": "YES",
                    // 优化级别
                    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                    // 添加调试编译条件
                    // "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG",
                ]
            ),
            // Release 配置
            .release(
                name: .release,
                settings: [
                    // ========== 发布时代码签名（macOS 应用需要）==========
                    // "OTHER_CODE_SIGN_FLAGS": "--timestamp --deep",
                    // "ENABLE_HARDENED_RUNTIME": true,
                    // ========== Provisioning Profile（如需特定 profile）==========
                    // "PROVISIONING_PROFILE_SPECIFIER": "Your Profile Name",
                    // 优化级别
                    "SWIFT_OPTIMIZATION_LEVEL": "-Owholemodule",
                ]
            ),

            // ========== 添加自定义配置 ==========
            // .debug(name: "Staging", settings: ["STAGING": "YES"]),
            // .release(name: "Production", settings: ["PRODUCTION": "YES"]),
        ],

        // 默认设置（推荐设置）
        defaultSettings: .recommended
        // 或者使用 Xcode 默认设置
        // defaultSettings: .none
    ),

    // ========== Targets ==========
    targets: [
        // ---------- 主 App Target ----------
        .target(
            name: "AppTemplate",
            destinations: .iOS,
            product: .app,
            productName: "AppTemplate",          // 产品名称（显示在应用图标下）
            bundleId: "com.example.AppTemplate",
            deploymentTargets: .iOS("17.0"),

            // ========== Info.plist 配置 ==========
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "我的应用",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",

                    // ========== 启动屏幕 ==========
                    "UILaunchStoryboardName": "LaunchScreen",

                    // ========== 屏幕方向 ==========
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                        // "UIInterfaceOrientationLandscapeLeft",
                        // "UIInterfaceOrientationLandscapeRight",
                        // "UIInterfaceOrientationPortraitUpsideDown",
                    ],

                    // ========== 网络安全配置（允许 HTTP）==========
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],

                    // ========== URL Schemes（深度链接）==========
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Viewer",
                            "CFBundleURLName": "com.example.AppTemplate",
                            "CFBundleURLSchemes": ["myapp"],
                        ]
                    ],

                    // ========== 隐私权限描述（根据需要添加）==========
                    // "NSPhotoLibraryUsageDescription": "需要访问相册以选择照片",
                    // "NSPhotoLibraryAddUsageDescription": "需要保存照片到相册",
                    // "NSCameraUsageDescription": "需要使用相机拍摄照片",
                    // "NSMicrophoneUsageDescription": "需要使用麦克风录音",
                    // "NSLocationWhenInUseUsageDescription": "需要获取您的位置信息",
                    // "NSLocationAlwaysAndWhenInUseUsageDescription": "需要在后台获取您的位置信息",
                    // "NSContactsUsageDescription": "需要访问联系人",
                    // "NSCalendarsUsageDescription": "需要访问日历",
                    // "NSRemindersUsageDescription": "需要访问提醒事项",
                    // "NSFaceIDUsageDescription": "需要使用 Face ID 进行身份验证",
                    // "NSUserTrackingUsageDescription": "需要追踪您的活动以提供个性化广告",

                    // ========== 后台模式 ==========
                    "UIBackgroundModes": [
                        // "audio",
                        // "location",
                        // "fetch",
                        // "remote-notification",
                        // "bluetooth-central",
                        // "processing",
                    ],

                    // ========== Scene 配置（iOS 13+）==========
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [],
                    ],

                    // ========== SwiftUI 启动屏幕配置 ==========
                    // "UILaunchScreen": [
                    //     "UIColorName": "",
                    //     "UIImageName": "",
                    // ],
                ]
            ),

            // ========== 源码文件 ==========
            sources: [
                "AppTemplate/Sources/**",

                // ========== Glob 模式（更灵活的文件匹配）==========
                // .glob(pattern: "AppTemplate/Sources/**/*.swift", excluding: ["**/*+Unused.swift"]),

                // ========== 条件源文件（仅特定平台）==========
                // .glob(pattern: "AppTemplate/Sources/iOS/**", inclusionCondition: .when([.ios])),
            ],

            // ========== 资源文件 ==========
            resources: [
                "AppTemplate/Resources/**",

                // ========== Glob 模式 ==========
                // .glob(pattern: "AppTemplate/Resources/**", excluding: ["**/*.lproj"]),

                // ========== 条件资源 ==========
                // .glob(pattern: "AppTemplate/Resources/iOS/**", inclusionCondition: .when([.ios])),
            ],

            // ========== CoreData 模型 ==========
            // coreDataModels: [
            //     .coreDataModel("AppTemplate/Resources/Model.xcdatamodeld", currentVersion: "1"),
            //     .coreDataModel("AppTemplate/Resources/Model2.xcdatamodeld"), // 自动检测版本
            // ],

            // ========== 资源合成器 ==========
            // 用于自动生成资源访问代码（如 Strings, Assets, Lproj 等）
            // resourceSynthesizers: .default + [
            //     .strings(),
            //     .assets(),
            //     .coreData(),
            //     .files(),
            //     .custom(
            //         type: "json",
            //         parser: .directory(selector: "Entries", extensions: ["json"]),
            //         extensions: ["json"]
            //     ),
            // ],

            // ========== 构建脚本（Build Phases 脚本）==========
            scripts: [
                // ========== Pre-scripts（编译前执行）==========
                // .pre(
                //     tool: "/bin/echo",
                //     arguments: ["\"开始编译\""],
                //     name: "开始编译提示",
                //     inputPaths: ["Sources/**/*.swift"],      // 输入文件（用于增量构建）
                //     outputPaths: ["$(DERIVED_FILE_DIR)/output.txt"]  // 输出文件
                // ),

                // ========== 运行脚本文件 ==========
                // .pre(
                //     path: "scripts/swiftlint.sh",
                //     name: "SwiftLint",
                //     inputFileListPaths: ["inputs.xcfilelist"],  // 输入文件列表
                //     dependencyFile: "$TEMP_DIR/dependencies.d"  // 依赖文件
                // ),

                // ========== 内联脚本 ==========
                // .pre(
                //     script: """
                //     echo "Running SwiftLint..."
                //     swiftlint lint --quiet
                //     """,
                //     name: "SwiftLint"
                // ),

                // ========== Post-scripts（编译后执行）==========
                // .post(
                //     script: "echo '编译完成'",
                //     name: "编译完成提示"
                // ),

                // ========== 仅在 Archive 时运行的脚本 ==========
                // .post(
                //     script: "echo 'Archive 构建'",
                //     name: "Archive 提示",
                //     runForInstallBuildsOnly: true
                // ),

                // ========== 使用外部工具 ==========
                // .post(
                //     tool: "/usr/bin/say",
                //     arguments: ["\"构建成功\""],
                //     name: "语音提示"
                // ),
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
                // .external(name: "Nuke"),

                // ---------- 布局 ----------

                // .external(name: "SnapKit"),

                // ---------- 架构模式 ----------

                // .external(name: "ComposableArchitecture"),

                // ---------- 工具类 ----------

                // Keychain 钥匙串存储
                // .external(name: "KeychainAccess"),

                // SF Symbols 图标
                // .external(name: "SFSafeSymbols"),

                // ---------- 日志调试 ----------

                // .external(name: "CocoaLumberjack"),
            ],

            // ========== Target 设置（覆盖项目设置）==========
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",

                    // 代码签名
                    "CODE_SIGN_STYLE": "Automatic",
                    "CODE_SIGN_IDENTITY": "Apple Development",
                    "PRODUCT_BUNDLE_IDENTIFIER": "com.example.AppTemplate",

                    // 权限文件
                    // "CODE_SIGN_ENTITLEMENTS": "AppTemplate/Resources/AppTemplate.entitlements",

                    // SwiftUI 预览（需要时启用）
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

        // // ---------- Framework Target ----------
        // .target(
        //     name: "MyFramework",
        //     destinations: .iOS,
        //     product: .framework,           // 或 .staticFramework
        //     bundleId: "com.example.MyFramework",
        //     deploymentTargets: .iOS("17.0"),
        //     infoPlist: .default,
        //     sources: ["MyFramework/Sources/**"],
        //     resources: ["MyFramework/Resources/**"],
        //     dependencies: [
        //         .external(name: "Alamofire"),
        //     ]
        // ),

        // // ---------- 测试 Target ----------
        // .target(
        //     name: "AppTemplateTests",
        //     destinations: .iOS,
        //     product: .unitTests,
        //     bundleId: "com.example.AppTemplateTests",
        //     infoPlist: .default,
        //     sources: ["Tests/**"],
        //     dependencies: [
        //         .target(name: "AppTemplate"),
        //         // 测试辅助库
        //         // .external(name: "Nimble"),      // 匹配器
        //         // .external(name: "Quick"),       // BDD 测试框架
        //     ]
        // ),

        // // ---------- UI 测试 Target ----------
        // .target(
        //     name: "AppTemplateUITests",
        //     destinations: .iOS,
        //     product: .uiTests,
        //     bundleId: "com.example.AppTemplateUITests",
        //     infoPlist: .default,
        //     sources: ["UITests/**"],
        //     dependencies: [
        //         .target(name: "AppTemplate"),
        //     ]
        // ),

        // // ---------- Extension Targets ----------

        // // Today Widget (iOS 14+)
        // .target(
        //     name: "WidgetExtension",
        //     destinations: .iOS,
        //     product: .appExtension,
        //     bundleId: "com.example.AppTemplate.WidgetExtension",
        //     infoPlist: .extendingDefault(with: [
        //         "CFBundleDisplayName": "$(PRODUCT_NAME)",
        //         "NSExtension": [
        //             "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
        //         ],
        //     ]),
        //     sources: "WidgetExtension/Sources/**",
        //     resources: "WidgetExtension/Resources/**",
        //     dependencies: [
        //         .target(name: "AppTemplate"),
        //     ]
        // ),

        // // Notification Service Extension
        // .target(
        //     name: "NotificationServiceExtension",
        //     destinations: .iOS,
        //     product: .appExtension,
        //     bundleId: "com.example.AppTemplate.NotificationServiceExtension",
        //     infoPlist: .extendingDefault(with: [
        //         "CFBundleDisplayName": "$(PRODUCT_NAME)",
        //         "NSExtension": [
        //             "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
        //             "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService",
        //         ],
        //     ]),
        //     sources: "NotificationServiceExtension/**"
        // ),

        // // Share Extension
        // .target(
        //     name: "ShareExtension",
        //     destinations: .iOS,
        //     product: .appExtension,
        //     bundleId: "com.example.AppTemplate.ShareExtension",
        //     infoPlist: .extendingDefault(with: [
        //         "NSExtension": [
        //             "NSExtensionPointIdentifier": "com.apple.share-services",
        //             "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).ShareViewController",
        //         ],
        //     ]),
        //     sources: "ShareExtension/**",
        //     resources: "ShareExtension/Resources/**"
        // ),

        // // ---------- Clip App Target (iOS 16+) ----------
        // .target(
        //     name: "AppClip",
        //     destinations: .iOS,
        //     product: .appClip,
        //     bundleId: "com.example.AppTemplate.Clip",
        //     infoPlist: .extendingDefault(
        //         with: [
        //             "CFBundleDisplayName": "App Clip",
        //             "WKAppBundleIdentifier": "com.example.AppTemplate.Clip",
        //         ]
        //     ),
        //     sources: "AppClip/**",
        //     dependencies: [
        //         .target(name: "AppTemplate"),
        //     ]
        // ),

        // // ---------- Bundle Target（资源包）----------
        // .target(
        //     name: "ResourcesBundle",
        //     destinations: .iOS,
        //     product: .bundle,
        //     bundleId: "com.example.AppTemplate.ResourcesBundle",
        //     resources: "ResourcesBundle/**"
        // ),
    ],

    // ========== Schemes ==========
    schemes: [
        // ---------- 主 Scheme ----------
        .scheme(
            name: "AppTemplate",
            shared: true,                           // 是否共享给团队
            buildAction: .buildAction(
                targets: ["AppTemplate"],

                // ========== 构建 Pre-Actions ==========
                preActions: [
                    // .executionAction(
                    //     title: "构建前检查",
                    //     scriptText: "echo '开始构建...'",
                    //     target: "AppTemplate"
                    // ),
                ],

                // ========== 构建 Post-Actions ==========
                postActions: [
                    // .executionAction(
                    //     title: "构建完成",
                    //     scriptText: "echo '构建完成！'",
                    //     target: "AppTemplate"
                    // ),
                ],

                // 失败时是否运行 post-actions
                runPostActionsOnFailure: false
            ),

            // ========== 测试配置 ==========
            testAction: .targets(
                [
                    // .testableTarget(
                    //     target: "AppTemplateTests",
                    //     parallelization: .enabled,    // 并行测试
                    //     randomExecutionOrder: .enabled,  // 随机执行顺序
                    //     simulatedLocation: .rioDeJaneiro  // 模拟位置
                    // ),
                ],
                // ========== 测试计划 ==========
                // .testPlans(["*.xctestplan"]),
                // ========== 测试 Pre-Actions ==========
                preActions: [],
                // ========== 测试 Post-Actions ==========
                postActions: [],
                // ========== 测试选项 ==========
                options: .options(
                    language: "zh-Hans",                // 测试语言
                    region: "CN"                       // 测试区域
                    // coverageLevel: .ordinary          // 覆盖率级别
                )
            ),

            // ========== 运行配置 ==========
            runAction: .runAction(
                executable: "AppTemplate",

                // ========== 启动参数 ==========
                // arguments: .arguments(
                //     // ========== 环境变量 ==========
                //     environmentVariables: [
                //         "API_BASE_URL": .environmentVariable(value: "https://api.example.com"),
                //         "DEBUG_MODE": .environmentVariable(value: "true", isEnabled: true),
                //         "CUSTOM_KEY": "$(SRCROOT)",  // 使用 Xcode 环境变量
                //     ],
                //     // 启动参数（传递给应用程序）
                //     launchArguments: [
                //         .launchArgument(name: "--uitesting", isEnabled: true),
                //         .launchArgument(name: "--debug", isEnabled: false),
                //     ]
                // ),

                // ========== 运行选项 ==========
                options: .options(
                    // StoreKit 配置文件（用于应用内购买测试）
                    // storeKitConfigurationPath: "Configuration/StoreKit.storekit",

                    // 模拟位置
                    // simulatedLocation: .tokyo,
                    // simulatedLocation: .custom(gpxFile: "Resources/Location.gpx"),

                    // GPU 帧捕获模式
                    // enableGPUFrameCaptureMode: .metal,
                    // enableGPUFrameCaptureMode: .disabled,

                    // 语言和区域
                    language: "zh-Hans",
                    region: "CN"

                    // 启动参数
                    // launchScreen: .manifest(path: "LaunchScreen.manifest")
                ),

                // ========== 诊断选项 ==========
                diagnosticsOptions: .options(
                    mainThreadCheckerEnabled: true    // 主线程检查器
                    // gpuValidationMode: .enabled,     // GPU 验证
                    // mallocScribble: true,             // 内存填充检测
                    // mallocGuardEdges: true            // 边界保护
                )

                // ========== 自定义 LLDB 初始化文件 ==========
                // customLLDBInitFile: "Scripts/lldbinit",

                // ========== 可执行配置 ==========
                // executable: .constant("AppTemplate"),      // 常量可执行文件
                // executable: .projectTarget("AppTemplate") // 项目目标
            ),

            // ========== Archive 配置 ==========
            archiveAction: .archiveAction(
                configuration: .release,
                // ========== Archive Pre-Actions ==========
                preActions: [],
                // ========== Archive Post-Actions ==========
                postActions: [],
                // ========== 自定义 Archive 路径 ==========
                // customArchiveName: "AppTemplate-$(VERSION)-$(BUILD_NUMBER)",
                // revealArchiveInOrganizer: true
            ),

            // ========== Profile 配置 ==========
            profileAction: .profileAction(
                configuration: .release,
                executable: "AppTemplate"
            ),

            // ========== Analyze 配置 ==========
            analyzeAction: .analyzeAction(
                configuration: .debug
            )
        ),

        // // ---------- Debug Scheme ----------
        // .scheme(
        //     name: "AppTemplate-Debug",
        //     shared: true,
        //     buildAction: .buildAction(targets: ["AppTemplate"]),
        //     runAction: .runAction(
        //         executable: "AppTemplate",
        //         arguments: .arguments(
        //             launchArguments: [
        //                 .launchArgument(name: "--debug", isEnabled: true),
        //             ],
        //             environmentVariables: [
        //                 "DEBUG": "1",
        //             ]
        //         )
        //     )
        // ),

        // // ---------- Release Scheme ----------
        // .scheme(
        //     name: "AppTemplate-Release",
        //     shared: true,
        //     buildAction: .buildAction(targets: ["AppTemplate"]),
        //     runAction: .runAction(
        //         executable: "AppTemplate",
        //         options: .options(
        //             simulatedLocation: .disabled
        //         )
        //     ),
        //     archiveAction: .archiveAction(configuration: .release)
        // ),
    ],

    // ========== 额外文件 ==========
    additionalFiles: [
        ".tuist-supported-version",
        "Tuist/**",

        // ========== 添加其他需要显示在 Xcode 中的文件 ==========
        // "README.md",
        // "Documentation/**",
    ],

    // ========== 资源合成器（项目级别）==========
    // 用于自动生成资源访问代码
    // resourceSynthesizers: .default

    // ========== 插件（Tuist 插件）==========
    // plugins: [
    //     .git(url: "https://github.com/tuist/tuist-plugin-example", from: "1.0.0"),
    // ]
)

// MARK: - 辅助函数（可选）

// /// 根据环境变量获取 Bundle ID
// func bundleId(forEnvironment env: String) -> String {
//     switch env {
//     case "staging": return "com.example.AppTemplate.staging"
//     case "production": return "com.example.AppTemplate"
//     default: return "com.example.AppTemplate.dev"
//     }
// }
