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

### 版本指定方式对比

| 方式 | 语法 | 说明 | 稳定性 | 推荐场景 |
|------|------|------|--------|----------|
| **版本范围** | `from: "1.8.1"` | 使用 1.8.1 及以上兼容版本 | ⭐⭐⭐⭐⭐ | 默认推荐，自动获取小版本更新 |
| **精确版本** | `exact: "1.8.1"` | 锁定 1.8.1 版本 | ⭐⭐⭐⭐⭐ | 生产环境，需要完全确定版本 |
| **分支** | `branch: "master"` | 使用指定分支最新代码 | ⭐⭐⭐ | 开发环境，尝鲜新特性 |
| **修订** | `revision: "abc123"` | 使用指定提交哈希 | ⭐⭐⭐⭐ | 需要特定提交或修复 |
| **范围区间** | `"1.8.0"..."2.0.0"` | 版本范围区间 | ⭐⭐⭐⭐ | 限制大版本更新范围 |
| **本地路径** | `path: "../Lib"` | 使用本地包 | ⭐⭐⭐ | 本地开发或私有包 |

#### 使用建议

```swift
// ✅ 推荐：生产环境使用版本范围
.package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0")

// ✅ 推荐：需要精确控制版本
.package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.11.0")

// ⚠️ 谨慎使用：主分支（代码可能不稳定）
// DZNEmptyDataSet 示例：该库的 tagged 版本不支持 SPM，必须使用 master 分支
.package(url: "https://github.com/dzenbot/DZNEmptyDataSet.git", branch: "master")

// ⚠️ 特殊场景：特定提交（如临时修复）
.package(url: "https://github.com/example/Lib.git", revision: "abc123def")

// ✅ 本地开发
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

### 场景 6：添加需要额外资源文件的库（AcknowList）

某些库需要额外的资源文件（如 plist、bundle 等），以 AcknowList 为例：

**背景**：AcknowList 用于显示应用的第三方库许可证列表，需要 acknowledgements.plist 文件。

**步骤**：

```swift
// 1. Tuist/Package.swift - 添加依赖
dependencies: [
    .package(url: "https://github.com/vtourraine/AcknowList.git", from: "3.4.0"),
]
productTypes: [
    "AcknowList": .staticFramework,
]

// 2. Project.swift - 添加依赖和资源文件
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .external(name: "AcknowList"),
        ],
        resources: [
            "MyApp/Pods-MyApp-acknowledgements.plist",  // 许可证列表文件
        ]
    )
]

// 3. 在代码中使用
import AcknowList

let list = AcknowParser.defaultAcknowList()?.acknowledgements ?? []
```

**获取 acknowledgements.plist 文件**：

- **CocoaPods 项目**：自动生成在 `Pods/Target Support Files/Pods-<target>/Pods-<target>-acknowledgements.plist`
- **SPM 项目**：需要手动创建或从其他分支获取
- **文件位置**：放在项目根目录，确保 `Bundle.main.path(forResource:ofType:)` 能找到

**注意事项**：
- plist 文件名必须为 `Pods-<CFBundleName>-acknowledgements.plist`
- 文件需要在 Project.swift 的 resources 中声明
- AcknowList 会自动解析并显示许可证信息

### 场景 7：使用本地依赖（修复远程 Package.swift 问题）

**背景**：某些库的 Package.swift 格式错误，无法直接通过 URL 使用。

**解决方案**：下载到本地，修复 Package.swift，然后作为本地包使用。

**以 FSPagerView 为例**：

```swift
// 1. 下载库源码到本地
// cd Packages/ThirdParty
// git clone https://github.com/wenchao-d/FSPagerView.git

// 2. 修复 Package.swift（调整路径配置）
// 详见 Packages/ThirdParty/FSPagerView/Package.swift

// 3. Tuist/Package.swift - 添加本地路径依赖
dependencies: [
    .package(path: "../Packages/ThirdParty/FSPagerView"),
]
productTypes: [
    "FSPagerView": .staticFramework,
]

// 4. Project.swift - 引用依赖
dependencies: [
    .external(name: "FSPagerView"),
]

