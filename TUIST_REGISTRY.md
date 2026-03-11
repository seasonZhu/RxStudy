# Tuist Registry 使用指南

> 原文：[Resolving Swift Packages faster With Registry from Tuist](https://toyboy2.medium.com/resolving-swift-packages-faster-with-registry-from-tuist-0bfb797c33c2)
> 作者：Lee young-jun
> 日期：2025年12月16日
> 翻译整理

---

## 目录

1. [概述](#概述)
2. [什么是 Registry？](#什么是-registry)
3. [配置 Registry](#配置-registry)
4. [将 URL 替换为 ID](#将-url-替换为-id)
5. [性能对比](#性能对比)
6. [CI/CD 使用](#cicd-使用)
7. [常见问题](#常见问题)
8. [总结](#总结)

---

## 概述

Tuist 现已开放 Swift Package Registry，**无需 Tuist 账户**即可使用 Registry。

> ⚠️ **更新**：Tuist Registry 之前需要登录流程，但团队最近决定**取消认证和账户创建的要求**。

---

## 什么是 Registry？

Registry 是 Tuist 的功能之一。当我们在 Xcode 中查看 Package Dependencies 时，通常会消耗大量时间和内存。

Tuist 的 Registry 基于 **[Swift Package Index](https://swiftpackageindex.com)**，使用 ID 代替 URL 来查找 Swift 包。

### 包 ID 示例

| 库名 | 包 ID |
|------|-------|
| Firebase iOS SDK | `firebase/firebase-ios-sdk` |
| Alamofire | `alamofire/alamofire` |
| SnapKit | `snapkit/snapkit` |

> 💡 也可以在 Swift Package Manager 中配合 Registry 使用：
> ```bash
> swift package --replace-scm-with-registry resolve
> ```

---

## 配置 Registry

### 1. 运行设置命令

```bash
tuist registry setup
```

此命令会生成 Registry 的配置文件 `registries.json`：

```json
{
    "security": {
        "default": {
            "signing": {
                "onUnsigned": "silentAllow"
            }
        }
    },
    "authentication": {
        "tuist.dev": {
            "loginAPIPath": "/api/registry/swift/login",
            "type": "token"
        }
    },
    "registries": {
        "[default]": {
            "supportsAvailability": false,
            "url": "https://tuist.dev/api/registry/swift"
        }
    },
    "version": 1
}
```

### 2. 速率限制

- 可以**无需登录**使用 Registry
- 速率限制：**每 IP 每分钟 1000 次请求**
- 个人项目一般不会达到限制

### 3. 常见错误

如果未运行 `registry setup` 就执行安装，会遇到以下错误：

```
error: no registry configured for 'alamofire' scope
```

运行 `tuist registry setup` 后即可解决。

---

## 将 URL 替换为 ID

### 方式一：修改 Package.swift

**修改前**（使用 URL）：
```swift
let package = Package(
    ...,
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.8.1")
    ],
)
```

**修改后**（使用 ID）：
```swift
let package = Package(
    ...,
    dependencies: [
        .package(id: "firebase.firebase-ios-sdk", from: "11.8.1")
    ],
)
```

### 方式二：修改 Project.swift

**修改前**（使用 URL）：
```swift
let project = Project(
    ...,
    packages: [
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk",
            requirement: .upToNextMajor(from: "11.8.1")
        ),
    ],
)
```

**修改后**（使用 ID）：
```swift
let project = Project(
    ...,
    packages: [
        .remote(
            url: "firebase.firebase-ios-sdk",
            requirement: .upToNextMajor(from: "11.8.1")
        ),
    ],
)
```

> ⚠️ **注意**：使用 ID 后，依赖的引用方式与 URL 完全相同：
> ```swift
> dependencies: [
>     .package(product: "FirebaseCore"),
> ]
> ```

---

## 性能对比

测试环境：清除 `/Library/Caches/org.swift.swiftpm/` 后的干净状态。

### 1. 包安装时间

| 方式 | 时间 | 相对值 |
|------|------|--------|
| **使用 URL** | 100% | 基准 |
| **使用 Registry** | 35% | **快 65%** ✅ |

### 2. 项目生成时间

| 方式 | 时间 | 相对值 |
|------|------|--------|
| **使用 URL** | 100% | 基准 |
| **使用 Registry** | 230% | **慢 2.3 倍** ⚠️ |

> 📝 项目生成变慢的原因：Registry 无法帮助增量构建。

### 3. 项目构建时间

| 方式 | 性能 |
|------|------|
| **使用 URL** | 基准 |
| **使用 Registry** | 略快 ✅ |

### 4. 官方基准测试

根据官方测试结果（73 个依赖的 Package 4）：

- 使用 Registry 和缓存，**构建速度可提升 86%**
- 缓存体积更小，有助于提升速度

---

## CI/CD 使用

### GitHub Workflow 配置

```yaml
jobs:
  build:
    runs-on: macos-15

    steps:
      - name: Checkout project
        uses: actions/checkout@v4

      - name: Install Mise
        uses: jdx/mise-action@v2

      - name: Setup Registry
        run: tuist registry setup

      - name: Install Packages
        run: tuist install

      - name: Build
        run: tuist build
```

### 缓存优化

根据官方 CI 指南配置缓存后，第二次构建的包安装时间显著减少：

| 构建次数 | 安装时间 |
|----------|----------|
| 首次构建 | 53s |
| 第二次构建（带缓存） | **11s** ✅ |

---

## 常见问题

### Q: 为什么需要使用 Registry？

A: 使用 Registry 可以显著**加快包解析速度**（减少 65%），特别是在 CI/CD 环境中效果明显。

### Q: 项目生成变慢怎么办？

A: 这是已知问题。可以考虑：
- 在 CI 中启用缓存
- 仅在需要时使用 Registry
- 继续使用传统 URL 方式

### Q: 国内可以使用吗？

A: Registry 依赖 `tuist.dev` 域名，国内可能需要代理。

### Q: 如何查找包的 ID？

A: 访问 [Swift Package Index](https://swiftpackageindex.com)，搜索即可找到对应的包 ID。

---

## 总结

| 指标 | Registry 表现 |
|------|--------------|
| **包解析速度** | ✅ 显著提升（减少 65%） |
| **项目生成速度** | ⚠️ 变慢（约 2.3 倍） |
| **构建速度** | ✅ 略有提升 |
| **缓存效果** | ✅ 显著提升（尤其在 CI 中） |

### 使用建议

- ✅ **推荐**：在 CI/CD 环境中使用 Registry，首次安装后配合缓存效果更佳
- ⚠️ **注意**：本地开发时项目生成会变慢，可根据实际情况选择

---

## 相关链接

- [Swift Package Index](https://swiftpackageindex.com)
- [Tuist 官方文档](https://tuist.dev)
- [官方基准测试](https://docs.tuist.io)
- [Tuist Registry 官方指南](https://tuist.dev/docs/guides/dependencies)

---

**祝您使用愉快！**
