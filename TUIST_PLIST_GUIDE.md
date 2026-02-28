# Tuist Plist 资源合成器配置指南

## 概述

Tuist 默认会为项目中的 **Info.plist 文件** 和 **第三方库许可证** 自动生成代码文件：

- `TuistPlists+<项目名>.swift` - 包含所有 SPM 依赖的许可证信息
- `TuistBundle+<项目名>.swift` - Bundle 扩展
- `TuistAssets+<项目名>.swift` - Assets 扩展

这些文件存储在：`Derived/Sources/` 目录

---

## PodsRxStudyAcknowledgements 生成机制

### 自动生成的内容

`TuistPlists+RxStudy.swift` 包含：

```swift
public enum PodsRxStudyAcknowledgements: Sendable {
    public static let preferenceSpecifiers: [[String: Any]] = [
        // 包含所有第三方库的许可证信息
        // - AcknowList (MIT)
        // - Alamofire (MIT)
        // - RxSwift (MIT)
        // - ... 等等
    ]
}
```

### 数据来源

Tuist 会自动扫描：
1. **Tuist/Package.swift** 中的依赖
2. **Project.swift** 中的 dependencies
3. 从每个 SPM 包的 Package.swift 或 LICENSE 文件提取许可证信息

---

## 禁用 Plist 资源合成器

### 原因

如果使用 **AcknowList** + **自己的 `Pods-RxStudy-acknowledgements.plist`**，Tuist 自动生成的 `TuistPlists+RxStudy.swift` 就不需要了。

### 配置方法

在 **Project.swift** 中添加 `resourceSynthesizers` 配置：

```swift
let project = Project(
    // ... 其他配置

    // ========== 禁用 Plist 资源合成器 ==========
    resourceSynthesizers: .default + [
        .assets(),        // ✅ 保留：Assets 合成器
        .strings(),      // ✅ 保留：Strings 合成器
        .coreData(),      // ✅ 保留：CoreData 合成器
        .files(),         // ✅ 保留：Files 合成器
        // ❌ 不添加 .plist()，禁用 Plist 合成器
    ],

    // ... 其他配置
)
```

### 效果

- ✅ **不再生成** `TuistPlists+RxStudy.swift` 文件
- ✅ **保留其他**资源合成器功能（Assets、Strings 等）
- ✅ 使用自己的 `Pods-RxStudy-acknowledgements.plist` + AcknowList

---

## 完整配置示例

```swift
import ProjectDescription

let project = Project(
    name: "RxStudy",
    targets: [
        .target(
            name: "RxStudy",
            // ... 其他配置

            resources: [
                "RxStudy/Pods-RxStudy-acknowledgements.plist",  // 手动管理的许可证文件
            ],

            dependencies: [
                .external(name: "AcknowList"),  // 使用 AcknowList 读取 plist
            ]
        )
    ],

    // ========== 禁用 Plist synthesizer ==========
    resourceSynthesizers: .default + [
        .assets(),
        .strings(),
        .coreData(),
        .files(),
    ]
)
```

---

## 替代方案

### 方案 1：完全禁用资源合成器

```swift
resourceSynthesizers: []  // 完全禁用所有自动生成
```

### 方案 2：仅禁用 Plist synthesizer

```swift
resourceSynthesizers: .default + [
    .assets(),
    .strings(),
    .coreData(),
    .files(),
    // 不添加 .plist()
]
```

### 方案 3：使用自定义 Plist synthesizer（高级）

```swift
resourceSynthesizers: .default + [
    .custom(
        type: "plist",
        parser: .directory(
            selector: "InfoPlist",  // 只处理特定的 plist 文件
            extensions: ["plist"]
        )
    ),
]
```

---

## 清理已生成的文件

### 删除旧的生成文件

```bash
# 删除自动生成的 Plist 文件
rm -rf Derived/Sources/TuistPlists+RxStudy.swift

# 重新生成项目
tuist generate
```

### 清理所有生成文件

```bash
# 清理并重新生成
tuist clean
tuist generate
```

---

## 验证配置

### 检查生成结果

```bash
# 查看 Derived/Sources 目录
ls -la Derived/Sources/

# 确认 TuistPlists+RxStudy.swift 不存在
ls -la Derived/Sources/TuistPlists+RxStudy.swift
# 应该显示：No such file or directory
```

---

## 常见问题

### Q: 禁用后会影响其他功能吗？

**A**: 不会。只禁用了 Plist synthesizer，其他合成器（Assets、Strings 等）仍然正常工作。

### Q: 如何恢复自动生成？

**A**: 删除 `resourceSynthesizers` 配置或添加 `.plist()` 即可：

```swift
resourceSynthesizers: .default + [
    .assets(),
    .strings(),
    .coreData(),
    .files(),
    .plist(),  // 恢复 Plist synthesizer
]
```

### Q: 如果项目中没有 Info.plist 会怎样？

**A**: Tuist 会自动生成一个基础的 Info.plist。resourceSynthesizers 配置不影响这个。

---

## 最佳实践

### ✅ 推荐

1. **使用手动管理的许可证文件**
   - 从 develop 分支获取 `Pods-RxStudy-acknowledgements.plist`
   - 放在项目根目录
   - 使用 AcknowList 读取

2. **禁用自动生成的 Plist synthesizer**
   - 避免重复代码
   - 保持许可证文件的一致性

3. **保留其他资源合成器**
   - Assets - 自动生成图片资源访问代码
   - Strings - 自动生成本地化字符串访问代码

### ❌ 不推荐

1. 同时使用自动生成和手动管理
2. 完全禁用所有 resourceSynthesizers（除非不需要）

---

**最后更新**: 2026-02-28
