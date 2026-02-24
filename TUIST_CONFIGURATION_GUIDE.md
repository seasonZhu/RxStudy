# Tuist 配置指南

> Package.swift 与 Project.swift 配置写法使用技巧与经验总结

---

## 一、核心职责区分

### Project.swift - Tuist 项目配置主文件
- **职责**：定义 Xcode 项目结构、目标、依赖关系、编译配置
- **特点**：使用 Tuist 的 `ProjectDescription` DSL
- **位置**：项目根目录

### Package.swift - SPM 包管理文件
- **职责**：定义 Swift Package 依赖、模块、产品
- **特点**：使用 Swift Package Manager 的标准 DSL
- **位置**：根目录或 Packages 子目录下

---

## 二、Project.swift 配置技巧

### 1. 常量定义与复用（KISS/DRY 原则）

```swift
// 顶部定义常用常量
let teamId = "GZKK4Y45D3"
let organizationName = "com.lostsakura"
let deploymentTarget = "17.6"

// 在配置中复用
let project = Project(
    name: "RxStudy",
    organizationName: organizationName,
    targets: [
        .target(
            deploymentTargets: .iOS(deploymentTarget),  // 复用
            // ...
        )
    ]
)
```

### 2. 依赖声明结构化分组

```swift
dependencies: [
    // ========== RxSwift 生态 ==========  // 使用分组注释
    .external(name: "RxSwift"),
    .external(name: "RxCocoa"),
    .external(name: "RxRelay"),
    .external(name: "RxDataSources"),

    // ========== 网络层 ==========
    .external(name: "RxMoya"),
    .external(name: "Alamofire"),

    // ========== 图片加载 ==========
    .external(name: "Kingfisher"),

    // ========== 布局 ==========
    .external(name: "SnapKit"),

    // ========== 工具 ==========
    .external(name: "KeychainAccess"),
    .external(name: "CocoaLumberjack"),
]
```

### 3. 源文件与资源路径管理

```swift
sources: [
    "RxStudy/**",  // 通配符包含目录

    // 第三方库源码直接引入（不支持 SPM）
    "Packages/ThirdParty/NSObject+Rx/Sources/**",
    "Packages/ThirdParty/TheRouter/Sources/**",
    "Packages/ThirdParty/MBProgressHUD/Sources/**",

    // FSPagerView: 排除 include 目录（仅头文件，避免重复编译）
    "Packages/ThirdParty/FSPagerView/Sources/**/*.swift",
    "Packages/ThirdParty/FSPagerView/Sources/*.m",
],

resources: [
    "RxStudy/Assets.xcassets/**",
    "RxStudy/Base.lproj/LaunchScreen.storyboard",

    // Bundle 资源
    "Packages/ThirdParty/SVProgressHUD/Sources/SVProgressHUD.bundle/**",
    "Packages/ThirdParty/MJRefresh/Sources/MJRefresh/MJRefresh.bundle/**"
]
```

### 4. Settings 层级配置

```swift
settings: .settings(
    base: [  // 基础配置（所有配置共享）
        "SWIFT_VERSION": "5.9",
        "ENABLE_BITCODE": "NO",
        "DEVELOPMENT_TEAM": .string(teamId),
    ],
    configurations: [  // 构建配置（可覆盖基础配置）
        .debug(name: .debug, settings: [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG"
        ]),
        .release(name: .release, settings: [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited)"
        ])
    ],
    defaultSettings: .recommended  // 使用 Tuist 推荐配置
)
```

### 5. Bridging Header 与搜索路径

```swift
settings: .settings(
    base: [
        // ========== Bridging Header 配置 ==========
        "SWIFT_OBJC_BRIDGING_HEADER": "$(SRCROOT)/RxStudy/RxStudy-Bridging-Header.h",

        // ========== 第三方库头文件搜索路径 ==========
        "HEADER_SEARCH_PATHS": [
            "$(inherited)",
            "$(SRCROOT)/RxStudy",
            "$(SRCROOT)/RxStudy/Extension/CrashController",
            "$(SRCROOT)/Packages/ThirdParty/TheRouter/Sources",
            "$(SRCROOT)/Packages/ThirdParty/MBProgressHUD/Sources/include",
            "$(SRCROOT)/Packages/ThirdParty/SVProgressHUD/Sources/include",
            "$(SRCROOT)/Packages/ThirdParty/MJRefresh/Sources/MJRefresh",
            "$(SRCROOT)/Packages/ThirdParty/DZNEmptyDataSet/Sources/include"
        ]
    ]
)
```

