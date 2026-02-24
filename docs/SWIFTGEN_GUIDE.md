# SwiftGen 使用指南

> Tuist + SwiftGen 资源类型安全访问方案

---

## 快速开始

### 运行 SwiftGen 生成代码

```bash
# 运行 SwiftGen 脚本
./scripts/swiftgen.sh

# 然后生成 Tuist 项目
tuist generate
```

### 在代码中使用生成的 API

```swift
// Assets 图片资源（类型安全）
import UIKit

// 旧方式（字符串，无类型检查）
let image = UIImage(named: "back")

// 新方式（SwiftGen 生成，类型安全）
let image = Asset.back.image

// SwiftUI
Image(asset: Asset.back)

// 本地化字符串
// 旧方式
let text = NSLocalizedString("welcome", comment: "")

// 新方式（SwiftGen 生成，类型安全）
let text = L10n.welcome
```

---

## 生成的文件

| 文件 | 作用 |
|------|------|
| `RxStudy/Generated/Assets+SwiftGen.swift` | Assets.xcassets 类型安全访问 |
| `RxStudy/Generated/Strings+SwiftGen.swift` | 本地化字符串类型安全访问 |

---

## 工作流程

### 日常开发流程

```
┌─────────────────────────────────────────────────────────────┐
│              开发流程                                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 在 Assets.xcassets 中添加新图片                         │
│     或在 .lproj 中添加本地化字符串                            │
│     ↓                                                       │
│  2. 运行 SwiftGen 脚本                                     │
│     ./scripts/swiftgen.sh                                   │
│     ↓                                                       │
│  3. SwiftGen 自动生成代码                                  │
│     RxStudy/Generated/*.swift                               │
│     ↓                                                       │
│  4. 在代码中使用类型安全访问                               │
│     Asset.newImage.image                                   │
│     L10n.newString                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 推荐的工作方式

**方式 1：手动运行（推荐）**

```bash
# 添加资源后手动运行
./scripts/swiftgen.sh && tuist generate
```

**方式 2：自动化（可选）**

创建 `Makefile` 或自定义脚本：

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

## SwiftGen 配置说明

### 配置文件：swiftgen.yml

```yaml
# 字符串配置
strings:
  inputs:
    - RxStudy/Base.lproj
    - RxStudy/zh-Hans.lproj
    - RxStudy/en.lproj
  filter: .[^/]+(?<!InfoPlist)\.strings$  # 排除 InfoPlist.strings
  outputs:
    - templateName: structured-swift5
      output: RxStudy/Generated/Strings+SwiftGen.swift
      params:
        enumName: L10n
        publicAccess: true

# Assets 配置
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

---

## 使用示例

### Assets 图片资源

```swift
import UIKit

// 获取 UIImage
let backImage = Asset.back.image
let homeImage = Asset.home.image

// SwiftUI
import SwiftUI
struct HomeView: View {
    var body: some View {
        Image(asset: Asset.home)
    }
}
```

### 本地化字符串

```swift
// 使用生成的 L10n 枚举
let welcomeText = L10n.welcome
let loginButton = L10n.Login.button

// 支持参数化字符串
// Localizable.strings: "Hello %@"
L10n.hello("World")
```

---

## 常见问题

### Q1: 添加新图片后为什么没有自动生成？

**A**: SwiftGen 不是自动运行的，需要手动执行脚本：

```bash
./scripts/swiftgen.sh
```

### Q2: 生成的文件需要提交到 Git 吗？

**A**: 不需要。生成的文件在 `.gitignore` 中：

```
RxStudy/Generated/
```

团队成员拉取代码后，运行脚本即可重新生成。

### Q3: SwiftGen 与 R.swift 有什么区别？

| 特性 | R.swift | SwiftGen |
|------|---------|----------|
| Tuist 兼容性 | ❌ 不支持 | ✅ 完全支持 |
| 配置方式 | Xcode 插件 | YAML 配置文件 |
| 模板支持 | 有限 | 丰富且可定制 |
| 社区活跃度 | 较少 | 非常活跃 |

---

## 添加新资源类型

### 添加字体支持

1. 创建字体目录：
```bash
mkdir -p RxStudy/Resources/Fonts
```

2. 添加 .ttf/.otf 字体文件

3. 在 `swiftgen.yml` 中取消注释 fonts 配置

4. 运行脚本：
```bash
./scripts/swiftgen.sh
```

### 添加 JSON/YAML 文件支持

1. 创建资源目录：
```bash
mkdir -p RxStudy/Resources/JSON
```

2. 在 `swiftgen.yml` 中添加：

```yaml
files:
  inputs:
    - RxStudy/Resources/JSON
  outputs:
    - templateName: inline-swift5
      output: RxStudy/Generated/JSON+SwiftGen.swift
      params:
        enumName: JSONFile
        publicAccess: true
```

---

## 总结

| 优势 | 说明 |
|------|------|
| ✅ 类型安全 | 编译时检查，避免拼写错误 |
| ✅ 自动补全 | Xcode 完整支持 |
| ✅ 重构友好 | 资源名称修改时自动更新 |
| ✅ Tuist 兼容 | 完美集成 Tuist 工作流 |
| ✅ 轻量级 | 无需 Xcode 插件 |

---

**文档版本**: v1.0
**更新日期**: 2026-02-24
**SwiftGen 版本**: 6.6.3
