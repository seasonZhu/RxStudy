# SwiftGen 完整使用指南

> Tuist 项目中实现资源类型安全访问的完整指南
> SwiftGen 版本：6.6.3

---

## 目录

1. [什么是 SwiftGen？](#1-什么是-swiftgen)
2. [快速开始](#2-快速开始)
3. [配置文件说明](#3-配置文件说明)
4. [生成的文件](#4-生成的文件)
5. [代码使用示例](#5-代码使用示例)
6. [添加新资源流程](#6-添加新资源流程)
7. [常见问题](#7-常见问题)
8. [最佳实践](#8-最佳实践)

---

## 1. 什么是 SwiftGen？

SwiftGen 是一个**代码生成工具**，可以将资源文件（图片、字符串、字体等）自动转换为**类型安全**的 Swift 代码。

### 优势对比

| 特性 | 传统方式 | SwiftGen |
|------|---------|----------|
| 类型安全 | ❌ 字符串，无编译时检查 | ✅ 枚举类型，编译时检查 |
| 自动补全 | ❌ 需要记住字符串名称 | ✅ 完整 Xcode 自动补全 |
| 重构友好 | ❌ 需手动查找替换 | ✅ 重命名后编译器报错 |
| 拼写错误 | ❌ 运行时才发现 | ✅ 编译时发现 |

### 本项目支持的资源类型

| 类型 | 生成文件 | 访问方式 |
|------|---------|---------|
| 图片/颜色 | `Assets+SwiftGen.swift` | `Asset.xxx.image` / `Asset.xxx.color` |
| 本地化字符串 | `Strings+SwiftGen.swift` | `L10n.xxx.xxx` |

---

## 2. 快速开始

### 2.1 安装 SwiftGen

```bash
brew install swiftgen
```

### 2.2 运行命令

```bash
# 方式一：运行脚本（推荐）
./scripts/swiftgen.sh

# 方式二：直接运行
swiftgen config run --config swiftgen.yml

# 方式三：配合 Tuist
./scripts/swiftgen.sh && tuist generate
```

### 2.3 一键构建（可选）

创建 `Makefile`：

```bash
# Makefile
gen:
	@echo "📦 运行 SwiftGen..."
	@./scripts/swiftgen.sh

generate: gen
	@echo "🔨 生成 Tuist 项目..."
	@tuist generate

build: generate
	@echo "🔨 编译项目..."
	@xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy build

.PHONY: gen generate build
```

使用：
```bash
make build  # 一键完成 SwiftGen + 生成 + 编译
```

---

## 3. 配置文件说明

### 3.1 配置文件位置

项目根目录：`swiftgen.yml`

### 3.2 完整配置内容

```yaml
# 字符串配置 - 只使用中文作为模板源
strings:
  inputs:
    - RxStudy/zh-Hans.lproj
  # 过滤器：只处理 Localizable.strings，排除 InfoPlist.strings
  filter: Localizable\.strings$
  outputs:
    - templateName: structured-swift5
      output: RxStudy/Generated/Strings+SwiftGen.swift
      params:
        enumName: L10n
        publicAccess: true

# Assets 配置 (使用 xcassets parser)
xcassets:
  inputs:
    - RxStudy/Assets.xcassets
  outputs:
    - templateName: swift5
      output: RxStudy/Generated/Assets+SwiftGen.swift
      params:
        enumName: Asset
        publicAccess: true
```

### 3.3 配置说明

| 配置项 | 说明 |
|--------|------|
| `strings.inputs` | 本地化文件目录（中文作为模板） |
| `strings.filter` | 正则过滤，只处理 `Localizable.strings` |
| `strings.outputs.enumName` | 生成的枚举名称 `L10n` |
| `xcassets.inputs` | Assets.xcassets 目录 |
| `xcassets.outputs.enumName` | 生成的枚举名称 `Asset` |

---

## 4. 生成的文件

### 4.1 Assets+SwiftGen.swift

```swift
public enum Asset {
    // TabBar 图标
    public static let home = ImageAsset(name: "home")
    public static let homeSelected = ImageAsset(name: "home_selected")
    public static let project = ImageAsset(name: "project")
    public static let projectSelected = ImageAsset(name: "project_selected")
    public static let my = ImageAsset(name: "my")
    public static let mySelected = ImageAsset(name: "my_selected")
    public static let collect = ImageAsset(name: "collect")
    public static let collectSelected = ImageAsset(name: "collect_selected")

    // 其他图片
    public static let back = ImageAsset(name: "back")
    public static let android = ImageAsset(name: "android")
    public static let loading01 = ImageAsset(name: "loading_01")
    // ... 更多

    // 颜色
    public static let mainTheme = ColorAsset(name: "mainTheme")
}
```

### 4.2 Strings+SwiftGen.swift

```swift
public enum L10n {
    // 通用
    public enum Common {
        public static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "取消")
        public static let confirm = L10n.tr("Localizable", "common.confirm", fallback: "确认")
        public static let loading = L10n.tr("Localizable", "common.loading", fallback: "加载中...")
    }

    // 首页
    public enum Home {
        public static let title = L10n.tr("Localizable", "home.title", fallback: "首页")
        public static let welcome = L10n.tr("Localizable", "home.welcome", fallback: "欢迎使用玩安卓")
    }

    // 项目
    public enum Project {
        public static let list = L10n.tr("Localizable", "project.list", fallback: "项目列表")
        public static let title = L10n.tr("Localizable", "project.title", fallback: "项目")
    }
}
```

---

## 5. 代码使用示例

### 5.1 UIKit 图片资源

#### UIImageView 加载图片

```swift
import UIKit

let imageView = UIImageView()
imageView.image = Asset.android.image  // ✅ 类型安全
imageView.contentMode = .scaleAspectFit
```

#### UIButton 设置图片

```swift
let button = UIButton(type: .system)
button.setImage(Asset.back.image, for: .normal)
button.setImage(Asset.back.image.withRenderingMode(.alwaysTemplate), for: .highlighted)
```

#### Navigation Item

```swift
let backItem = UIBarButtonItem(
    image: Asset.back.image.withRenderingMode(.alwaysOriginal),
    style: .plain,
    target: self,
    action: #selector(backTapped)
)
navigationItem.leftBarButtonItem = backItem
```

### 5.2 SwiftUI 图片资源

```swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image(asset: Asset.home)
                .resizable()
                .frame(width: 24, height: 24)

            Image(asset: Asset.android)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
    }
}
```

### 5.3 TabBar 配置

#### 方式一：直接使用（简单场景）

```swift
let home = HomeViewController()
home.tabBarItem = UITabBarItem(
    title: L10n.Home.title,
    image: Asset.home.image,
    selectedImage: Asset.homeSelected.image
)
```

#### 方式二：通过 TabType 封装（推荐）

```swift
enum TabType: CaseIterable {
    case home, project, my, collect
}

extension TabType {
    var image: UIImage {
        switch self {
        case .home: return Asset.home.image
        case .project: return Asset.project.image
        case .my: return Asset.my.image
        case .collect: return Asset.collect.image
        }
    }

    var selectedImage: UIImage {
        switch self {
        case .home: return Asset.homeSelected.image
        case .project: return Asset.projectSelected.image
        case .my: return Asset.mySelected.image
        case .collect: return Asset.collectSelected.image
        }
    }

    var title: String {
        switch self {
        case .home: return L10n.Home.title
        case .project: return L10n.Project.title
        case .my: return "我的"
        case .collect: return "收藏"
        }
    }
}

// 使用
let vc = UIViewController()
vc.tabBarItem = UITabBarItem(
    title: type.title,
    image: type.image,
    selectedImage: type.selectedImage
)
```

### 5.4 本地化字符串

#### UIKit

```swift
// Label
label.text = L10n.Home.welcome

// Alert
let alert = UIAlertController(
    title: L10n.Common.confirm,
    message: nil,
    preferredStyle: .alert
)

// Button
button.setTitle(L10n.Common.cancel, for: .normal)
```

#### SwiftUI

```swift
struct LoginView: View {
    var body: some View {
        VStack {
            Text(L10n.Home.welcome)
            Button(L10n.Common.confirm) { }
            Button(L10n.Common.cancel) { }
        }
    }
}
```

---

## 6. 添加新资源流程

### 6.1 添加新图片

```
1. 在 Assets.xcassets 中添加图片（如 "new_icon.png"）
       ↓
2. 运行: ./scripts/swiftgen.sh
       ↓
3. 使用: Asset.newIcon.image ✅
```

### 6.2 添加新颜色

```
1. 在 Assets.xcassets 中创建 Color Set
       ↓
2. 命名为 "themeColor"
       ↓
3. 运行: ./scripts/swiftgen.sh
       ↓
4. 使用: Asset.themeColor.color ✅
```

### 6.3 添加本地化字符串

#### 步骤 1：编辑 Localizable.strings

**`RxStudy/zh-Hans.lproj/Localizable.strings`**
```
"new.feature.title" = "新功能";
"new.feature.description" = "这是一个很棒的新功能";
```

**`RxStudy/en.lproj/Localizable.strings`**
```
"new.feature.title" = "New Feature";
"new.feature.description" = "This is an awesome new feature";
```

#### 步骤 2：运行 SwiftGen

```bash
./scripts/swiftgen.sh
```

#### 步骤 3：使用

```swift
let title = L10n.NewFeature.title
let desc = L10n.NewFeature.description
```

### 6.4 添加字体支持（可选）

1. 创建字体目录：
```bash
mkdir -p RxStudy/Resources/Fonts
```

2. 添加 .ttf/.otf 字体文件

3. 在 `swiftgen.yml` 中取消注释 fonts 配置

4. 运行脚本

---

## 7. 常见问题

### Q1: 添加新图片后为什么没有自动生成？

**A**: SwiftGen 不是自动运行的，需要手动执行：

```bash
./scripts/swiftgen.sh
```

### Q2: 生成的文件需要提交到 Git 吗？

**A**: 不需要。生成的文件在 `.gitignore` 中：

```
RxStudy/Generated/
```

团队成员拉取代码后，运行脚本即可重新生成。

### Q3: 不在 Assets.xcassets 中的图片如何使用？

**A**: 保留传统方式：

```swift
// 图片不在 Assets 中
imageView.image = UIImage(named: "user")
```

**建议**：将图片添加到 Assets.xcassets，然后运行 SwiftGen 使用类型安全方式。

### Q4: SwiftGen 与 R.swift 有什么区别？

| 特性 | R.swift | SwiftGen |
|------|---------|----------|
| Tuist 兼容性 | ❌ 不支持 | ✅ 完全支持 |
| 配置方式 | Xcode 插件 | YAML 配置文件 |
| 模板支持 | 有限 | 丰富且可定制 |
| 社区活跃度 | 较少 | 非常活跃 |

### Q5: 项目生成变慢怎么办？

A: 这是 Registry 的已知问题，与 SwiftGen 无关。

---

## 8. 最佳实践

### 8.1 命名规范

**Assets.xcassets**：
- 使用小写字母和下划线：`home_icon`
- 使用描述性名称：`back_button` 而不是 `img1`

**Localizable.strings**：
- 使用点号分隔命名空间：`home.title`
- 按功能分组：`common.confirm`, `common.cancel`

### 8.2 开发流程

```
┌─────────────────────────────────────────────────────┐
│                   开发流程                            │
├─────────────────────────────────────────────────────┤
│  1. 添加资源（Assets.xcassets / .lproj）           │
│     ↓                                               │
│  2. 运行 SwiftGen                                   │
│     ./scripts/swiftgen.sh                          │
│     ↓                                               │
│  3. 使用类型安全 API                                 │
│     Asset.xxx.image / L10n.xxx                     │
│     ↓                                               │
│  4. 编译检查                                        │
└─────────────────────────────────────────────────────┘
```

### 8.3 团队协作

- ✅ `RxStudy/Generated/` 在 `.gitignore` 中
- ✅ 每个开发者运行 `./scripts/swiftgen.sh`
- ✅ 生成的代码完全相同，无冲突

---

## 相关文件

| 文件 | 路径 |
|------|------|
| SwiftGen 配置 | `swiftgen.yml` |
| 运行脚本 | `scripts/swiftgen.sh` |
| 生成目录 | `RxStudy/Generated/` |
| Assets 目录 | `RxStudy/Assets.xcassets` |
| 本地化目录 | `RxStudy/zh-Hans.lproj/` |

---

**文档版本**: v2.0
**更新日期**: 2026-03-11
**SwiftGen 版本**: 6.6.3