### 6. InfoPlist 扩展配置

```swift
infoPlist: .extendingDefault(
    with: [
        "CFBundleDisplayName": "玩安卓",
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleVersion": "1",

        // 支持方向
        "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
        "UISupportedInterfaceOrientations~ipad": [
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationPortraitUpsideDown",
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight"
        ],

        // Scene 配置
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [
                "UIWindowSceneSessionRoleApplication": [[
                    "UISceneConfigurationName": "Default Configuration",
                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                ]]
            ]
        ],

        // 网络安全
        "NSAppTransportSecurity": [
            "NSAllowsArbitraryLoads": true
        ],

        // 权限描述
        "NSPhotoLibraryUsageDescription": "访问相册用于选择图片",
        "NSCameraUsageDescription": "访问相机用于拍摄图片",

        // URL Scheme
        "CFBundleURLTypes": [[
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["wandroid"]
        ]],

        // URL Query
        "LSApplicationQueriesSchemes": ["mqq", "csdn", "openjj", "jianshu"]
    ]
)
```

### 7. Scheme 配置

```swift
schemes: [
    .scheme(
        name: "RxStudy",
        shared: true,  // 共享 Scheme（团队成员可见）
        buildAction: .buildAction(targets: ["RxStudy"]),
        runAction: .runAction(executable: "RxStudy"),
        archiveAction: .archiveAction(configuration: .release),
        profileAction: .profileAction(configuration: .release),
        analyzeAction: .analyzeAction(configuration: .debug)
    )
]
```

---

## 三、Package.swift 配置技巧

### 1. 本地 Package 包装第三方库

当第三方库不支持 SPM 时，可将其包装为本地 Package：

```swift
// Packages/ThirdParty/MBProgressHUD/Package.swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MBProgressHUDSPM",
    platforms: [.iOS(.v13)],
    targets: [
        .target(
            name: "MBProgressHUDSPM",
            sources: ["Sources/**"],
            publicHeadersPath: "Sources/include"  // ObjC 公开头文件
        )
    ]
)
```

### 2. 模块化子 Package

```swift
// Packages/HttpRequest/Package.swift
let package = Package(
    name: "HttpRequest",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "HttpRequest",
            targets: ["HttpRequest"]
        )
    ],
    dependencies: [
        // 依赖在 Project.swift 中统一管理
        // .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
    ],
    targets: [
        .target(
            name: "HttpRequest",
            dependencies: [
                // .product(name: "RxSwift", package: "RxSwift"),
            ],
            path: "Sources"
        )
    ]
)
```

### 3. 依赖声明分组

```swift
let package = Package(
    name: "RxStudyDeps",
    platforms: [.iOS(.v17)],
    dependencies: [
        // ========== RxSwift 生态 ==========
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.0"),

        // ========== 网络层 ==========
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),

        // ========== 本地 Package ==========
        .package(path: "./Packages/ThirdParty/MBProgressHUD"),
        .package(path: "./Packages/ThirdParty/SVProgressHUD"),
        .package(path: "./Packages/ThirdParty/MJRefresh"),
    ]
)
```

---

## 四、两者协作模式

### 模式 1：依赖在 Project.swift 声明（推荐）

```swift
// Project.swift
let project = Project(
    packages: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
    ],
    targets: [
        .target(
            dependencies: [
                .external(name: "RxSwift"),  // 使用 external
            ]
        )
    ]
)

// Package.swift - 仅用于本地子模块声明
// 根目录的 Package.swift 可删除或仅保留本地依赖
```

**优点**：
- 统一管理所有依赖
- 利用 Tuist 的增量编译
- 更好的缓存支持

### 模式 2：混合使用（当前项目）

```swift
// Project.swift - 远程 SPM + 直接源码引入
packages: [
    .package(url: "...", from: "..."),  // 远程依赖
],
sources: [
    "Packages/ThirdParty/MBProgressHUD/Sources/**",  // 直接源码引入
]

// Package.swift - 本地 Package 声明
.package(path: "./Packages/ThirdParty/MBProgressHUD"),
```

**适用场景**：
- 第三方库不支持 SPM
- 需要修改第三方库源码
- 快速调试

---

## 五、最佳实践总结

### 编程原则应用

