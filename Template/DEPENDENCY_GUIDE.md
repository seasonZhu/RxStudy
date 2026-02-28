# Tuist 依赖管理指南

本指南详细说明 Tuist 的两种依赖管理方式及其使用场景。

## 目录

1. [重要说明](#重要说明)
2. [推荐方式：Package.swift](#推荐方式packageswift)
3. [可选方式：Tuist Registry](#可选方式tuist-registry)
4. [两种方式对比](#两种方式对比)
5. [常见场景](#常见场景)
6. [迁移指南](#迁移指南)
7. [最佳实践](#最佳实践)
8. [FAQ](#faq)

---

## 重要说明

### ⚠️ 关于 Tuist Registry

Tuist Registry (`registry.tuist.dev`) 在国内可能**无法直接访问**。

**本模板默认不启用 Registry**，使用更通用的 **Package.swift** 方式。

如果你可以访问 Registry（例如使用代理），可以在 `Tuist/Tuist.swift` 中启用：

```swift
// Tuist/Tuist.swift - 取消注释以启用
let config = Config(
    dependencies: [
        // .remote(url: "https://registry.tuist.dev", name: "Tuist"),
    ]
)
```

---

## 推荐方式：Package.swift

### 配置

**Tuist/Package.swift**（已包含在模板中）：

```swift
import ProjectDescription

let package = Package(
    name: "AppTemplate",
    dependencies: [
        // 在这里添加依赖
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
    ],
    productTypes: [
        // 可选：指定产品类型
        "Alamofire": .staticFramework,
    ]
)
```

### 使用

**Project.swift**：

```swift
targets: [
    .target(
        name: "AppTemplate",
        dependencies: [
            .external(name: "Alamofire"),
        ]
    )
]
```

### 添加依赖步骤

```bash
1. 修改 Tuist/Package.swift，添加 .package(...)
2. 修改 Project.swift，添加 .external(name: "...")
3. 运行 tuist install
```

### 版本指定

```swift
// 精确版本
.package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.11.0")

// 范围版本
.package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0")
.package(url: "https://github.com/Alamofire/Alamofire.git", "5.11.0"..."6.0.0")

// 分支
.package(url: "https://github.com/Alamofire/Alamofire.git", branch: "main")

// 提交
.package(url: "https://github.com/Alamofire/Alamofire.git", revision: "abc123")

// 本地路径
.package(path: "../LocalSPMPackage")
```

### 产品类型

```swift
productTypes: [
    // 动态框架
    "Alamofire": .framework,

    // 静态框架
    "Moya": .staticFramework,

    // 动态库
    "SomeLib": .dynamicLibrary,

    // 静态库
    "SomeLib": .staticLibrary,
]
```

### 优点

✅ **无网络限制** - 不依赖外部服务
✅ **版本控制** - 完全控制版本
✅ **全平台支持** - 所有 SPM 库都可用
✅ **团队一致** - Package.swift 可以提交到 Git
✅ **本地包支持** - 支持本地 SPM 包

### 缺点

❌ **两个文件** - 需要同时修改 Package.swift 和 Project.swift
❌ **手动管理** - 版本冲突需要手动处理

---

## 可选方式：Tuist Registry

### ⚠️ 前提条件

- 可以访问 `registry.tuist.dev`
- 或使用网络代理

### 配置

**Tuist/Tuist.swift**（需要取消注释）：

```swift
let config = Config(
    dependencies: [
        .remote(url: "https://registry.tuist.dev", name: "Tuist"),
    ]
)
```

### 使用

**只需要修改 Project.swift**：

```swift
targets: [
    .target(
        name: "AppTemplate",
        dependencies: [
            // ✅ 直接使用，无需 Package.swift
            .external(name: "Alamofire"),
            .external(name: "Kingfisher"),
        ]
    )
]
```

### 运行

```bash
tuist install  # 自动从 Registry 获取依赖
tuist generate
```

### 可用的常用库

Tuist Registry 包含大部分常用库：

| 类别 | 库名 |
|------|------|
| **网络** | Alamofire, Moya, Apollo |
| **响应式** | RxSwift, RxCocoa, RxRelay, CombineExt |
| **UI** | Kingfisher, Nuke, SnapKit, lottie-ios |
| **工具** | SwiftyJSON, KeychainAccess, SwiftLint |
| **架构** | TCA, UIKit-Plus |
| **其他** | Firebase, Sentry, CocoaLumberjack |

> 💡 查询可用库：访问 [registry.tuist.dev](https://registry.tuist.dev)

### 优点

✅ **简单** - 只需修改 Project.swift
✅ **自动化** - 版本自动管理

### 缺点

❌ **网络限制** - 国内可能无法访问
❌ **库限制** - 只有 Registry 中的库

---

## 两种方式对比

| 特性 | Tuist Registry | 本地 Package.swift |
|------|----------------|-------------------|
| **配置文件** | 仅 Project.swift | Package.swift + Project.swift |
| **易用性** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **灵活性** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **依赖可用性** | Registry 中的库 | 任意 SPM 库 |
| **版本控制** | 自动管理 | 手动指定 |
| **网络要求** | 需要 VPN/代理 | GitHub 即可 |
| **推荐场景** | 常用库 | 默认推荐 |

---

## 常见场景

### 场景 1：添加常用库（Alamofire）

**推荐：Package.swift**

```swift
// Tuist/Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
]

// Project.swift
dependencies: [
    .external(name: "Alamofire"),
]
```

**可选：Registry（需要代理）**

```swift
// Project.swift - 只需修改这里
dependencies: [
    .external(name: "Alamofire"),
]
```

### 场景 2：使用特定版本的库

**必须使用 Package.swift**：

```swift
// Tuist/Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.9.0"),
]

// Project.swift
dependencies: [
    .external(name: "Alamofire"),
]
```

### 场景 3：使用 GitHub 上的库但不在 Registry

**必须使用 Package.swift**：

```swift
// Tuist/Package.swift
dependencies: [
    .package(url: "https://github.com/example/UnknownLib.git", from: "1.0.0"),
]

// Project.swift
dependencies: [
    .external(name: "UnknownLib"),
]
```

### 场景 4：混合使用两种方式

**可以同时使用**：

```swift
// Tuist/Package.swift - 特殊库
dependencies: [
    .package(url: "https://github.com/example/SpecialLib.git", from: "1.0.0"),
]

// Project.swift - 混合使用
dependencies: [
    // Registry 中的库（需要代理）
    .external(name: "Alamofire"),
    .external(name: "Kingfisher"),
    // Package.swift 中的库
    .external(name: "SpecialLib"),
]
```

### 场景 5：本地 SPM 包

**使用本地依赖**：

```swift
// Tuist/Package.swift
dependencies: [
    .package(path: "../LocalSPMPackage"),
]

// Project.swift
dependencies: [
    .package(product: "LocalSPMPackage", type: .static),
]
```

---

## 迁移指南

### 从 Registry 迁移到 Package.swift

**步骤**：

1. 在 Package.swift 中添加依赖
2. 保持 Project.swift 不变
3. 运行 `tuist install`

```swift
// Tuist/Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
]

// Project.swift 保持不变
dependencies: [
    .external(name: "Alamofire"),  // 保持不变
]
```

### 从 Package.swift 迁移到 Registry

**步骤**：

1. 确保可以访问 registry.tuist.dev
2. 从 Package.swift 删除依赖
3. 在 Tuist.swift 中启用 Registry
4. 运行 `tuist install`

```bash
# 1. 查询库是否可用
curl https://registry.tuist.dev/projects/Alamofire

# 2. 从 Package.swift 删除
# .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),

# 3. Tuist/Tuist.swift - 启用 Registry
# .remote(url: "https://registry.tuist.dev", name: "Tuist"),

# 4. Project.swift 保持不变
# .external(name: "Alamofire"),

# 5. 重新安装
tuist install
```

---

## 最佳实践

### 1. 默认使用 Package.swift

```swift
// ✅ 推荐 - 无网络限制
// Tuist/Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
]

// Project.swift
dependencies: [
    .external(name: "Alamofire"),
]
```

### 2. 提交 Package.swift 到 Git

```bash
# ✅ 确保团队依赖一致
git add Tuist/Package.swift
git commit -m "Add Alamofire dependency"
```

### 3. 使用版本范围而非精确版本

```swift
// ✅ 推荐 - 允许小版本更新
.package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0")

// ⚠️ 谨慎使用 - 锁定特定版本
.package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.11.0")
```

### 4. 静态链接常用库

```swift
// ✅ 推荐 - 减少启动时间
productTypes: [
    "Alamofire": .staticFramework,
    "SnapKit": .staticFramework,
]
```

### 5. 版本锁定

```bash
# 使用 .tuist-supported-version 锁定 Tuist 版本
echo "3.18.0" > .tuist-supported-version

# 在 CI 中验证
tuist validate
```

---

## 依赖版本查看

### 查看 Package.swift 依赖版本

```bash
# 查看当前项目依赖
tuist generate --verbose

# 查看依赖图
tuist graph
```

### 查询 Registry

```bash
# 查询特定库（需要能访问 Registry）
curl https://registry.tuist.dev/projects/Alamofire

# 查询所有库
curl https://registry.tuist.dev/projects
```

### 依赖冲突解决

```bash
# 清理并重新安装
tuist clean
rm -rf ~/.tuist/cache
rm -rf ~/Library/Caches/tuist
tuist install
```

---

## FAQ

### Q: 我应该使用哪种方式？

**A**: 默认使用 **Package.swift**，因为：
- ✅ 无网络限制（只需访问 GitHub）
- ✅ 支持所有 SPM 库
- ✅ 完全控制版本

只有当你可以访问 Registry 且追求简单性时，才考虑使用 Registry。

### Q: 两种方式可以混用吗？

**A**: 可以！你可以在 Package.swift 中定义特殊库，同时使用 Registry 获取常用库。

### Q: 如何知道库是否在 Registry 中？

**A**: 访问 [registry.tuist.dev](https://registry.tuist.dev) 或使用 `curl https://registry.tuist.dev/projects/库名` 查询。

### Q: Package.swift 可以删除吗？

**A**: 不建议删除。即使留空，也建议保留以便后续添加依赖。

### Q: 如何避免版本冲突？

**A**: 使用 Package.swift 时需要注意版本兼容性。建议：
1. 使用版本范围（`from: "5.11.0"`）而非精确版本
2. 定期更新依赖并测试
3. 使用 `tuist graph` 查看依赖关系

### Q: 国内使用哪种方式更稳定？

**A**: **Package.swift 更稳定**，因为：
- GitHub 国内访问相对稳定
- 不依赖额外的 Registry 服务
- 团队成员都能正常使用

---

## 相关文档

- [Tuist Registry](https://registry.tuist.dev) - 可能需要代理
- [Tuist 依赖文档](https://tuist.dev/docs/en/guides/dependencies/)
- [SPM 依赖规范](https://swift.org/package-manager/#/package-manager/dependencies)
- [Tuist 配置指南](./TUIST_CONFIG_GUIDE.md)
- [Tuist 安装指南](./TUIST_INSTALLATION_GUIDE.md)

---

**最后更新**: 2026-02-27
