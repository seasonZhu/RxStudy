# Tuist iOS 项目模板

这是一个功能完整的 Tuist iOS 项目模板，包含详细注释的配置文件。所有配置选项都已预先添加并注释，用户只需取消注释即可使用。

## 📚 相关文档

| 文档 | 说明 |
|------|------|
| **README.md** | 本文件 - 快速开始、基础配置说明 |
| [TUIST_CONFIG_GUIDE.md](./TUIST_CONFIG_GUIDE.md) | 完整配置参考 - 220+ 官方示例提取的配置技巧 |
| [TUIST_INSTALLATION_GUIDE.md](./TUIST_INSTALLATION_GUIDE.md) | Tuist 安装、升级、卸载指南 |

> 💡 **新用户建议**：先阅读本文了解基础，然后查阅 [TUIST_CONFIG_GUIDE.md](./TUIST_CONFIG_GUIDE.md) 了解完整配置选项

## 📁 目录结构

```
Template/
├── Project.swift                # Tuist 项目配置（带完整注释）
├── Tuist/                       # Tuist 配置目录
│   ├── Tuist.swift             # Tuist 配置文件
│   └── Package.swift           # SPM 依赖配置（依赖已注释）
├── AppTemplate/                # 应用源码
│   ├── Sources/                # 源代码文件
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   └── ViewController.swift
│   └── Resources/              # 资源文件
│       └── LaunchScreen.storyboard
└── README.md                   # 本文件
```

## 🚀 快速开始

### 1. 复制模板到新位置

```bash
# 复制整个 Template 文件夹到你的项目目录
cp -r /path/to/Template /path/to/MyProject
cd /path/to/MyProject

# 或者直接把外层的 Template 进行改名
```

### 2. 修改基本配置

编辑 `Project.swift`，修改以下基本信息：

```swift
// 项目名称（第 16 行）
name: "MyApp",

// 组织标识符（第 17 行）
organizationName: "com.mycompany",

// Bundle ID（第 117 行）
bundleId: "com.mycompany.MyApp",

// Team ID（第 50 行）
"DEVELOPMENT_TEAM": .string("YOUR_TEAM_ID"),
```

### 3. 生成 Xcode 项目

```bash
# 首次使用 - 安装完整依赖
tuist install

# 生成 Xcode 项目
tuist generate

# 打开项目（Tuist 生成 workspace）
open AppTemplate.xcworkspace
```

> 💡 **提示**：日常开发中可以直接运行 `tuist generate`，它会自动处理依赖更新。

## 📖 配置详解

### 项目选项 (Project Options)

#### 自动 Scheme 配置

```swift
options: .options(
    // 启用自动 Scheme 生成
    automaticSchemesOptions: .enabled(
        defaultScheme: .schemeName("AppTemplate"),
        testTarget: .testableTarget(
            target: "AppTemplateTests",
            parallelization: .enabled
        )
    ),

    // 或禁用自动生成，手动配置 Scheme
    automaticSchemesOptions: .disabled,

    textSettings: .textSettings(
        indentWidth: 4,
        tabWidth: 4
    )
)
```

### 项目设置 (Project Settings)

#### 基础设置

```swift
settings: .settings(
    base: [
        // iOS 部署目标
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",

        // 代码签名
        "CODE_SIGN_STYLE": "Automatic",
        "CODE_SIGN_IDENTITY": "Apple Development",

        // 设备支持
        "TARGETED_DEVICE_FAMILY": "1,2",  // 1=iPhone, 2=iPad

        // SwiftUI 预览
        "ENABLE_PREVIEWS": "YES",
    ]
)
```

#### Debug/Release 特定设置

```swift
debug: [
    "ENABLE_TESTABILITY": "YES",        // 允许测试访问 internal
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone", // 无优化
],

release: [
    // macOS 应用需要
    "OTHER_CODE_SIGN_FLAGS": "--timestamp --deep",
    "ENABLE_HARDENED_RUNTIME": true,
    "SWIFT_OPTIMIZATION_LEVEL": "-Owholemodule",
]
```

