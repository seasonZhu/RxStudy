# Tuist 完整配置指南

> Tuist 项目配置、依赖管理、资源合成的完整指南

---

## 目录

1. [核心概念](#1-核心概念)
2. [配置文件说明](#2-配置文件说明)
3. [依赖管理](#3-依赖管理)
4. [Project.swift 高级配置](#4-projectswift-高级配置)
5. [Package.swift 配置](#5-packageswift-配置)
    - [5.4 productTypes 配置审计](#54-producttypes-配置审计重要避免重复决策)
6. [资源合成器配置](#6-资源合成器配置)
7. [常见问题与解决方案](#7-常见问题与解决方案)
8. [最佳实践](#8-最佳实践)
9. [版本升级 SOP](#9-版本升级-sop)

---

## 1. 核心概念

### 核心文件职责

| 文件 | 职责 | 位置 |
|------|------|------|
| **Project.swift** | 定义 Xcode 项目结构、目标、依赖关系、编译配置 | 项目根目录 |
| **Package.swift** | 定义 Swift Package 依赖、模块、产品 | Tuist/ 目录 |
| **Tuist/Tuist.swift** | Tuist 全局配置（如 Registry） | Tuist/ 目录 |

### Dependencies vs Package Dependencies

在使用 Tuist + SPM 时，Xcode 中会显示两种依赖类型：

```
Xcode Navigator:
├── RxStudy (主工程)
├── Dependencies (Tuist 管理的项目)
│   ├── RxSwift
│   └── Moya
└── Package Dependencies (Xcode SPM 解析器)
```

---

## 2. 配置文件说明

### 2.1 项目结构

```
ProjectRoot/
├── Project.swift              # Tuist 主配置
├── Package.swift              # 根目录 SPM（可选）
├── swiftgen.yml              # SwiftGen 配置
├── Tuist/
│   ├── Tuist.swift          # Tuist 配置
│   ├── Package.swift        # SPM 依赖定义
│   └── .build/              # 依赖缓存
├── Packages/
│   ├── ThirdParty/          # 第三方库源码
│   └── ModuleName/          # 本地模块
└── App/                     # 主应用源码
```

### 2.2 依赖存储位置

#### 项目级缓存（当前项目专用）

```
Tuist/.build/
├── artifacts/           # 构建产物
├── checkouts/          # 第三方源码
├── repositories/       # Git 仓库克隆
└── workspace-state.json
```

#### 全局缓存（所有项目共享）

```
~/.cache/tuist/
├── Binaries/             # 二进制文件缓存
├── Manifests/            # 依赖清单缓存
├── Plugins/             # Tuist 插件缓存
├── Projects/            # 项目描述缓存
└── Runs/                # 运行缓存
```

---

## 3. 依赖管理

### 3.1 两种依赖管理方式

#### 方式一：Package.swift（推荐）

```swift
// Tuist/Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
]
productTypes: [
    "Alamofire": .staticFramework,
]
```

**Project.swift 引用**：
```swift
dependencies: [
    .external(name: "Alamofire"),
    .external(name: "RxSwift"),
]
```

#### 方式二：Tuist Registry（可选，需代理）

> ⚠️ Registry 在国内可能无法直接访问

```swift
// Tuist/Tuist.swift
let config = Config(
    dependencies: [
        .remote(url: "https://registry.tuist.dev", name: "Tuist"),
    ]
)
```

### 3.2 版本指定方式

| 方式 | 语法 | 说明 |
|------|------|------|
| **版本范围** | `.package(url: "...", from: "5.11.0")` | 推荐：自动获取小版本更新 |
| **精确版本** | `.package(url: "...", exact: "5.11.0")` | 锁定特定版本 |
| **分支** | `.package(url: "...", branch: "main")` | 谨慎使用：代码可能不稳定 |
| **修订** | `.package(url: "...", revision: "abc123")` | 特定提交 |
| **本地路径** | `.package(path: "../LocalSPMPackage")` | 本地开发 |

### 3.3 依赖管理流程

```
tuist install
  ↓
读取 Tuist/Package.swift 中的依赖定义
  ↓
解析版本要求
  ↓
克隆到: Tuist/.build/repositories/
  ↓
检出到: Tuist/.build/checkouts/
```

### 3.4 常用命令

```bash
# 安装依赖
tuist install

# 生成项目
tuist generate

# 清理缓存
tuist clean

# 查看依赖图
tuist graph

# 使用代理（网络问题时）
http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 tuist generate
```

---

## 4. Project.swift 高级配置

### 4.1 常量定义与复用

```swift
let teamId = "GZKK4Y45D3"
let organizationName = "com.lostsakura"
let deploymentTarget = "17.6"

let project = Project(
    name: "RxStudy",
    organizationName: organizationName,
    targets: [
        .target(
            deploymentTargets: .iOS(deploymentTarget),
            // ...
        )
    ]
)
```

### 4.2 依赖声明分组

```swift
dependencies: [
    // ========== RxSwift 生态 ==========
    .external(name: "RxSwift"),
    .external(name: "RxCocoa"),
    .external(name: "RxRelay"),

    // ========== 网络层 ==========
    .external(name: "Moya"),
    .external(name: "Alamofire"),

    // ========== 图片加载 ==========
    .external(name: "Kingfisher"),

    // ========== 布局 ==========
    .external(name: "SnapKit"),
]
```

### 4.3 源文件与资源路径

```swift
sources: [
    "RxStudy/**",

    // 第三方库源码
    "Packages/ThirdParty/NSObject+Rx/Sources/**",
    "Packages/ThirdParty/TheRouter/Sources/**",

    // 排除 include 目录
    "Packages/ThirdParty/FSPagerView/Sources/**/*.swift",
    "Packages/ThirdParty/FSPagerView/Sources/*.m",
],

resources: [
    "RxStudy/Assets.xcassets/**",
    "RxStudy/Base.lproj/LaunchScreen.storyboard",

    // Bundle 资源
    "Packages/ThirdParty/SVProgressHUD/Sources/SVProgressHUD.bundle/**",
]
```

### 4.4 Bridging Header 与搜索路径

```swift
settings: .settings(
    base: [
        "SWIFT_OBJC_BRIDGING_HEADER": "$(SRCROOT)/RxStudy/RxStudy-Bridging-Header.h",

        "HEADER_SEARCH_PATHS": [
            "$(inherited)",
            "$(SRCROOT)/RxStudy",
            "$(SRCROOT)/Packages/ThirdParty/TheRouter/Sources",
            "$(SRCROOT)/Packages/ThirdParty/MBProgressHUD/Sources/include",
            "$(SRCROOT)/Packages/ThirdParty/MJRefresh/Sources/MJRefresh",
        ]
    ]
)
```

### 4.5 InfoPlist 配置

```swift
infoPlist: .extendingDefault(
    with: [
        "CFBundleDisplayName": "玩安卓",
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleVersion": "1",

        // 支持方向
        "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],

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

        // URL Scheme
        "CFBundleURLTypes": [[
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["wandroid"]
        ]],
    ]
)
```

### 4.6 Scheme 配置

```swift
schemes: [
    .scheme(
        name: "RxStudy",
        shared: true,  // 团队成员可见
        buildAction: .buildAction(targets: ["RxStudy"]),
        runAction: .runAction(executable: "RxStudy"),
        archiveAction: .archiveAction(configuration: .release),
        profileAction: .profileAction(configuration: .release),
        analyzeAction: .analyzeAction(configuration: .debug)
    )
]
```

---

## 5. Package.swift 配置

### 5.1 本地 Package 包装第三方库

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
            publicHeadersPath: "Sources/include"
        )
    ]
)
```

### 5.2 模块化子 Package

```swift
let package = Package(
    name: "HttpRequest",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HttpRequest", targets: ["HttpRequest"])
    ],
    targets: [
        .target(
            name: "HttpRequest",
            path: "Sources"
        )
    ]
)
```

### 5.3 依赖声明分组

```swift
let package = Package(
    name: "RxStudyDeps",
    dependencies: [
        // ========== RxSwift 生态 ==========
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),

        // ========== 网络层 ==========
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),

        // ========== 本地 Package ==========
        .package(path: "./Packages/ThirdParty/MBProgressHUD"),
    ]
)
```

### 5.4 productTypes 配置审计（重要，避免重复决策）

> **审计日期**: 2026-06-17
> **审计结论**: 保留所有 33 行配置（保守策略）

#### 5.4.1 底层逻辑（why productTypes 配置存在）

Tuist 默认会自动检测 SPM 库的 product 类型：

| 库的 Package.swift 长这样 | Tuist 实际产物 |
|---|---|
| `.library(name: "X", targets: [...])` | `.staticFramework`（默认） |
| `.library(name: "X", type: .dynamic, ...)` | `.dynamicFramework` |
| `.library(name: "X", type: .static, ...)` | `.staticFramework` |

所以 **`productTypes` 配置的真正作用是「覆盖默认行为」**——只有当库的默认类型和你期望不一致时才有意义。

#### 5.4.2 当前 33 行配置分类（全量审计结果）

| 分类 | 数量 | 库 | 说明 |
|---|---|---|---|
| ✅ **必要覆盖** | 5 | RxCocoa, RxRelay, RxBlocking, Alamofire, SnapKit | 库默认是 `.dynamic`，配成 `.staticFramework` 才是真正的覆盖 |
| ❌ **冗余配置** | 25 | RxSwift, RxDataSources, RxGesture, RxTheme, RxSwiftExt, RxOptional, NSObject-Rx, RxMoya, Moya, Kingfisher, KeychainAccess, CocoaLumberjack, MarqueeLabel, SFSafeSymbols, ZipArchive, WebUI, ProgressHUD, MBProgressHUD, SVProgressHUD, MJRefresh, JXSegmentedView, DZNEmptyDataSet, AcknowList, SwiftUIX, SwiftUIIntrospect | 库默认就是 static，配置是冗余但无害 |
| 💀 **死代码** | 2 | IQKeyboardManager, FlexLayout | 库的 product 名变了 / package 已注释 |
| ⚠️ **无效配置** | 1 | FSPagerView | 本地 Package 走 sources 集成，productTypes 不生效 |

#### 5.4.3 5 个真正"必要覆盖"的库（核心价值）

这些库默认 `.dynamic`，如果不显式配成 `.staticFramework`：

- iOS app 会要求 **Embed Frameworks**（动态库必须 embed）
- App Store 上传时会有 **"Missing required architecture"** 警告
- 启动时动态链接开销变大

```
RxCocoa     → 默认 .dynamic → 必须配 .staticFramework
RxRelay     → 默认 .dynamic → 必须配 .staticFramework
RxBlocking  → 默认 .dynamic → 必须配 .staticFramework
Alamofire   → 默认 .dynamic → 必须配 .staticFramework
SnapKit     → 默认 .dynamic → 必须配 .staticFramework
```

#### 5.4.4 决策记录（避免反复拉扯）

**决策**：**保留所有 33 行配置（含冗余和无效），不清洗**。

**理由**：
1. **冗余不是错**：25 行冗余配置起到"显式文档"作用——未来读者看到一堆 `.staticFramework`，一眼明白"项目全用静态 framework"
2. **防御性默认值**：未来加新库时，如果默认是 `.dynamic`，开发者会注意到现有配置都是 `.staticFramework`，主动覆盖，避免埋雷
3. **3 行死代码暂时保留**：IQKeyboardManager / FlexLayout 短期内可能被重新引入，配置不动；FSPagerView 是历史残留，无害

#### 5.4.5 审计方法（如何自查新库）

```bash
# 1. 在 checkouts 目录找到新库的 Package.swift
find Tuist/.build/checkouts/<LibName> -name "Package.swift"

# 2. 看 products 段的 type 字段
grep -A3 "name: \"<LibName>\"" Tuist/.build/checkouts/<LibName>/Package.swift | grep "type:"
# type: .dynamic  → 必须配 productTypes 为 .staticFramework
# type: .static   → 配不配都一样（冗余）
# 无 type 字段     → 默认 static（冗余）
```

#### 5.4.6 历史变更记录

| 日期 | 变更 | 审计人 |
|---|---|---|
| 2026-06-17 | 首次全量审计，确认 5 必要 / 25 冗余 / 2 死代码 / 1 无效；决策保留全部 | Claude |

---

## 6. 资源合成器配置

### 6.1 自动生成的文件

Tuist 默认会生成以下文件到 `Derived/Sources/`：

| 文件 | 说明 |
|------|------|
| `TuistPlists+<项目名>.swift` | SPM 依赖许可证信息 |
| `TuistAssets+<项目名>.swift` | Assets 扩展 |
| `TuistStrings+<项目名>.swift` | Strings 扩展 |

### 6.2 禁用 Plist 资源合成器

如果使用 **AcknowList** + 自己的 `.plist` 文件，可以禁用自动生成：

```swift
// Project.swift
let project = Project(
    name: "RxStudy",
    // ... 其他配置

    // ✅ 正确：手动指定需要的合成器
    resourceSynthesizers: [
        .assets(),   // 保留
        .strings(),  // 保留
    ]
)
```

> ⚠️ **重要**：不要使用 `.default`，它包含了 `.plist()` 合成器

### 6.3 替代方案

| 方案 | 代码 | 效果 |
|------|------|------|
| **完全禁用** | `resourceSynthesizers: []` | 禁用所有自动生成 |
| **仅保留 Assets/Strings** | `resourceSynthesizers: [.assets(), .strings()]` | 推荐 |
| **使用 .default** | ❌ 不推荐 | 会生成 Plist 文件 |

### 6.4 验证配置

```bash
# 查看 Derived/Sources 目录
ls -la Derived/Sources/

# 确认 Plist 文件不存在
ls Derived/Sources/TuistPlists+RxStudy.swift
# 应该显示：No such file or directory
```

---

## 7. 常见问题与解决方案

### Q1: 第三方库不支持 SPM 怎么办？

**方案 A**：包装为本地 Package
```
Packages/ThirdParty/XXX/
├── Package.swift
└── Sources/
```

**方案 B**：直接引入源码
```swift
sources: ["Packages/ThirdParty/XXX/Sources/**"]
```

### Q2: ObjC 库如何配置？

```swift
.target(
    sources: [
        "XXX/**/*.swift",
        "XXX/*.m",
    ],
    publicHeadersPath: "include"
)
```

### Q3: OC 库的 .h 文件在 Xcode 中不显示？

**这是 Tuist 的设计行为，不是 Bug**：
- .m 文件 → 源文件 → 编译 → 显示在导航器
- .h 文件 → 头文件 → 不编译 → 不显示在导航器

**验证方法**：
```bash
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy build
# 输出 "BUILD SUCCEEDED" 则说明配置正确
```

### Q4: Package Dependencies 中出现未使用的库？

**原因**：这是 SPM 的正常依赖解析行为。

例如使用 RxMoya 时，Moya 库声明了 ReactiveSwift 作为可选依赖，SPM 会自动下载。

**结论**：不影响编译，无需担心。

### Q5: GitHub 连接超时怎么办？

```bash
# 设置 Git 代理
git config --global http.proxy "http://127.0.0.1:7890"
git config --global https.proxy "http://127.0.0.1:7890"

# 使用代理运行
http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 tuist generate
```

### Q6: 多 Target 共享配置怎么办？

使用 Tuist 的配置复用机制，或提取为独立的方法。

---

## 8. 最佳实践

### 编程原则

| 原则 | Project.swift | Package.swift |
|------|---------------|---------------|
| **KISS** | 保持结构扁平 | 仅声明必要内容 |
| **DRY** | 常量提取分组 | 本地 Package 共享 |
| **SOLID-S** | 每个目标职责单一 | 每个 Package 模块化 |
| **YAGNI** | 仅添加当前需要 | 不声明不用的依赖 |

### 推荐工作流

```
┌─────────────────────────────────────────────┐
│           Tuist 项目配置工作流                │
├─────────────────────────────────────────────┤
│  1. 远程依赖 → Project.swift packages       │
│  2. 本地模块 → Packages/ 下创建 Package     │
│  3. 不支持 SPM → 直接 sources 中引入         │
│  4. 公共配置 → 提取为常量或 Plugin          │
└─────────────────────────────────────────────┘
```

### 两种协作模式对比

| 模式 | 适用场景 |
|------|---------|
| **集中声明**（模式 A） | 单体应用，依赖较少 |
| **本地 Package**（模式 B） | 多模块业务，需要解耦 |

---

## 9. 版本升级 SOP

> Tuist 4.x 升级频繁（平均每月 1-2 个 minor），server-side 强依赖版本。**把升级动作固化为 SOP，避免每次踩同样的坑**。

### 9.1 三处版本号必须对齐（核心原则）

| 位置 | 含义 | 示例 |
|------|------|------|
| `~/.local/state/tuist/...` 实际运行的 binary | 真实版本 | `4.200.4` |
| `.tuist-supported-version`（项目根） | 项目支持的最低/期望版本 | `4.200.4` |
| `mise.toml`（`[tools] tuist =`） | 工具版本管理声明 | `4.200.4` |

**违反此原则的后果**：
- 别人 clone 仓库后，Tuist 会警告版本不匹配
- `mise install` 装错版本，hook 触发时二进制不一致
- 服务器端（远程 cache、analytics）随版本失效而失败

### 9.2 升级前检查（5 步）

```bash
# 1. 看当前版本
/opt/homebrew/Cellar/tuist@<ver>/<ver>/bin/tuist version

# 2. 看 homebrew 实际装的版本（可能有多个版本共存）
brew list --versions | grep tuist

# 3. 看 tuist 实际指向的 symlink
ls -la /opt/homebrew/bin/tuist

# 4. 看项目声明的版本
cat .tuist-supported-version

# 5. 看 mise 声明的版本
cat mise.toml
```

### 9.3 升级命令（macOS Apple Silicon）

#### 场景 A：从旧版本升级到最新 stable

```bash
# 1. 信任 tuist 官方 tap（首次升级需要）
brew trust tuist/tuist

# 2. ARM Mac 必须用 arch -arm64（shell 在 Rosetta 2 下会失败）
arch -arm64 brew install tuist/tuist/tuist@<最新版本>

# 3. 解除旧版本 link
arch -arm64 brew unlink tuist@<旧版本>

# 4. 链接新版本
arch -arm64 brew link tuist@<新版本>

# 5. 同步项目版本声明
echo "<新版本>" > .tuist-supported-version

# 6. 更新 mise.toml
# 编辑 mise.toml: tuist = "<新版本>"

# 7. 端到端验证
tuist generate
```

#### 场景 B：x86 用户的 ARM Mac 兼容配置

如果你的 shell 跑在 Rosetta 2 下（`arch` 命令返回 `i386`），所有 `brew` 命令都必须加 `arch -arm64` 前缀。**长期方案**——在 `~/.zshrc` 加 alias：

```bash
alias brew='arch -arm64 brew'
```

#### 场景 C：完全重装（推荐每半年一次）

```bash
# 1. 卸载所有版本
arch -arm64 brew uninstall --force tuist@4.143.0
arch -arm64 brew uninstall --force tuist@4.200.4

# 2. 清理缓存
rm -rf /opt/homebrew/Cellar/tuist@*

# 3. 重新安装最新
arch -arm64 brew install tuist/tuist/tuist@<最新版本>

# 4. 同步项目三处版本号（参见 9.1）
```

### 9.4 升级失败排错清单

| 症状 | 根因 | 解决方案 |
|------|------|----------|
| `Refusing to load formula ... from untrusted tap` | tap 未信任 | `brew trust tuist/tuist` |
| `Cannot install under Rosetta 2 in ARM default prefix` | shell 在 x86 模式 | 命令前加 `arch -arm64` |
| `Could not symlink bin/tuist` | 旧版本还占着 symlink | `brew unlink tuist@<旧版>` 后再 `brew link` |
| 升级后 `tuist version` 没变 | PATH 缓存或 symlink 没切换 | `hash -r && which tuist`，必要时重新 link |
| `Refreshing of the access and refresh token pair failed after 5 seconds` | DNS 无法解析 `auth.tuist.dev` / `backend.tuist.dev` | 见 `TROUBLESHOOTING.md`「错误7」 |

### 9.5 升级后必须做的 3 件事

```bash
# 1. 重新生成项目（验证不破坏现有 manifest）
tuist generate

# 2. 检查是否有 deprecation warning（4.143.0 以前的版本会遇到）
# 如果有，按 9.3 升级

# 3. 提交版本对齐变更
git add .tuist-supported-version mise.toml
git commit -m "chore: bump tuist to <新版本>"
```

---

## 相关文件

| 文件 | 路径 |
|------|------|
| Project.swift | 项目根目录 |
| Tuist/Package.swift | Tuist/ 目录 |
| Tuist/Tuist.swift | Tuist/ 目录 |
| swiftgen.yml | 项目根目录 |

---

**文档版本**: v3.1
**更新日期**: 2026-06-17
**变更记录**:
- v3.0 (2026-06-17): 新增第 9 章「版本升级 SOP」，固化 4.143.0 → 4.200.4 升级踩坑经验（DNS/认证、IQKeyboardManager 重命名、Rosetta 2、版本对齐）
- v3.1 (2026-06-17): 新增 5.4 节「productTypes 配置审计」，全量审计 33 行配置（5 必要 / 25 冗余 / 2 死代码 / 1 无效），决策保留全部配置（含审计方法 + 决策记录 + 历史变更）
