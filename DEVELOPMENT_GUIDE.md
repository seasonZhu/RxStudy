# RxStudy 项目开发指南

本文档整合了 Tuist 配置、依赖管理、资源合成器等核心内容，为项目开发提供全面的配置参考。

---

## 目录

1. [项目结构概述](#项目结构概述)
2. [依赖管理](#依赖管理)
3. [资源合成器配置](#资源合成器配置)
4. [开发最佳实践](#开发最佳实践)
5. [常见问题解答](#常见问题解答)

---

## 项目结构概述

### 核心配置文件

| 文件 | 作用 |
|------|------|
| `Project.swift` | 定义项目结构、Targets、依赖引用 |
| `Tuist/Package.swift` | 定义 SPM 依赖列表 |
| `Tuist/Tuist.swift` | Tuist 全局配置（如 Registry） |
| `.tuist-supported-version` | 锁定 Tuist 版本 |

### 目录结构

```
RxStudy/
├── Project.swift                    # 项目配置
├── Tuist/
│   ├── Package.swift               # SPM 依赖定义
│   ├── Tuist.swift                 # Tuist 配置
│   └── .build/                     # 依赖缓存（自动生成）
│       ├── checkouts/              # 依赖源码
│       └── repositories/           # Git 仓库克隆
├── SwiftUIApp/                     # SwiftUI 入口
├── RxStudy/                        # UIKit 代码
├── Derived/                        # 生成的文件
└── Packages/ThirdParty/            # 本地第三方库
```

---

## 依赖管理

### 依赖存储位置

#### 项目级缓存（当前项目专用）

```
/Users/dy/Documents/Swift Git/RxStudy/Tuist/.build/
```

**目录结构**：
```
Tuist/.build/
├── artifacts/           # 构建产物
├── checkouts/          # 📦 第三方源码下载位置
│   ├── RxGesture/
│   └── RxOptional/
└── repositories/       # 📚 Git 仓库克隆位置
```

#### 全局缓存（所有项目共享）

```
~/.cache/tuist/
```

### 两种依赖管理方式

#### 方式一：Package.swift（推荐）

**配置文件**：`Tuist/Package.swift`

```swift
import ProjectDescription

let package = Package(
    name: "RxStudy",
    dependencies: [
        // 格式：.package(url: "仓库URL", from: "版本号")
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
    ],
    productTypes: [
        // 可选：指定产品类型
        "Alamofire": .staticFramework,
    ]
)
```

**Project.swift 引用**：

```swift
targets: [
    .target(
        name: "RxStudy",
        dependencies: [
            .external(name: "Alamofire"),
            .external(name: "RxSwift"),
        ]
    )
]
```

#### 方式二：Tuist Registry（可选，需代理）

> ⚠️ Tuist Registry (`registry.tuist.dev`) 在国内可能无法直接访问。

**Tuist/Tuist.swift**：

```swift
let config = Config(
    dependencies: [
        .remote(url: "https://registry.tuist.dev", name: "Tuist"),
    ]
)
```

**Project.swift**（无需 Package.swift）：

```swift
dependencies: [
    .external(name: "Alamofire"),
    .external(name: "Kingfisher"),
]
```

#### 两种方式对比

| 特性 | Package.swift | Tuist Registry |
|------|--------------|----------------|
| **网络要求** | GitHub 即可 | 需要代理 |
| **配置文件** | Package.swift + Project.swift | 仅 Project.swift |
| **版本控制** | 手动指定 | 自动管理 |
| **灵活性** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **推荐场景** | 默认推荐 | 常用库 + 可访问外网 |

### 版本指定方式

| 方式 | 语法 | 说明 |
|------|------|------|
| **版本范围** | `.package(url: "...", from: "5.11.0")` | 推荐：自动获取小版本更新 |
| **精确版本** | `.package(url: "...", exact: "5.11.0")` | 锁定特定版本 |
| **分支** | `.package(url: "...", branch: "main")` | 谨慎使用：代码可能不稳定 |
| **修订** | `.package(url: "...", revision: "abc123")` | 特定提交 |
| **本地路径** | `.package(path: "../LocalSPMPackage")` | 本地开发 |

### 常用操作命令

```bash
# 安装依赖
tuist install

# 生成 Xcode 项目
tuist generate

# 清理缓存
tuist clean

# 查看依赖图
tuist graph
```

### 本地 SPM 包

某些库没有 Package.swift 或需要修复问题时，可以制作成本地 SPM 包：

```
Packages/ThirdParty/TheRouter/
├── Package.swift          # 手动创建
└── Sources/
    ├── include/           # 公开头文件
    └── *.swift
```

**Package.swift 示例**：

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TheRouter",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "TheRouter", targets: ["TheRouter"]),
    ],
    targets: [
        .target(
            name: "TheRouter",
            path: "Sources",
            publicHeadersPath: "include",
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
            ]
        ),
    ]
)
```

---

## 资源合成器配置

### 自动生成的内容

Tuist 默认会生成以下文件到 `Derived/Sources/`：

| 文件 | 说明 |
|------|------|
| `TuistPlists+<项目名>.swift` | SPM 依赖许可证信息 |
| `TuistAssets+<项目名>.swift` | Assets 扩展 |
| `TuistBundle+<项目名>.swift` | Bundle 扩展 |

### 禁用 Plist 资源合成器

如果使用 **AcknowList** + 自己的 `.plist` 文件，可以禁用自动生成：

```swift
// Project.swift
let project = Project(
    name: "RxStudy",
    // ... 其他配置

    // ✅ 正确：手动指定需要的合成器
    resourceSynthesizers: [
        .assets(),   // 保留：Assets 合成器
        .strings(),  // 保留：Strings 合成器
    ]
)
```

> ⚠️ **重要**：不要使用 `.default`，它包含了 `.plist()` 合成器。

**错误示例**：
```swift
// ❌ 错误：.default 会生成 Plist 文件
resourceSynthesizers: .default + [
    .assets(),
    .strings(),
]
```

### 清理生成的文件

```bash
# 删除自动生成的 Plist 文件
rm -rf Derived/Sources/TuistPlists+RxStudy.swift

# 重新生成项目
tuist generate
```

---

## 开发最佳实践

### 1. 依赖管理

- ✅ 默认使用 **Package.swift**，无网络限制
- ✅ 提交 `Package.swift` 到 Git，确保团队一致
- ✅ 使用版本范围（`from: "5.11.0"`）而非精确版本
- ✅ 常用库使用静态链接：`"Alamofire": .staticFramework`

### 2. 导航层级设计

**推荐架构**：每个 Tab 独立的 NavigationView

```swift
TabView(selection: $selectedTab) {
    NavigationView { HomeView() }
        .navigationViewStyle(.stack)
        .tabItem { Label("首页", systemImage: "house.fill") }
        .tag(0)

    NavigationView { ProjectView() }
        .navigationViewStyle(.stack)
        .tabItem { Label("项目", systemImage: "folder.fill") }
        .tag(1)
    // ...
}
```

**二级页面隐藏 TabBar**（iOS 16+）：

```swift
.toolbar(.hidden, for: .tabBar)
```

### 3. TabBar 外观配置

使用 UIKit 层面配置，比 SwiftUI 修饰符更稳定：

```swift
// SwiftUIApp.swift
private func configureTabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()

    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
        .foregroundColor: UIColor.systemBlue
    ]
    appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
        .foregroundColor: UIColor.systemGray
    ]
    appearance.stackedLayoutAppearance.normal.iconColor = .systemGray

    UITabBar.appearance().standardAppearance = appearance
    if #available(iOS 15.0, *) {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