#### 自定义配置

```swift
configurations: [
    .debug(name: .debug),
    .release(name: .release),
    // 添加自定义配置
    .debug(name: "Staging", settings: ["STAGING": "YES"]),
    .release(name: "Production", settings: ["PRODUCTION": "YES"]),
]
```

### Target 配置

#### 主 App Target

```swift
.target(
    name: "AppTemplate",
    destinations: .iOS,                    // 目标平台
    product: .app,                         // 产品类型
    productName: "AppTemplate",            // 产品显示名称
    bundleId: "com.example.AppTemplate",   // Bundle ID
    deploymentTargets: .iOS("17.0"),       // 部署目标
    // ...
)
```

#### 产品类型 (Product Types)

| 类型 | 说明 | 用途 |
|------|------|------|
| `.app` | 应用程序 | 主应用 |
| `.appClip` | App Clip | 轻量级应用 (iOS 14+) |
| `.framework` | 动态框架 | 可共享代码 |
| `.staticFramework` | 静态框架 | 静态链接代码 |
| `.unitTests` | 单元测试 | 单元测试目标 |
| `.uiTests` | UI 测试 | UI 测试目标 |
| `.appExtension` | 应用扩展 | Widget、通知等 |
| `.stickerPackExtension` | 贴纸包 | iMessage 贴纸 |
| `.messagesExtension` | 消息扩展 | iMessage 扩展 |
| `.extensionKitExtension` | Extension Kit | App Intents (iOS 16+) |
| `.bundle` | 资源包 | 纯资源目标 |

#### 源码配置

```swift
sources: [
    "AppTemplate/Sources/**",

    // Glob 模式（更灵活）
    .glob(pattern: "Sources/**/*.swift", excluding: ["**/*+Unused.swift"]),

    // 条件源文件（仅特定平台）
    .glob(pattern: "Sources/iOS/**", inclusionCondition: .when([.ios])),
]
```

#### 资源配置

```swift
resources: [
    "AppTemplate/Resources/**",

    // Glob 模式
    .glob(pattern: "Resources/**", excluding: ["**/*.lproj"]),

    // 条件资源
    .glob(pattern: "Resources/iOS/**", inclusionCondition: .when([.ios])),
]
```

#### CoreData 配置

```swift
coreDataModels: [
    .coreDataModel("Resources/Model.xcdatamodeld", currentVersion: "1"),
    .coreDataModel("Resources/Model2.xcdatamodeld"), // 自动检测版本
],

// 资源合成器
resourceSynthesizers: .default + [.coreData()]
```

#### 构建脚本 (Build Scripts)

```swift
scripts: [
    // 编译前执行
    .pre(
        tool: "/bin/echo",
        arguments: ["\"开始编译\""],
        name: "开始编译提示",
        inputPaths: ["Sources/**/*.swift"],       // 用于增量构建
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
        script: "swiftlint lint --quiet",
        name: "SwiftLint"
    ),

    // 编译后执行
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
]
```

#### 条件依赖

```swift
dependencies: [
    // 仅 iOS
    .target(name: "iOSOnlyFramework", condition: .when([.ios])),

    // 仅 macOS
    .target(name: "MacOnlyFramework", condition: .when([.macos])),

    // 多平台
    .target(name: "SharedFramework"),
]
```

### Info.plist 配置

#### 常用配置

```swift
infoPlist: .extendingDefault(
    with: [
        // 应用信息
        "CFBundleDisplayName": "我的应用",
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleVersion": "1",

        // 启动屏幕
        "UILaunchStoryboardName": "LaunchScreen",

        // 屏幕方向
        "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationLandscapeLeft",
        ],

        // 网络安全
        "NSAppTransportSecurity": [
            "NSAllowsArbitraryLoads": true
        ],

        // URL Schemes（深度链接）
        "CFBundleURLTypes": [
            [
                "CFBundleTypeRole": "Viewer",
                "CFBundleURLName": "com.example.AppTemplate",
                "CFBundleURLSchemes": ["myapp"],
            ]
        ],
    ]
)
```