| 原则 | Project.swift | Package.swift |
|------|---------------|---------------|
| **KISS** | 保持结构扁平，避免过度嵌套 | 仅声明必要的内容 |
| **DRY** | 常量提取到顶部，分组注释复用 | 本地 Package 共享基础配置 |
| **SOLID-S** | 每个目标职责单一 | 每个 Package 模块化 |
| **YAGNI** | 仅添加当前需要的设置 | 不声明不用的依赖 |

### 推荐工作流

```
┌─────────────────────────────────────────────────────────────┐
│                    Tuist 项目配置工作流                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 远程依赖     → Project.swift 的 packages 中声明           │
│                                                             │
│  2. 本地模块     → Packages/ 下创建独立 Package               │
│                                                             │
│  3. 不支持 SPM  → 直接在 sources 中引入源文件                 │
│                                                             │
│  4. 公共配置     → 提取为常量或 Tuist Plugin                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 项目结构示例

```
RxStudy/
├── Project.swift              # Tuist 主配置
├── Package.swift              # 根目录 SPM（可选，仅本地依赖）
├── Tuist/
│   └── Tuist.swift           # Tuist 配置
├── Packages/
│   ├── HttpRequest/
│   │   └── Package.swift     # 子模块 Package
│   ├── RxStudyUtils/
│   │   └── Package.swift
│   └── ThirdParty/
│       ├── MBProgressHUD/
│       │   └── Package.swift # 第三方库包装
│       └── SVProgressHUD/
│           └── Package.swift
└── RxStudy/                  # 主应用源码
```

---

## 六、常见问题与解决方案

### Q1: 第三方库不支持 SPM 怎么办？

**方案 A**：包装为本地 Package
```
Packages/ThirdParty/XXX/
├── Package.swift
└── Sources/
    └── XXX/
```

**方案 B**：直接引入源码
```swift
sources: ["Packages/ThirdParty/XXX/Sources/**"]
```

### Q2: ObjC 库如何配置？

```swift
targets: [
    .target(
        sources: [
            "XXX/**/*.swift",
            "XXX/*.m",           // ObjC 源文件
        ],
        publicHeadersPath: "include"  // 公开头文件路径
    )
]
```

### Q3: 如何管理 Bundle 资源？

```swift
resources: [
    "Packages/ThirdParty/XXX/XXX.bundle/**"
]
```

### Q4: OC 库的 .h 文件在 Xcode 中不显示？

**问题描述**：在 Tuist 项目中引入第三方 OC 库后，.m 文件可见，但 .h 文件不在 Xcode 导航器中显示。

#### 原因分析

这是 Tuist 的**设计行为**，不是 Bug：

```
Tuist 处理文件的逻辑：
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  sources 配置 → 用于编译 → 添加到 Compile Sources           │
│                                                             │
│  .m 文件     → 源文件   → 编译   → 显示在导航器             │
│  .h 文件     → 头文件   → 不编译   → 不显示在导航器         │
│                                                             │
│  HEADER_SEARCH_PATHS → 告诉编译器在哪里找 .h 文件          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**核心结论**：
- ✅ .h 文件不显示不影响编译
- ✅ 代码可以正常 import/#include
- ✅ 编译器能通过 HEADER_SEARCH_PATHS 找到头文件
- ✅ 项目可以正常编译运行

#### 验证方法

```bash
# 测试项目是否可以正常编译
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build

# 如果输出 "BUILD SUCCEEDED"，说明配置完全正确
```

#### 查看头文件的方法

虽然 .h 文件不在导航器中，但可以通过以下方式查看：

**方法 1：代码跳转（推荐）**
```swift
// 在代码中使用类名，然后 Command + 点击
MBProgressHUD.showAdded(to: view, animated: true)  // Command + 点击 MBProgressHUD
```

**方法 2：Xcode Open Quickly**
```
快捷键: Command + Shift + O
输入: MBProgressHUD.h
回车 → 直接打开头文件
```

**方法 3：Finder 直接查看**
```bash
# 在终端中打开头文件目录
open "/path/to/Packages/ThirdParty/MBProgressHUD/Sources/include"
```

#### 正确的配置方式

