# Tuist iOS 项目模板

这是一个最小化的 Tuist iOS 项目模板，包含完整注释的配置文件。

## 📁 目录结构

```
Template/
├── Project.swift                # Tuist 项目配置（带完整注释）
├── Tuist/                       # Tuist 配置目录
│   ├── Tuist.swift             # Tuist 配置文件
│   └── Package.swift           # SPM 依赖配置（依赖已注释）
└── AppTemplate/                # 应用源码
    ├── Sources/                 # 源代码文件
    │   ├── AppDelegate.swift
    │   ├── SceneDelegate.swift
    │   └── ViewController.swift
    └── Resources/               # 资源文件
        ├── Info.plist
        └── LaunchScreen.storyboard
```

## 🚀 快速开始

### 1. 复制模板到新位置

```bash
# 复制整个 Template 文件夹到你的项目目录
cp -r /path/to/Template /path/to/MyProject
cd /path/to/MyProject
```

### 2. 修改项目配置

编辑 `Project.swift`，根据需要：

1. **修改项目名称**（第 19 行）
   ```swift
   name: "MyApp",  // 改成你的项目名
   ```

2. **修改 Bundle ID**（第 31 行）
   ```swift
   bundleId: "com.example.AppTemplate",  // 改成你的 Bundle ID
   ```

3. **修改 Team ID**（第 39 行）
   ```swift
   "DEVELOPMENT_TEAM": .string("YOUR_TEAM_ID"),  // 改成你的 Team ID
   ```

4. **添加第三方依赖**

   4.1 在 `Tuist/Package.swift` 中取消注释需要的依赖：
   ```swift
   dependencies: [
       .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
       // ...
   ]
   ```

   4.2 在 `Tuist/Package.swift` 的 `productTypes` 中取消注释：
   ```swift
   productTypes: [
       "Alamofire": .staticFramework,
       // ...
   ]
   ```

   4.3 在 `Project.swift` 的 `dependencies` 中取消注释：
   ```swift
   dependencies: [
       .external(name: "Alamofire"),
       // ...
   ]
   ```

### 3. 生成 Xcode 项目

```bash
# 安装依赖
tuist fetch

# 生成 Xcode 项目
tuist generate

# 打开项目
open AppTemplate.xcodeproj
```

## 📝 常用依赖配置示例

### 示例 1：纯 UIKit + 网络请求

**`Tuist/Package.swift`**:
```swift
dependencies: [
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.3"),
]
```

**`Project.swift`**:
```swift
dependencies: [
    .external(name: "Moya"),
    .external(name: "Alamofire"),
    .external(name: "Kingfisher"),
]
```

### 示例 2：UIKit + RxSwift + 网络

**`Tuist/Package.swift`**:
```swift
dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.9.0"),
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.11.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.3"),
    .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
]
```

**`Project.swift`**:
```swift
dependencies: [
    .external(name: "RxSwift"),
    .external(name: "RxCocoa"),
    .external(name: "RxMoya"),
    .external(name: "Alamofire"),
    .external(name: "Kingfisher"),
    .external(name: "SnapKit"),
]
```

### 示例 3：SwiftUI + async/await

**`Project.swift`**:
```swift
// 添加 SwiftUI Target
.target(
    name: "SwiftUIApp",
    destinations: .iOS,
    product: .app,
    bundleId: "com.example.SwiftUIApp",
    deploymentTargets: .iOS("17.0"),
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "我的应用",
    ]),
    sources: ["SwiftUIApp/Sources/**"],
    resources: ["AppTemplate/Resources/**"],
    dependencies: [
        .external(name: "Moya"),
        .external(name: "Alamofire"),
    ]
)
```

## 🛠️ 自定义配置

### 修改 iOS 部署目标

在 `Project.swift` 中修改：
```swift
// 第 29 行
"IPHONEOS_DEPLOYMENT_TARGET": "16.0",  // 改成你需要的版本
```

同时在 Target 中修改：
```swift
deploymentTargets: .iOS("16.0"),
```

### 修改 Info.plist 配置

在 `Project.swift` 的 `infoPlist` 中添加或修改配置：
```swift
infoPlist: .extendingDefault(
    with: [
        "CFBundleDisplayName": "我的应用",
        // 添加更多配置...
    ]
)
```

### 添加更多 Targets

参考 `Project.swift` 中注释掉的 SwiftUI Target 示例，添加测试 Target、Widget Extension 等。

## 📚 常用命令

```bash
# 查看Tuist版本
tuist version

# 清理缓存
tuist clean

# 安装依赖
tuist fetch

# 生成项目
tuist generate

# 编辑项目
tuist edit

# 查看项目信息
tuist graph
```

## ⚠️ 注意事项

1. **Team ID** - 必须替换为你的 Apple Developer Team ID
2. **Bundle ID** - 建议使用反向域名格式（如 `com.company.app`）
3. **依赖版本** - 根据项目需求调整版本要求
4. **权限描述** - 在 Info.plist 中添加你需要的隐私权限描述

## 📖 参考文档

- [Tuist 官方文档](https://tuist.dev)
- [Swift Package Manager](https://swift.org/package-manager/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

## 🆘 遇到问题？

```bash
# 查看 Tuist 日志
tuist --help

# 清理并重新生成
tuist clean && tuist fetch && tuist generate
```

如有问题，请查阅 Tuist 官方文档或提交 Issue。