#### 隐私权限描述

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

// Face ID
"NSFaceIDUsageDescription": "需要使用 Face ID 进行身份验证",

// 广告追踪
"NSUserTrackingUsageDescription": "需要追踪您的活动以提供个性化广告",
```

#### 后台模式

```swift
"UIBackgroundModes": [
    "audio",              // 音频播放
    "location",           // 位置更新
    "fetch",              // 后台下载
    "remote-notification", // 远程通知
    "bluetooth-central",  // 蓝牙中心设备
    "processing",         // 后台处理
]
```

### Scheme 配置

#### 完整 Scheme 示例

```swift
.scheme(
    name: "AppTemplate",
    shared: true,  // 是否共享给团队

    // 构建配置
    buildAction: .buildAction(
        targets: ["AppTemplate"],
        preActions: [
            .executionAction(
                title: "构建前检查",
                scriptText: "echo '开始构建...'",
                target: "AppTemplate"
            ),
        ],
        postActions: [
            .executionAction(
                title: "构建完成",
                scriptText: "echo '构建完成！'",
                target: "AppTemplate"
            ),
        ],
        runPostActionsOnFailure: false
    ),

    // 测试配置
    testAction: .targets(
        [
            .testableTarget(
                target: "AppTemplateTests",
                parallelization: .enabled,      // 并行测试
                randomExecutionOrder: .enabled, // 随机执行
                simulatedLocation: .tokyo       // 模拟位置
            ),
        ],
        options: .options(
            language: "zh-Hans",
            region: "CN",
            coverageLevel: .ordinary
        ),
        // 使用测试计划
        .testPlans(["*.xctestplan"])
    ),

    // 运行配置
    runAction: .runAction(
        executable: "AppTemplate",
        options: .options(
            storeKitConfigurationPath: "Configuration/StoreKit.storekit",
            simulatedLocation: .tokyo,
            enableGPUFrameCaptureMode: .metal,
            language: "zh-Hans",
            region: "CN",
        ),
        diagnosticsOptions: .options(
            mainThreadCheckerEnabled: true,
            gpuValidationMode: .enabled,
            mallocScribble: true,
        ),
        arguments: .arguments(
            launchArguments: [
                .launchArgument(name: "--debug", isEnabled: true),
            ],
            environmentVariables: [
                "API_BASE_URL": .environmentVariable(value: "https://api.example.com"),
                "DEBUG": "1",
            ]
        )
    ),

    // Archive 配置
    archiveAction: .archiveAction(
        configuration: .release,
        customArchiveName: "AppTemplate-$(VERSION)-$(BUILD_NUMBER)",
        revealArchiveInOrganizer: true
    )
)
```

#### 模拟位置选项

```swift
// 预设位置
simulatedLocation: .tokyo
simulatedLocation: .rioDeJaneiro
simulatedLocation: .johannesburg

// 自定义 GPX 文件
simulatedLocation: .custom(gpxFile: "Resources/Location.gpx")