```swift
// Project.swift
.target(
    name: "RxStudy",
    sources: [
        // 使用通配符引入整个目录
        "Packages/ThirdParty/MBProgressHUD/Sources/**",
        "Packages/ThirdParty/SVProgressHUD/Sources/**",
        "Packages/ThirdParty/MJRefresh/Sources/**",
    ],
    settings: .settings(
        base: [
            // 关键：配置头文件搜索路径
            "HEADER_SEARCH_PATHS": [
                "$(inherited)",
                "$(SRCROOT)/Packages/ThirdParty/MBProgressHUD/Sources/include",
                "$(SRCROOT)/Packages/ThirdParty/SVProgressHUD/Sources/include",
                "$(SRCROOT)/Packages/ThirdParty/MJRefresh/Sources/MJRefresh",
            ]
        ]
    )
)
```

#### 常见误区

| 误区 | 正确理解 |
|------|---------|
| 需要在 sources 中显式声明 .h 文件 | ❌ 不需要，通配符 `**` 已经包含 |
| .h 文件不显示会影响编译 | ❌ 不影响，编译器通过搜索路径找到 |
| 需要创建 Bridging Header 引入所有 .h | ❌ 只需要配置 HEADER_SEARCH_PATHS |
| 必须在 Xcode 中手动添加 .h 引用 | ❌ 不需要，Tuist 配置已足够 |

#### 头文件目录结构差异

**问题**：为什么有些库的 .h 文件在 `include/` 目录，而 MJRefresh 的 .h 和 .m 混在一起？

**原因**：这是**不同库的原始组织方式**，两种都正确：

```
// 方式 A：include/ 目录（MBProgressHUD/SVProgressHUD）
Sources/
├── include/
│   └── MBProgressHUD.h
└── MBProgressHUD.m

// 方式 B：原始结构（MJRefresh）
Sources/MJRefresh/
├── MJRefresh.h
├── MJRefresh.m
├── Base/
│   ├── MJRefreshComponent.h
│   └── MJRefreshComponent.m
└── Custom/
```

**配置差异**：

```swift
// 方式 A 的 HEADER_SEARCH_PATHS
"HEADER_SEARCH_PATHS": [
    "$(SRCROOT)/Packages/ThirdParty/MBProgressHUD/Sources/include",
]

// 方式 B 的 HEADER_SEARCH_PATHS
"HEADER_SEARCH_PATHS": [
    "$(SRCROOT)/Packages/ThirdParty/MJRefresh/Sources/MJRefresh",
    "$(SRCROOT)/Packages/ThirdParty/MJRefresh/Sources/MJRefresh/**",  // 包含子目录
]
```

**对比**：

| 方式 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **include/ 目录** | ✅ 公开 API 清晰<br>✅ 符合 SPM 规范 | ❌ 需要手动整理 | 规范化整理的库 |
| **原始结构** | ✅ 保持原始库结构<br>✅ .h 和 .m 对应关系清晰 | ❌ API 边界不够清晰 | 直接从 GitHub 复制的库 |

**建议**：保持各库的原始结构，无需统一整理。只要 `HEADER_SEARCH_PATHS` 配置正确即可。

#### 总结

| 问题 | 答案 |
|------|------|
| .h 文件不显示正常吗？ | ✅ **正常**，Tuist 的设计行为 |
| 项目能正常编译吗？ | ✅ **可以**，通过验证 |
| 需要修改配置吗？ | ❌ **不需要**，当前配置正确 |
| 有办法显示 .h 文件吗？ | ✅ 有但没必要，使用代码跳转即可 |

---

### Q5: 为什么 Package Dependencies 中会出现未使用的库？

**问题描述**：只使用了 RxMoya，但 Package Dependencies 中出现了 ReactiveSwift。

#### 原因分析

这是 **SPM 的正常依赖解析行为**。

**Moya 库提供了 3 个变体**：

| Product | 依赖 | 说明 |
|---------|------|------|
| **Moya** | Alamofire | 基础网络层 |
| **ReactiveMoya** | Moya + ReactiveSwift | 基于 ReactiveSwift 的扩展 |
| **RxMoya** | Moya + RxSwift | 基于 RxSwift 的扩展（**你在用这个**） |

**Moya 的 Package.swift 声明**：

```swift
// Moya/Package.swift（简化版）
let package = Package(
    name: "Moya",
    products: [
        .library(name: "Moya", targets: ["Moya"]),
        .library(name: "ReactiveMoya", targets: ["ReactiveMoya"]),  // ← 需要 ReactiveSwift
        .library(name: "RxMoya", targets: ["RxMoya"]),              // ← 你在用这个
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", ...),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", ...),  // ← 声明了
        .package(url: "https://github.com/ReactiveX/RxSwift.git", ...),
    ],
    targets: [
        .target(name: "ReactiveMoya", dependencies: [
            "Moya",
            .product(name: "ReactiveSwift", package: "ReactiveSwift")
        ]),
        .target(name: "RxMoya", dependencies: [
            "Moya",
            .product(name: "RxSwift", package: "RxSwift")
        ]),
    ]
)
```