// 5. 移除源码集成方式（如果之前使用）
// sources 中删除：
// "Packages/ThirdParty/FSPagerView/Sources/**/*.swift",
// "Packages/ThirdParty/FSPagerView/Sources/*.m",
```

**本地依赖的优点**：
- ✅ 可以修复 Package.swift 的问题
- ✅ 可以修改库的源码（如需要）
- ✅ 不受远程仓库更新影响

**注意事项**：
- ⚠️ 本地路径是相对于 Tuist/Package.swift 的相对路径
- ⚠️ 团队成员需要有相同的本地目录结构
- ⚠️ 建议将本地依赖提交到 Git 仓库中

### 场景 8：将源码库制作成本地 SPM 包

**背景**：某些库没有 Package.swift 文件，或者你想将现有的源码集成方式改为 SPM 包管理。

**解决方案**：手动创建 Package.swift 文件，将库转换为 SPM 包。

**以 TheRouter 为例**：

```swift
// 1. 创建目录结构
Packages/ThirdParty/TheRouter/
├── Package.swift          // 手动创建
└── Sources/
    ├── include/           // 创建此目录存放公开的头文件
    │   ├── TheRouterableProxy.h
    │   └── TheRouterDynamicParamsMapping.h
    ├── *.swift            // Swift 源文件
    ├── *.h                // 头文件（原始位置保留）
    └── *.m                // Objective-C 实现

// 2. 创建 Package.swift
// Packages/ThirdParty/TheRouter/Package.swift
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
            sources: ["."],
            publicHeadersPath: "include",  // 公开头文件目录
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
            ]
        ),
    ]
)

// 3. Tuist/Package.swift - 添加本地路径依赖
dependencies: [
    .package(path: "../Packages/ThirdParty/TheRouter"),
]
productTypes: [
    "TheRouter": .staticFramework,
]

// 4. Project.swift - 添加 SPM 依赖
dependencies: [
    .external(name: "TheRouter"),
]

// 5. 移除源码集成方式
// sources 中删除：
// "Packages/ThirdParty/TheRouter/Sources/**",

// 6. 更新 HEADER_SEARCH_PATHS（如果需要）
// 移除 TheRouter 的头文件搜索路径，SPM 会自动管理
```

**关键步骤说明**：

1. **创建 Package.swift**：
   - `name`: 包名称
   - `platforms`: 支持的平台和最低版本
   - `path: "Sources"`: 源码目录
   - `sources: ["."]`: 包含所有源文件
   - `publicHeadersPath`: Objective-C 公开头文件目录

2. **处理 Objective-C 头文件**：
   - 创建 `Sources/include/` 目录
   - 将需要公开的头文件复制到 `include/` 目录
   - 设置 `publicHeadersPath: "include"`

3. **配置链接设置**（可选）：
   - 使用 `linkerSettings` 添加依赖的系统框架
   - 如 UIKit、Foundation 等

4. **迁移步骤**：
   - 创建 Package.swift
   - 整理目录结构（include 目录）
   - 更新 Tuist/Package.swift
   - 更新 Project.swift（移除源码集成，添加 SPM 依赖）
   - 运行 `tuist install` 验证

**本地 SPM 包的优点**：
- ✅ 统一依赖管理方式（全部使用 SPM）
- ✅ 自动处理头文件路径
- ✅ 更清晰的依赖关系
- ✅ 可以修改库的源码（如需要）
- ✅ 不受远程仓库更新影响

**与源码集成的对比**：

| 特性 | 源码集成 | 本地 SPM 包 |
|------|---------|-------------|
| **头文件管理** | 手动配置 HEADER_SEARCH_PATHS | SPM 自动管理 |
| **依赖声明** | sources 中列出源文件路径 | dependencies 中声明 |
| **可维护性** | 较低，路径易出错 | 较高，配置集中 |
| **迁移成本** | 无需创建 Package.swift | 需要创建 Package.swift |
| **推荐场景** | 临时集成、快速测试 | 长期使用的依赖 |

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

### Q: 什么时候应该使用 branch 而不是 from？

**A**: 使用 `branch` 的场景：
- ❌ 库的 tagged 版本不支持 SPM（如 DZNEmptyDataSet）
- ⚠️ 需要测试尚未发布的最新功能
- ⚠️ 临时使用某个分支的 bug 修复

**示例**：
```swift
// DZNEmptyDataSet 的 tagged 版本没有 Package.swift，必须使用 master
.package(url: "https://github.com/dzenbot/DZNEmptyDataSet.git", branch: "master")

// FlexLayout 使用正常的版本范围
.package(url: "https://github.com/layoutBox/FlexLayout.git", from: "2.2.3")
```

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

**最后更新**: 2026-02-28