// 禁用
simulatedLocation: .disabled
```

## 🧩 Extension 配置示例

### Widget Extension (iOS 14+)

```swift
.target(
    name: "WidgetExtension",
    destinations: .iOS,
    product: .appExtension,
    bundleId: "com.example.AppTemplate.WidgetExtension",
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "我的小组件",
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
        ],
    ]),
    sources: "WidgetExtension/Sources/**",
    resources: "WidgetExtension/Resources/**",
    dependencies: [
        .target(name: "AppTemplate"),
    ]
)
```

### Notification Service Extension

```swift
.target(
    name: "NotificationServiceExtension",
    destinations: .iOS,
    product: .appExtension,
    bundleId: "com.example.AppTemplate.NotificationServiceExtension",
    infoPlist: .extendingDefault(with: [
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.usernotifications.service",
            "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).NotificationService",
        ],
    ]),
    sources: "NotificationServiceExtension/**"
)
```

### Share Extension

```swift
.target(
    name: "ShareExtension",
    destinations: .iOS,
    product: .appExtension,
    bundleId: "com.example.AppTemplate.ShareExtension",
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

### App Clip (iOS 14+)

```swift
.target(
    name: "AppClip",
    destinations: .iOS,
    product: .appClip,
    bundleId: "com.example.AppTemplate.Clip",
    infoPlist: .extendingDefault(
        with: [
            "CFBundleDisplayName": "App Clip",
            "WKAppBundleIdentifier": "com.example.AppTemplate.Clip",
        ]
    ),
    sources: "AppClip/**",
    dependencies: [
        .target(name: "AppTemplate"),
    ]
)
```

## 📦 常用依赖配置

### 网络层

**Tuist/Package.swift**:
```swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
]
productTypes: [
    "Alamofire": .staticFramework,
    "Moya": .staticFramework,
]
```

**Project.swift**:
```swift
dependencies: [
    .external(name: "Alamofire"),
    .external(name: "Moya"),
]
```

### RxSwift 生态

**Tuist/Package.swift**:
```swift
dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.9.0"),
]
```

**Project.swift**:
```swift
dependencies: [
    .external(name: "RxSwift"),
    .external(name: "RxCocoa"),
    .external(name: "RxRelay"),
    .external(name: "RxDataSources"),
    .external(name: "RxGesture"),
]
```

### UI 组件

**Tuist/Package.swift**:
```swift
dependencies: [
    .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.3"),
]
```

**Project.swift**:
```swift
dependencies: [
    .external(name: "SnapKit"),
    .external(name: "Kingfisher"),
]
```

### 架构框架

**Tuist/Package.swift**:
```swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
]
```

**Project.swift**:
```swift
dependencies: [
    .external(name: "ComposableArchitecture"),
]
```

## 🛠️ 常用命令

```bash
# 查看 Tuist 版本
tuist version

# 清理缓存
tuist clean

# 安装完整依赖（首次使用或添加新依赖后）
tuist install

# 生成项目（自动处理依赖）
tuist generate

# 生成并打开项目
tuist generate && open AppTemplate.xcworkspace

# 编辑项目（在 Xcode 中编辑 Project.swift）
tuist edit

# 查看项目依赖图
tuist graph

# 验证项目配置
tuist validate

# 运行测试
tuist test
```

## ⚠️ 注意事项

### 必需配置

1. **Team ID** - 必须替换为你的 Apple Developer Team ID
2. **Bundle ID** - 建议使用反向域名格式（如 `com.company.app`）
3. **部署目标** - 根据项目需求调整 iOS 版本

### 权限描述

在 Info.plist 中添加所有需要的隐私权限描述，否则应用会被拒。

### 依赖管理

1. 先在 `Tuist/Package.swift` 中添加依赖
2. 在 `productTypes` 中指定产品类型
3. 在 `Project.swift` 的 `dependencies` 中引用
4. 运行 `tuist install` 安装依赖

### 代码签名

- 开发阶段使用 Automatic 代码签名
- 发布前配置正确的 Provisioning Profile
- macOS 应用需要额外的代码签名配置

## 📚 参考资源

- [Tuist 官方文档](https://tuist.dev)
- [Tuist GitHub](https://github.com/tuist/tuist)
- [Swift Package Manager](https://swift.org/package-manager/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

## 🆘 常见问题

### Manifest not found

确保项目名称与 Target 名称一致，且目录结构正确。

### 依赖冲突

运行 `tuist clean && tuist install` 清理并重新安装依赖。

### 代码签名错误

检查 Team ID 是否正确，证书是否有效。

### 构建脚本失败

检查脚本路径是否正确，是否有执行权限。

---

**最后更新**: 2026-02-27
**Tuist 版本**: 3.18.0