#### SPM 依赖解析流程

```
┌─────────────────────────────────────────────────────────────┐
│              SPM 依赖解析流程                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 你在 Project.swift 中声明:                              │
│     .package(url: "https://github.com/Moya/Moya.git", ...)  │
│                                                             │
│  2. SPM 下载 Moya 的 Package.swift                          │
│                                                             │
│  3. SPM 看到 Moya 声明了 ReactiveSwift 依赖                 │
│     ↓                                                       │
│                                                             │
│  4. SPM 自动下载 ReactiveSwift                              │
│     (虽然你没直接使用，但 Moya 库需要它用于 ReactiveMoya)   │
│                                                             │
│  5. 显示在 Package Dependencies 中                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 影响评估

| 问题 | 答案 |
|------|------|
| 影响编译吗？ | ❌ 不影响 |
| 会增加包大小吗？ | ❌ 不会，未使用的库不会被链接 |
| 会增加编译时间吗？ | ⚠️ 轻微增加（下载依赖需要时间） |
| 需要手动移除吗？ | ❌ 不需要，SPM 自动管理 |

#### 验证方法

```bash
# 检查项目是否使用了 ReactiveSwift
grep -r "import ReactiveSwift" RxStudy/ --include="*.swift"

# 输出为空说明没有使用，这是正常的
```

**示例验证**：
```swift
// 你的项目中的引用统计
import ReactiveSwift  → 0 次  ❌ 没有使用
import RxSwift       → 70 次 ✅ 在使用
```

#### 总结

| 现象 | 原因 | 影响 |
|------|------|------|
| Package Dependencies 出现未使用的库 | 库的 Package.swift 声明了多个变体的依赖 | ✅ 正常行为，无负面影响 |

**这是 SPM 的标准行为，无需担心！**

---

### Q6: 多 Target 共享配置怎么办？

---

## 七、网络问题解决方案

### Q1: GitHub 连接超时怎么办？

**错误信息**：
```
fatal: unable to access 'https://github.com/.../':
Failed to connect to github.com port 443 after 42524 ms: Couldn't connect to server
```

#### 解决方案：配置 Git 代理

**步骤 1：创建代理设置脚本**

```bash
#!/bin/bash
# set-proxy.sh

PROXY_PORT=${1:-7890}
PROXY_URL="http://127.0.0.1:${PROXY_PORT}"

echo "📡 正在设置代理..."
echo "   代理地址: ${PROXY_URL}"

# 设置 Git 代理
git config --global http.proxy "${PROXY_URL}"
git config --global https.proxy "${PROXY_URL}"

echo ""
echo "✅ 代理设置完成！"
echo "  Git HTTP代理:  $(git config --global http.proxy)"
echo "  Git HTTPS代理: $(git config --global https.proxy)"
```

**步骤 2：使用代理运行 Tuist**

```bash
# 设置代理
./set-proxy.sh 7890

# 使用代理安装依赖
http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 tuist install

# 使用代理生成项目
http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 tuist generate
```

**步骤 3：取消代理（可选）**

```bash
#!/bin/bash
# unset-proxy.sh

git config --global --unset http.proxy
git config --global --unset https.proxy

unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset all_proxy
unset ALL_PROXY

echo "✅ 代理已取消"
```

---

## 八、Tuist 管理模式详解

### Dependencies vs Package Dependencies

在使用 Tuist + SPM 时，Xcode 中会显示两种依赖类型：

#### 显示结构

```
Xcode Navigator:
├── RxStudy (主工程)
├── Dependencies (Tuist 管理的项目)
│   ├── RxSwift
│   ├── RxSwiftExt
│   ├── Moya
│   └── ...
└── Package Dependencies (Xcode SPM 解析器)
```

#### 工作原理

```
┌─────────────────────────────────────────────────────────────────┐
│                    Tuist + Xcode SPM 协同工作流程                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Project.swift 声明 packages                                  │
│     ↓                                                           │
│  2. Tuist 为每个 SPM 包生成独立的 Xcode 项目                      │
│     → 保存到 .build/tuist-derived/                              │
│     → 在 Xcode 中显示为 "Dependencies"                           │
│     → 目的：增量编译缓存、并行编译                                │
│                                                                 │
│  3. Xcode SPM 解析器管理包                                       │
│     → 下载包源码到 .build/checkouts/                            │
│     → 解析包依赖关系                                             │
│     → 在 Xcode 中显示为 "Package Dependencies"                   │
│                                                                 │
│  4. 编译时协同工作                                               │
│     → Tuist 管理编译配置                                         │
│     → Xcode SPM 管理链接                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### 两种模式对比