```

### 4. 导航栏标题

使用 `.toolbar()` 而非 `.navigationTitle()`：

```swift
.toolbar {
    ToolbarItem(placement: .principal) {
        Text("首页")
            .font(.system(size: 17, weight: .semibold))
    }
}
.navigationBarTitleDisplayMode(.inline)
```

### 5. 登录拦截

使用 `.loginGuard()` modifier 在点击时检查登录状态：

```swift
FunctionRow(icon: "star.fill", title: "我的积分")
    .loginGuard(
        isLoggedIn: viewModel.isLoggedIn,
        showLogin: $showLogin
    ) {
        CoinView()
    }
```

---

## 常见问题解答

### Q: 两种依赖方式可以混用吗？

**A**: 可以。Package.swift 定义特殊库，同时可以使用 Registry 获取常用库。

### Q: 如何查看已下载的依赖？

```bash
ls ~/Documents/Swift\ Git/RxStudy/Tuist/.build/checkouts/
```

### Q: 如何清理缓存？

```bash
# 项目级缓存
rm -rf ~/Documents/Swift\ Git/RxStudy/Tuist/.build

# 全局缓存
rm -rf ~/.cache/tuist
```

### Q: 国内使用哪种方式更稳定？

**A**: Package.swift 更稳定，因为只依赖 GitHub，不依赖额外的 Registry 服务。

### Q: 配置后 tuist generate 报错怎么办？

1. 检查参数顺序是否正确
2. 确保 `resourceSynthesizers` 没有使用 `.default`
3. 运行 `tuist clean` 后重试

### Q: 如何锁定 Tuist 版本？

```bash
echo "4.143.0" > .tuist-supported-version
```

---

## 相关文档

- [Tuist 官方文档](https://tuist.dev)
- [Tuist Registry](https://registry.tuist.dev)
- [SwiftUI 迁移工作总结](./MIGRATION_SUMMARY.md)

---

**最后更新**: 2026-03-10
