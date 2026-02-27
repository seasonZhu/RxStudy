# Tuist 配置技巧大全

本文档总结了 Tuist 官方模板库中的所有配置技巧和最佳实践。

> 基于 Tuist 官方仓库 220+ 个 Project.swift 示例文件分析整理

## 目录

1. [项目结构](#项目结构)
2. [Target 配置](#target-配置)
3. [依赖管理](#依赖管理)
4. [构建脚本](#构建脚本)
5. [Scheme 配置](#scheme-配置)
6. [Settings 配置](#settings-配置)
7. [Info.plist 配置](#infoplist-配置)
8. [资源管理](#资源管理)
9. [ProjectDescriptionHelpers](#projectdescriptionhelpers)
10. [插件与模板](#插件与模板)
11. [高级技巧](#高级技巧)

---

## 项目结构

### 基础项目结构

```swift
import ProjectDescription

let project = Project(
    name: "MyApp",
    organizationName: "com.example",  // 可选
    options: .options(
        automaticSchemesOptions: .enabled(
            defaultScheme: .schemeName("MyApp"),
            testTarget: .testableTarget(
                target: "MyAppTests",
                parallelization: .enabled
            )
        ),
        textSettings: .textSettings(
            indentWidth: 4,
            tabWidth: 4,
            usesTabs: false
        )
    ),
    settings: .settings(base: [:]),
    targets: [],
    schemes: [],
    additionalFiles: []
)
```

### 多项目 Workspace

```swift
// 在根目录创建 Workspace 配置
// 通常使用 WorkspaceDescription.swift

import ProjectDescription

let workspace = Workspace(
    name: "MyWorkspace",
    projects: [
        "Projects/App",
        "Projects/Frameworks",
    ]
)
```

---

## Target 配置

### 产品类型 (Product)

| 类型 | 说明 | 使用场景 |
|------|------|----------|
| `.app` | 应用程序 | 主应用 |
| `.appClip` | App Clip | 轻量级应用 (iOS 14+) |
| `.framework` | 动态框架 | 可共享代码，需要动态链接 |
| `.staticFramework` | 静态框架 | 静态链接代码 |
| `.staticLibrary` | 静态库 | C/C/Objective-C 静态库 |
| `.dynamicLibrary` | 动态库 | C/C/Objective-C 动态库 |
| `.unitTests` | 单元测试 | 单元测试目标 |
| `.uiTests` | UI 测试 | UI 测试目标 |
| `.appExtension` | 应用扩展 | Widget、通知等 |
| `.stickerPackExtension` | 贴纸包 | iMessage 贴纸 |
| `.messagesExtension` | 消息扩展 | iMessage 扩展 |
| `.extensionKitExtension` | Extension Kit | App Intents (iOS 16+) |
| `.bundle` | 资源包 | 纯资源目标 |
| `.commandLineTool` | 命令行工具 | macOS 命令行工具 |

### 目标平台 (Destinations)

```swift
// iOS
destinations: .iOS

// macOS
destinations: .macOS

// 多平台
destinations: [.iPhone, .iPad]
destinations: [.iPhone, .iPad, .macCatalyst]

// 自定义
destinations: .destinations(
    iPhone: [.iPadPro12_9inch],
    iPad: [.iPadmini6thGen],
    mac: [.macMini, .macBookPro],
    appleWatch: [.appleWatchSeries9],
    appleTV: [.appleTV4K],
    vision: [.visionPro]
)
```

### 部署目标

```swift
// 单平台
deploymentTargets: .iOS("17.0")

// 多平台
deploymentTargets: .multiplatform(
    iOS: "16.0",
    macOS: "13.0",
    watchOS: "9.0",
    tvOS: "16.0",
    visionOS: "1.0"
)

// 带条件的部署目标
deploymentTargets: .iOS("17.0"),
// 在 Target 中使用条件
dependencies: [
    .target(name: "MacOnlyFramework", condition: .when([.macos]))
]
```

### Target 元数据 (Metadata)

```swift
// 用于缓存标记
.target(
    name: "MyFramework",
    metadata: .metadata(tags: ["cacheable"])
)

// 自定义元数据
.target(
    name: "MyApp",
    metadata: .metadata(
        tags: ["domain:ui", "layer:feature"],
        custom: [
            "type": "main",
            "priority": "high"
        ]
    )
)
```

### 生成源文件

```swift
.target(
    name: "App",
    sources: [
        "App/Sources/**",
        .generated("App/Generated/GeneratedEmptyFile.swift"),
        .generated("$(BUILT_PRODUCTS_DIR)/GeneratedFile.swift"),
    ]
)
```

---

## 依赖管理

### 外部依赖 (SPM)

```swift
// 在 Package.swift 中定义
// Project.swift 中引用
dependencies: [
    .external(name: "Alamofire"),
    .external(name: "RxSwift"),
]
```

### 本地依赖

```swift
// 同项目内的 Target
.target(name: "MyFramework")

// 不同项目的 Target
.project(target: "FrameworkA", path: "../Frameworks/FrameworkA")

// 相对路径
.project(target: "FrameworkB", path: .relativeToRoot("Frameworks/FrameworkB"))

// 相对于 manifest
.project(target: "FrameworkC", path: .relativeToManifest("Frameworks/FrameworkC"))
```

### 条件依赖

```swift
dependencies: [
    // 仅 iOS
    .target(name: "iOSFramework", condition: .when([.ios])),

    // 仅 macOS
    .target(name: "MacFramework", condition: .when([.macos])),

    // 多条件
    .target(name: "SharedFramework", condition: .when([.ios, .macos])),

    // 多个条件
    .target(
        name: "SpecificFramework",
        condition: .when([.iOS, .device] /* 仅 iOS 设备 */)
    ),
]
```

### 嵌入式 SPM 包

```swift
// 在 Package.swift 中定义
// 在 Project.swift 中
packages: [
    .package(path: "LocalSwiftPackage"),
]

targets: [
    .target(
        name: "App",
        dependencies: [
            // 运行时嵌入
            .package(product: "LocalSwiftPackage", type: .runtimeEmbedded),

            // 静态链接
            .package(product: "LocalSwiftPackage", type: .static),

            // 动态链接
            .package(product: "LocalSwiftPackage", type: .dynamic),
        ]
    ),
]
```

### XCFramework 依赖

```swift
// 在 Package.swift 中定义本地 XCFramework
// Project.swift 中使用
dependencies: [
    .external(name: "MyXCFramework"),
]
```

### Framework 依赖

```swift
dependencies: [
    // 本地 Framework
    .framework(path: "Frameworks/MyFramework.framework"),

    // 系统框架
    .sdk(name: "SwiftUI", type: .framework),
    .sdk(name: "c++", type: .library, status: .required),
]
```

---

## 构建脚本

### Pre-Scripts（编译前）

```swift
scripts: [
    // 使用外部工具
    .pre(
        tool: "/bin/echo",
        arguments: ["\"开始编译\""],
        name: "开始提示",
        inputPaths: ["Sources/**/*.swift"],
        outputPaths: ["$(DERIVED_FILE_DIR)/output.txt"]
    ),

    // 运行脚本文件
    .pre(
        path: "scripts/swiftlint.sh",
        name: "SwiftLint",
        inputFileListPaths: ["inputs.xcfilelist"],
        dependencyFile: "$TEMP_DIR/dependencies.d"
    ),

    // 内联脚本
    .pre(
        script: """
        echo "Running SwiftLint..."
        swiftlint lint --quiet
        """,
        name: "SwiftLint",
        basedOnDependencyAnalysis: false  // 每次都运行
    ),
]
```

### Post-Scripts（编译后）

```swift
scripts: [
    // 普通后置脚本
    .post(
        script: "echo '编译完成'",
        name: "编译完成提示"
    ),

    // 仅 Archive 时运行
    .post(
        script: "echo 'Archive 构建'",
        name: "Archive 提示",
        runForInstallBuildsOnly: true
    ),

    // 使用外部工具
    .post(
        tool: "/usr/bin/say",
        arguments: ["\"构建成功\""],
        name: "语音提示"
    ),
]
```

### 脚本最佳实践

```swift
// 1. 使用 inputPaths/inputFileListPaths 实现增量构建
.pre(
    path: "scripts/lint.sh",
    name: "Lint",
    inputPaths: ["Sources/**/*.swift"],  // 仅当这些文件变化时运行
    outputPaths: ["$(DERIVED_FILE_DIR)/lint.output"]
)

// 2. 使用 dependencyFile 追踪依赖
.pre(
    path: "scripts/codegen.sh",
    name: "Code Generation",
    inputFileListPaths: ["inputs.xcfilelist"],
    dependencyFile: "$TEMP_DIR/codegen.d"
)

// 3. 控制脚本执行频率
.pre(
    script: "swiftlint",
    name: "SwiftLint",
    basedOnDependencyAnalysis: true  // 基于依赖分析（默认）
)
```

---

## Scheme 配置

### 基本 Scheme

```swift
schemes: [
    .scheme(
        name: "MyApp",
        shared: true,  // 共享给团队
        buildAction: .buildAction(targets: ["MyApp"]),
        testAction: .targets([.testableTarget("MyAppTests")]),
        runAction: .runAction(executable: "MyApp"),
        archiveAction: .archiveAction(configuration: .release)
    ),
]
```

### 构建 Action

```swift
scheme(
    buildAction: .buildAction(
        targets: ["MyApp", "MyFramework"],

        // 构建前操作
        preActions: [
            .executionAction(
                title: "构建前检查",
                scriptText: "swiftlint",
                target: "MyApp"
            ),
        ],

        // 构建后操作
        postActions: [
            .executionAction(
                title: "构建完成",
                scriptText: "echo 'Done!'",
                target: "MyApp"
            ),
        ],

        // 失败时是否运行 post-actions
        runPostActionsOnFailure: false
    ),
)
```

### 测试 Action

```swift
testAction: .targets(
    [
        .testableTarget(
            target: "MyAppTests",
            parallelization: .enabled,       // 并行测试
            randomExecutionOrder: .enabled,  // 随机顺序
            skipTestSpecs: ["Tests/flaky/*"] // 跳过特定测试
        ),
    ],

    // 测试选项
    options: .options(
        language: "zh-Hans",
        region: "CN",
        coverageLevel: .ordinary,
        onlyEnabled: false  // 运行禁用的测试
    ),

    // 使用测试计划
    testPlans: ["Tests/TestPlans/*.xctestplan"],

    // 测试前/后操作
    preActions: [],
    postActions: [],

    // 覆盖默认测试超时
    timeout: 120
)
```

### 运行 Action

```swift
runAction: .runAction(
    executable: "MyApp",

    // 启动参数
    arguments: .arguments(
        environmentVariables: [
            "API_BASE_URL": .environmentVariable(value: "https://api.example.com"),
            "DEBUG": "1",
        ],
        launchArguments: [
            .launchArgument(name: "--enable-testing", isEnabled: true),
            .launchArgument(name: "--mock-api", isEnabled: false),
        ]
    ),

    // 运行选项
    options: .options(
        storeKitConfigurationPath: "Configuration/StoreKit.storekit",
        simulatedLocation: .tokyo,
        enableGPUFrameCaptureMode: .metal,
        language: "zh-Hans",
        region: "CN"
    ),

    // 诊断选项
    diagnosticsOptions: .options(
        mainThreadCheckerEnabled: true,
        gpuValidationMode: .enabled,
        mallocScribble: true,
        mallocGuardEdges: true,
        zombieObjects: true
    ),

    // 自定义 LLDB 初始化文件
    customLLDBInitFile: "Scripts/lldbinit",

    // 可执行配置
    executable: .projectTarget("MyApp")  // 或 .constant("MyApp")
)
```

### 模拟位置

```swift
// 预设位置
simulatedLocation: .tokyo
simulatedLocation: .rioDeJaneiro
simulatedLocation: .johannesburg
simulatedLocation: .disabled

// 自定义 GPX 文件
simulatedLocation: .custom(gpxFile: "Resources/Location.gpx")
```

### Archive Action

```swift
archiveAction: .archiveAction(
    configuration: .release,
    preActions: [],
    postActions: [],
    customArchiveName: "MyApp-$(VERSION)-$(BUILD_NUMBER)",
    revealArchiveInOrganizer: true
)
```

### 隐藏 Scheme

```swift
.scheme(
    name: "InternalTests",
    hidden: true,  // 不在 Xcode 中显示
    buildAction: .buildAction(targets: ["MyApp"]),
    testAction: .targets([.testableTarget("InternalTests")])
)
```

---

## Settings 配置

### 基础设置

```swift
settings: .settings(
    base: [
        // 部署目标
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "MACOSX_DEPLOYMENT_TARGET": "14.0",

        // 代码签名
        "CODE_SIGN_STYLE": "Automatic",
        "CODE_SIGN_IDENTITY": "Apple Development",
        "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",

        // Swift 版本
        "SWIFT_VERSION": "5.9",

        // 优化级别
        "SWIFT_OPTIMIZATION_LEVEL": "-Onone",  // Debug
        "SWIFT_OPTIMIZATION_LEVEL": "-O",      // Release

        // 模块化
        "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",  // 框架分发

        // 其他
        "TARGETED_DEVICE_FAMILY": "1,2",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
        "ENABLE_PREVIEWS": "YES",
    ]
)
```

### Debug/Release 特定设置

```swift
settings: .settings(
    configurations: [
        .debug(
            name: "Debug",
            settings: [
                "ENABLE_TESTABILITY": "YES",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG MOCKING",
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
            ],
            xcconfig: "Configs/Debug.xcconfig"  // 可选
        ),
        .release(
            name: "Release",
            settings: [
                "SWIFT_OPTIMIZATION_LEVEL": "-Owholemodule",
                "OTHER_CODE_SIGN_FLAGS": "--timestamp --deep",  // macOS
                "ENABLE_HARDENED_RUNTIME": true,  // macOS
            ]
        ),
    ]
)
```

### 自定义配置

```swift
configurations: [
    .debug(name: .debug),
    .release(name: .release),

    // Staging 配置
    .debug(
        name: "Staging",
        settings: [
            "STAGING": "YES",
            "API_BASE_URL": "https://staging.api.com",
        ]
    ),

    // Production 配置
    .release(
        name: "Production",
        settings: [
            "PRODUCTION": "YES",
            "API_BASE_URL": "https://api.com",
        ]
    ),
]
```

### Settings 合并

```swift
// 使用 SettingsDictionary.merging 合并设置
let baseSettings: SettingsDictionary = [
    "SWIFT_VERSION": "5.9",
]

let debugSettings = baseSettings.merging([
    "ENABLE_TESTABILITY": "YES",
])

settings: .settings(
    base: debugSettings,
    configurations: []
)
```

### 平台特定设置

```swift
settings: .settings(
    base: [
        // 通用设置
        "SWIFT_VERSION": "5.9",

        // iOS 特定
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
        "CODE_SIGN_ENTITLEMENTS[sdk=iphone*]": "Entitlements/iOS.entitlements",

        // macOS 特定
        "MACOSX_DEPLOYMENT_TARGET": "14.0",
        "CODE_SIGN_ENTITLEMENTS[sdk=macosx*]": "Entitlements/macOS.entitlements",
    ]
)
```

---

## Info.plist 配置

### 基础配置

```swift
infoPlist: .extendingDefault(
    with: [
        "CFBundleDisplayName": "我的应用",
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleVersion": "1",

        // 启动屏幕
        "UILaunchStoryboardName": "LaunchScreen",

        // SwiftUI 启动屏幕
        "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": "",
        ],
    ]
)
```

### 屏幕方向

```swift
"UISupportedInterfaceOrientations": [
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
    "UIInterfaceOrientationPortraitUpsideDown",
],

// iPad 特定
"UISupportedInterfaceOrientations~ipad": [
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationPortraitUpsideDown",
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
],
```

### URL Schemes（深度链接）

```swift
"CFBundleURLTypes": [
    [
        "CFBundleTypeRole": "Viewer",
        "CFBundleURLName": "com.example.app",
        "CFBundleURLSchemes": ["myapp", "myapp-alt"],
        "CFBundleURLIconFile": "Icon",
    ]
],
```

### 隐私权限

```swift
// 相册
"NSPhotoLibraryUsageDescription": "需要访问相册以选择照片",
"NSPhotoLibraryAddUsageDescription": "需要保存照片到相册",

// 相机
"NSCameraUsageDescription": "需要使用相机拍摄照片",

// 麦克风
"NSMicrophoneUsageDescription": "需要使用麦克风录音",

// 位置
"NSLocationWhenInUseUsageDescription": "需要获取您的位置信息",
"NSLocationAlwaysAndWhenInUseUsageDescription": "需要在后台获取您的位置信息",

// 联系人
"NSContactsUsageDescription": "需要访问联系人",

// Face ID / Touch ID
"NSFaceIDUsageDescription": "需要使用 Face ID 进行身份验证",

// 广告追踪
"NSUserTrackingUsageDescription": "需要追踪您的活动以提供个性化广告",

// Siri
"NSSiriUsageDescription": "需要使用 Siri 进行快捷操作",

// 日历
"NSCalendarsUsageDescription": "需要访问日历",

// 提醒事项
"NSRemindersUsageDescription": "需要访问提醒事项",

// 文件
"NSDocumentsFolderUsageDescription": "需要访问文档文件夹",
"NSDesktopFolderUsageDescription": "需要访问桌面文件夹",
"NSDownloadsFolderUsageDescription": "需要访问下载文件夹",
```

### 后台模式

```swift
"UIBackgroundModes": [
    "audio",                 // 音频播放
    "location",              // 位置更新
    "fetch",                 // 后台下载
    "remote-notification",   // 远程通知
    "bluetooth-central",     // 蓝牙中心设备
    "bluetooth-peripheral",  // 蓝牙外设
    "processing",            // 后台处理
    "newsstand-download",    // 杂志下载
    "externalAccessory",     // 外部配件
],
```

### Scene 配置（iOS 13+）

```swift
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
```

### App Clip 配置

```swift
// App Clip Info.plist
infoPlist: .extendingDefault(
    with: [
        "CFBundleDisplayName": "App Clip",
        "WKAppBundleIdentifier": "com.example.App.Clip",
        "WKApplicationExtensions": [
            "com.apple.NSExtension.ActivationType": true
        ]
    ]
)
```

### 权限文件

```swift
.target(
    name: "MyApp",
    entitlements: .dictionary([
        "aps-environment": "development",  // 推送通知
        "keychain-access-groups": ["com.example.app"],
        "com.apple.security.app-groups": ["group.com.example.app"],
        "com.apple.security.application-groups": ["group.com.example.app"],
    ])
)

// 或使用文件
entitlements: "MyApp/Entitlements/MyApp.entitlements"
```

---

## 资源管理

### Glob 模式

```swift
sources: [
    // 基础模式
    "Sources/**",

    // Glob 模式
    .glob(pattern: "Sources/**/*.swift", excluding: ["**/*+Unused.swift"]),

    // 排除多个
    .glob(
        pattern: "Sources/**/*.swift",
        excluding: ["**/*+Unused.swift", "**/*Generated.swift"]
    ),
]

resources: [
    .glob(
        pattern: "Resources/**",
        excluding: ["**/*.lproj", "**/Internal/**"]
    ),
]
```

### 条件资源

```swift
sources: [
    // 通用源文件
    "Sources/Common/**",

    // iOS 特定
    .glob(
        pattern: "Sources/iOS/**",
        inclusionCondition: .when([.ios])
    ),

    // macOS 特定
    .glob(
        pattern: "Sources/macOS/**",
        inclusionCondition: .when([.macos])
    ),
]
```

### CoreData

```swift
// CoreData 模型
coreDataModels: [
    .coreDataModel("Resources/Model.xcdatamodeld", currentVersion: "1"),
    .coreDataModel("Resources/Model2.xcdatamodeld"),  // 自动检测版本
]

// 资源合成器
resourceSynthesizers: .default + [
    .coreData(),
    .strings(),
    .assets(),
]
```

### 资源合成器

```swift
resourceSynthesizers: .default + [
    // 内置类型
    .strings(),      // Localizable.strings
    .assets(),       // Assets.xcassets
    .coreData(),     // .xcdatamodeld
    .files(),        // 任意文件

    // 自定义类型
    .custom(
        type: "json",
        parser: .directory(
            selector: "Entries",
            extensions: ["json"]
        ),
        extensions: ["json"]
    ),
]
```

### Buildable Folders

```swift
// 用于大项目的模块化构建
.target(
    name: "MyFramework",
    buildableFolders: [
        .folder("Sources/ModuleA"),
        .folder("Sources/ModuleB"),
    ]
)
```

### Additional Files

```swift
// 项目中显示但不是编译目标的文件
additionalFiles: [
    "README.md",
    "CHANGELOG.md",
    "Documentation/**",
    .folderReference(path: "Designs"),
    .glob(pattern: "**/.*.yml", excluding: ["Internal/**"]),
]
```

---

## ProjectDescriptionHelpers

### 创建辅助函数

```swift
// Project+Templates.swift
import ProjectDescription

extension Project {
    /// 创建 App 项目
    public static func app(
        name: String,
        destinations: Destinations,
        additionalTargets: [String] = []
    ) -> Project {
        var targets = makeAppTargets(
            name: name,
            destinations: destinations,
            dependencies: additionalTargets.map { .target(name: $0) }
        )
        targets += additionalTargets.flatMap { makeFrameworkTargets(name: $0, destinations: destinations) }

        return Project(
            name: name,
            organizationName: "tuist.io",
            targets: targets
        )
    }

    /// 创建 Framework 项目
    public static func framework(
        name: String,
        destinations: Destinations,
        dependencies: [TargetDependency] = []
    ) -> Project {
        Project(
            name: name,
            targets: [
                .target(
                    name: name,
                    destinations: destinations,
                    product: .framework,
                    bundleId: "dev.tuist.\(name)",
                    infoPlist: .default,
                    sources: ["Sources/**"],
                    dependencies: dependencies
                ),
                .target(
                    name: "\(name)Tests",
                    destinations: destinations,
                    product: .unitTests,
                    bundleId: "dev.tuist.\(name)Tests",
                    infoPlist: .default,
                    sources: "Tests/**",
                    dependencies: [.target(name: name)]
                ),
            ]
        )
    }

    // MARK: - Private

    private static func makeAppTargets(
        name: String,
        destinations: Destinations,
        dependencies: [TargetDependency]
    ) -> [Target] {
        let appTarget: Target = .target(
            name: name,
            destinations: destinations,
            product: .app,
            bundleId: "dev.tuist.\(name)",
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "LaunchScreen",
            ]),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )

        let testTarget: Target = .target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "dev.tuist.\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [.target(name: name)]
        )

        return [appTarget, testTarget]
    }

    private static func makeFrameworkTargets(
        name: String,
        destinations: Destinations
    ) -> [Target] {
        let frameworkTarget: Target = .target(
            name: name,
            destinations: destinations,
            product: .framework,
            bundleId: "dev.tuist.\(name)",
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            dependencies: []
        )

        let testTarget: Target = .target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "dev.tuist.\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [.target(name: name)]
        )

        return [frameworkTarget, testTarget]
    }
}
```

### 使用辅助函数

```swift
// Project.swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    name: "MyApp",
    destinations: .iOS,
    additionalTargets: ["FeatureA", "FeatureB"]
)
```

### 创建 Target 辅助函数

```swift
// Target+Helpers.swift
import ProjectDescription

extension Target {
    /// 创建基础 Framework Target
    static func framework(
        name: String,
        destinations: Destinations,
        dependencies: [TargetDependency] = [],
        isStatic: Bool = false
    ) -> Target {
        .target(
            name: name,
            destinations: destinations,
            product: isStatic ? .staticFramework : .framework,
            bundleId: "dev.tuist.\(name)",
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            dependencies: dependencies
        )
    }

    /// 创建测试 Target
    static func tests(
        name: String,
        destinations: Destinations,
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "dev.tuist.\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: dependencies
        )
    }
}
```

### 环境变量辅助函数

```swift
// Environment+Helpers.swift
import ProjectDescription

extension Environment {
    /// 获取 Bundle ID
    static var bundleId: String {
        switch Environment.environmentVariable(named: "ENVIRONMENT") {
        case "staging": return "com.example.app.staging"
        case "production": return "com.example.app"
        default: return "com.example.app.dev"
        }
    }

    /// 获取 API 基础 URL
    static var apiBaseUrl: String {
        switch Environment.environmentVariable(named: "ENVIRONMENT") {
        case "staging": return "https://staging-api.example.com"
        case "production": return "https://api.example.com"
        default: return "https://dev-api.example.com"
        }
    }
}
```

### Settings 辅助函数

```swift
// Settings+Helpers.swift
import ProjectDescription

extension Settings {
    /// Debug 设置
    static func debug(
        settings: SettingsDictionary = [:],
        xcconfig: String? = nil
    ) -> Configuration {
        .debug(
            name: "Debug",
            settings: [
                "ENABLE_TESTABILITY": "YES",
                "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
            ].merging(settings),
            xcconfig: xcconfig.flatMap { .file(path: $0) }
        )
    }

    /// Release 设置
    static func release(
        settings: SettingsDictionary = [:],
        xcconfig: String? = nil
    ) -> Configuration {
        .release(
            name: "Release",
            settings: [
                "SWIFT_OPTIMIZATION_LEVEL": "-Owholemodule",
            ].merging(settings),
            xcconfig: xcconfig.flatMap { .file(path: $0) }
        )
    }
}
```

---

## 插件与模板

### 创建插件

```swift
// Plugin.swift
@preconcurrency import ProjectDescription

let plugin = Plugin(name: "MyPlugin")
```

### 使用插件

```swift
// Tuist.swift
import ProjectDescription

let tuist = Tuist(
    project: .tuist(),
    plugins: [
        .local(path: "./Plugins/MyPlugin"),
        // 或
        .git(url: "https://github.com/example/tuist-plugin", from: "1.0.0"),
    ]
)
```

### 创建模板

```swift
// Templates/example/template.swift
import ProjectDescription
import ProjectDescriptionHelpers

let template = Template(
    description: "Example template",
    items: [
        .item(
            path: "./Sources/Generated.swift",
            contents: .string("""
            // Generated file
            import Foundation

            let projectName = "\(Constants.name)"
            """)
        ),
        .file(
            path: "./Sources/GeneratedFile.swift",
            templatePath: "./Templates/file.stencil"
        ),
    ]
)
```

### 使用模板

```swift
// 在 Project.swift 中
import ProjectDescriptionHelpers

.target(
    name: "App",
    // ...
    dependencies: [
        .template(path: "./Tuist/Templates/example")
    ]
)
```

### Stencil 模板

```swift
// Templates/model.stencil
import Foundation

struct {{ name }} {
    {% for attribute in attributes %}
    var {{ attribute.name }}: {{ attribute.type }}
    {% endfor %}

    init({% for attribute in attributes %}
        {{ attribute.name }}: {{ attribute.type }}{% if not for.last %}, {% endif %}
    {% endfor %}) {
        {% for attribute in attributes %}
        self.{{ attribute.name }} = {{ attribute.name }}
        {% endfor %}
    }
}

// 使用
let template = Template(
    description: "Model generator",
    attributes: [
        .attribute(name: "name", value: "User"),
        .attribute(name: "attributes", value: [
            ["name": "id", "type": "Int"],
            ["name": "name", "type": "String"],
            ["name": "email", "type": "String"],
        ])
    ]
)
```

---

## 高级技巧

### 构建规则

```swift
.target(
    name: "MyApp",
    buildRules: [
        .buildRule(
            name: "Process InfoPlist.strings",
            fileType: .sourceFilesWithNamesMatching,
            filePatterns: "*/InfoPlist.strings",
            compilerSpec: .customScript,
            inputFiles: ["$(INPUT_FILE_PATH)"],
            outputFiles: ["${DERIVED_FILES_DIR}/${INPUT_FILE_REGION_PATH_COMPONENT}/${INPUT_FILE_NAME}"],
            script: "cp \"$SCRIPT_INPUT_FILE_0\" \"$SCRIPT_OUTPUT_FILE_0\""
        ),
    ]
)
```

### 多项目依赖

```swift
// 主项目
let project = Project(
    name: "MainApp",
    targets: [
        .target(
            name: "App",
            dependencies: [
                // 引用其他项目
                .project(target: "FrameworkA", path: "../Frameworks/FrameworkA"),
                .project(target: "FrameworkB", path: "../Frameworks/FrameworkB"),
            ]
        ),
    ],
    additionalFiles: [
        // 在 Xcode 中显示其他项目
        .folderReference(path: "../Frameworks"),
    ]
)
```

### Cache 配置

```swift
// Target 元数据用于缓存标记
.target(
    name: "MyApp",
    metadata: .metadata(tags: [
        "cacheable",          // 可缓存
        "domain:ui",         // 领域标签
        "layer:feature",     // 层级标签
    ])
)

// 在 CacheProfiles 中定义缓存策略
// Tuist/CacheProfiles.swift
import ProjectDescription

extension CacheProfiles {
    static var standard: CacheProfile {
        .cacheProfile(
            name: "standard",
            configuration: .cacheProfile(
                cache: .cache(
                    controllers: [:],
                    // ...
                )
            )
        )
    }
}
```

### 测试主机配置

```swift
.target(
    name: "UITests",
    product: .uiTests,
    settings: .settings(
        base: SettingsDictionary().merging([
            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/TestHost.app/TestHost"
        ])
    ),
    dependencies: [
        .target(name: "MyApp"),
        .project(target: "TestHost", path: "../Helpers"),
    ]
)
```

### Workspace 配置

```swift
// WorkspaceDescription.swift
import ProjectDescription

let workspace = Workspace(
    name: "MyWorkspace",
    projects: [
        "Projects/App",
        "Projects/Frameworks",
    ],
    schemes: []  // Workspace 级别的 schemes
)
```

### 条件编译

```swift
// 在 settings 中
settings: .settings(
    configurations: [
        .debug(
            name: "Debug",
            settings: [
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG MOCKING",
            ]
        ),
    ]
)

// 在代码中使用
#if DEBUG
    print("Debug mode")
#elseif STAGING
    print("Staging mode")
#else
    print("Production mode")
#endif
```

### 批量生成 Target

```swift
// 用于大型项目的自动化 Target 生成
func target(name: String) -> Target {
    .target(
        name: name,
        destinations: .iOS,
        product: .app,
        bundleId: "dev.tuist.\(name)",
        infoPlist: .file(path: .relativeToManifest("Info.plist")),
        sources: .paths([.relativeToManifest("Sources/**")]),
        settings: .settings(
            base: ["CODE_SIGN_IDENTITY": "", "CODE_SIGNING_REQUIRED": "NO"]
        )
    )
}

let project = Project(
    name: "App",
    targets: (1 ... 300).map { target(name: "App\($0)") }
)
```

### 自定义 xcconfig

```swift
settings: .settings(
    configurations: [
        .debug(
            name: "Debug",
            settings: [:],
            xcconfig: "Configs/Debug.xcconfig"  // 使用 xcconfig 文件
        ),
    ]
)
```

### 扩展配置完整示例

```swift
.target(
    name: "WidgetExtension",
    destinations: .iOS,
    product: .appExtension,
    bundleId: "com.example.App.WidgetExtension",
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "我的小组件",
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
        ],
    ]),
    sources: "WidgetExtension/Sources/**",
    resources: "WidgetExtension/Resources/**",
    dependencies: [
        .target(name: "App"),
        .target(name: "SharedFramework"),
    ]
)

.target(
    name: "NotificationServiceExtension",
    destinations: .iOS,
    product: .appExtension,
    bundleId: "com.example.App.NotificationServiceExtension",
    infoPlist: .extendingDefault(with: [
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
            "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService",
        ],
    ]),
    sources: "NotificationServiceExtension/**"
)

.target(
    name: "ShareExtension",
    destinations: .iOS,
    product: .appExtension,
    bundleId: "com.example.App.ShareExtension",
    infoPlist: .extendingDefault(with: [
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.share-services",
            "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).ShareViewController",
        ],
    ]),
    sources: "ShareExtension/**",
    resources: "ShareExtension/Resources/**"
)
```

### App Clip 完整示例

```swift
.target(
    name: "AppClip",
    destinations: .iOS,
    product: .appClip,
    bundleId: "com.example.App.Clip",
    infoPlist: .default,
    sources: "AppClip/Sources/**",
    entitlements: "AppClip/Entitlements/AppClip.entitlements",
    dependencies: [
        .target(name: "App"),
        .target(name: "Framework"),
        .target(name: "Widget"),
    ]
)

.target(
    name: "AppClipTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "com.example.App.ClipTests",
    infoPlist: .default,
    sources: "AppClipTests/Tests/**",
    dependencies: [
        .target(name: "AppClip"),
    ]
)
```

---

## 最佳实践总结

### 1. 项目组织

```
MyApp/
├── Projects/
│   ├── App/
│   │   └── Project.swift
│   └── Frameworks/
│       └── Project.swift
├── Tuist/
│   ├── ProjectDescriptionHelpers/
│   │   └── Project+Templates.swift
│   ├── CacheProfiles.swift
│   └── Tuist.swift
├── WorkspaceDescription.swift
└── .tuist-supported-version
```

### 2. 使用辅助函数

创建可复用的辅助函数来减少重复代码：

```swift
// Project+Helpers.swift
extension Project {
    static func app(
        name: String,
        destinations: Destinations,
        dependencies: [TargetDependency] = []
    ) -> Project {
        // 统一配置
    }
}

// 使用
let project = Project.app(name: "MyApp", destinations: .iOS)
```

### 3. 模块化架构

使用多个 Framework 来组织代码：

```swift
let project = Project.app(
    name: "MyApp",
    destinations: .iOS,
    additionalTargets: [
        "AuthFeature",
        "HomeFeature",
        "ProfileFeature",
        "Networking",
        "UIComponents",
    ]
)
```

### 4. 条件编译

使用环境变量和配置来管理不同环境：

```swift
let bundleId = Environment.env == .string("production")
    ? "com.example.app"
    : "com.example.app.dev"
```

### 5. 脚本最佳实践

- 使用 `inputPaths` 和 `outputPaths` 实现增量构建
- 使用 `dependencyFile` 追踪依赖关系
- 设置合理的超时时间
- 提供清晰的错误消息

### 6. 测试配置

- 为不同测试类型创建专门的 Scheme
- 使用并行测试加速
- 配置合理的超时和重试策略

### 7. 缓存优化

- 使用 `metadata.tags` 标记可缓存的 Target
- 配置合理的缓存策略
- 避免不必要的缓存失效

---

## 参考资源

- [Tuist 官方文档](https://tuist.dev/docs/)
- [Tuist GitHub](https://github.com/tuist/tuist)
- [ProjectDescription API](https://tuist.dev/docs/en/api/projectdescription/)
- [社区模板](https://github.com/tuist/tuist/tree/main/examples)

---

**最后更新**: 2026-02-27
**Tuist 版本**: 3.18.0