| 模式 | Project.swift 配置 | Xcode 显示 | 适用场景 |
|------|-------------------|-----------|---------|
| **模式 A：集中声明 packages**<br>（推荐用于单体应用） | ✅ 有 `packages` 字段 | Dependencies + Package Dependencies | 中小型项目、快速开发 |
| **模式 B：本地 Package 模块化**<br>（推荐用于大型项目） | ❌ 无 `packages` 字段 | 仅 Dependencies | 大型项目、多团队协作、需要模块化 |

#### 模式 A 示例（当前 RxStudy）

```swift
// Project.swift
let project = Project(
    packages: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        // ... 更多远程依赖
    ],
    targets: [
        .target(
            name: "RxStudy",
            dependencies: [
                .external(name: "RxSwift"),
                .external(name: "RxMoya"),
            ]
        )
    ]
)
```

**优点**：
- ✅ 配置集中，易于管理
- ✅ Tuist 增量编译缓存
- ✅ 支持并行编译
- ✅ 适合单体应用

**缺点**：
- ❌ Package Dependencies 节点会显示
- ❌ 不适合复杂的模块化架构

#### 模式 B 示例（TemplateTuist）

```swift
// Project.swift - 无 packages 字段
let project = Project(
    targets: [
        .target(
            name: "Moya",
            dependencies: [
                .external(name: "Alamofire")  // 来自本地 Package
            ]
        ),
        .target(
            name: "Login",
            dependencies: [
                .target(name: "HttpRequest")  // 依赖本地模块
            ]
        )
    ]
)

// Moya/Package.swift - 模块声明自己的依赖
let package = Package(
    name: "Moya",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0"),
    ]
)
```

**优点**：
- ✅ 模块化清晰，职责分离
- ✅ 每个模块可独立编译测试
- ✅ 适合多团队协作
- ✅ 不显示 Package Dependencies

**缺点**：
- ❌ 配置分散在多个 Package.swift
- ❌ 需要更多项目结构规划

#### 选择建议

| 项目特征 | 推荐模式 |
|---------|---------|
| 单体应用，依赖较少 | 模式 A（集中声明） |
| 多模块业务，需要解耦 | 模式 B（本地 Package） |
| 小型团队，快速迭代 | 模式 A |
| 大型团队，并行开发 | 模式 B |

---

## 九、参考资源

- [Tuist 官方文档](https://tuist.dev/docs/)
- [Swift Package Manager 文档](https://www.swift.org/package-manager/)
- 项目示例：`RxStudy/Project.swift`

---

## 附录：快速参考

### 常用命令

```bash
# 生成项目
tuist generate

# 安装依赖
tuist install

# 清理缓存
tuist clean

# 使用代理（网络问题时）
http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 tuist generate

# 验证编译
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
```

### 常见配置速查

```swift
// 常量定义
let teamId = "GZKK4Y45D3"

// SPM 依赖
packages: [
    .package(url: "https://github.com/...", from: "1.0.0"),
]

// 目标依赖
dependencies: [
    .external(name: "RxSwift"),
    .target(name: "MyModule"),
]

// 源文件
sources: [
    "Sources/**",
    "Packages/ThirdParty/XXX/Sources/**",
]

// 头文件搜索路径
"HEADER_SEARCH_PATHS": [
    "$(SRCROOT)/Packages/ThirdParty/XXX/Sources/include",
]
```

### 目录结构速查

```
ProjectRoot/
├── Project.swift          # Tuist 主配置
├── Package.swift          # 根目录 SPM（可选）
├── Tuist/
│   └── Tuist.swift       # Tuist 配置
├── Packages/
│   ├── ThirdParty/       # 第三方库源码
│   └── ModuleName/       # 本地模块
└── App/                  # 主应用源码
```

---

**文档版本**：v1.1
**更新日期**：2026-02-24
**维护者**：Tuist 配置指南
