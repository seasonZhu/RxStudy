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

### ✅ 验证通过的配置方法

在 **Project.swift** 中添加 `resourceSynthesizers` 配置（**注意：不使用 `.default`**）：

```swift
let project = Project(
    name: "RxStudy",
    // ... 其他配置

    targets: [
        .target(
            name: "RxStudy",
            // ... target 配置
        )
    ],

    schemes: [
        // ... schemes 配置
    ],

    additionalFiles: [
        ".tuist-supported-version",
        "Tuist/**"
    ],

    // ========== 禁用 Plist 资源合成器（验证通过）==========
    // 手动指定需要的合成器，不包含 .plist() 以避免生成 TuistPlists+RxStudy.swift
    // 这样我们就可以使用自己的 Pods-RxStudy-acknowledgements.plist + AcknowList
    resourceSynthesizers: [
        .assets(),   // ✅ 保留：Assets 合成器
        .strings(),  // ✅ 保留：Strings 合成器
    ]
)
```

### ⚠️ 重要：不要使用 `.default`

**错误示例**（会导致生成 Plist 文件）：
```swift
// ❌ 错误：.default 包含了 .plist()
resourceSynthesizers: .default + [
    .assets(),
    .strings(),
]
```

**正确示例**（验证通过）：
```swift
// ✅ 正确：只包含需要的合成器
resourceSynthesizers: [
    .assets(),
    .strings(),
]
```

### 效果

- ✅ **不再生成** `TuistPlists+RxStudy.swift` 文件
- ✅ **保留其他**资源合成器功能（Assets、Strings 等）
- ✅ 使用自己的 `Pods-RxStudy-acknowledgements.plist` + AcknowList
- ✅ **已在 RxStudy 项目中验证通过**

---

## 完整配置示例（验证通过）

```swift
import ProjectDescription

let teamId = "GZKK4Y45D3"

let project = Project(
    name: "RxStudy",
    organizationName: "com.lostsakura",
    options: .options(
        textSettings: .textSettings(
            indentWidth: 2,
            tabWidth: 2
        )
    ),
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "17.6",
            "ENABLE_BITCODE": "NO",
            "SWIFT_VERSION": "5.9",
            "DEVELOPMENT_TEAM": .string(teamId)
        ],
        configurations: [
            .debug(name: .debug),
            .release(name: .release)
        ],
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "RxStudy",
            destinations: .iOS,
            product: .app,
            bundleId: "com.lostsakura.RxStudy",
            deploymentTargets: .iOS("17.6"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "玩安卓",
                "CFBundleShortVersionString": "1.0.0",
                "CFBundleVersion": "1",
                // ... 其他 Info.plist 配置
            ]),
            sources: [
                "RxStudy/**",
                "RxStudy/Generated/**/*.swift",
            ],
            resources: [
                "RxStudy/Assets.xcassets/**",
                "RxStudy/Base.lproj/LaunchScreen.storyboard",
                "RxStudy/Base.lproj/Main.storyboard",
                // ========== 手动管理的许可证文件 ==========
                "RxStudy/Pods-RxStudy-acknowledgements.plist",
            ],
            dependencies: [
                // ========== 许可证列表 ==========
                TargetDependency.external(name: "AcknowList"),
                // ... 其他依赖
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "ENABLE_PREVIEWS": "YES",
                    // ... 其他设置
                ],
                configurations: [
                    .debug(name: .debug),
                    .release(name: .release)
                ],
                defaultSettings: .recommended
            )
        ),
    ],
    schemes: [
        .scheme(
            name: "RxStudy",
            shared: true,
            buildAction: .buildAction(targets: ["RxStudy"]),
            runAction: .runAction(executable: "RxStudy"),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        )
    ],
    additionalFiles: [
        ".tuist-supported-version",
        "Tuist/**"
    ],
    // ========== 禁用 Plist 资源合成器（验证通过）==========
    resourceSynthesizers: [
        .assets(),   // ✅ 保留：Assets 合成器
        .strings(),  // ✅ 保留：Strings 合成器
    ]
)
```

---

## 替代方案

### 方案 1：完全禁用资源合成器

```swift
resourceSynthesizers: []  // 完全禁用所有自动生成
```

### 方案 2：仅保留 Assets 和 Strings（推荐，已验证）

```swift
resourceSynthesizers: [
    .assets(),
    .strings(),
]
```

### 方案 3：尝试使用 .default（不推荐，会生成 Plist）

```swift
// ❌ 这会导致生成 TuistPlists+RxStudy.swift
resourceSynthesizers: .default + [
    .assets(),
    .strings(),
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

# ✅ 确认 TuistPlists+RxStudy.swift 不存在
ls -la Derived/Sources/TuistPlists+RxStudy.swift
# 应该显示：No such file or directory

# ✅ 确认其他合成器仍然正常工作
ls -la Derived/Sources/TuistAssets+RxStudy.swift   # 应该存在
ls -la Derived/Sources/TuistStrings+RxStudy.swift  # 应该存在
```

### 验证状态：✅ 通过

**RxStudy 项目验证结果**（2026-02-28）：
- ✅ `TuistPlists+RxStudy.swift` 不再生成
- ✅ `TuistAssets+RxStudy.swift` 正常生成
- ✅ `TuistStrings+RxStudy.swift` 正常生成
- ✅ AcknowList 正常读取 `Pods-RxStudy-acknowledgements.plist`
- ✅ 第三方库许可证页面正常显示

---

## 常见问题

### Q: 禁用后会影响其他功能吗？

**A**: 不会。只禁用了 Plist synthesizer，其他合成器（Assets、Strings 等）仍然正常工作。

### Q: 为什么不使用 `.default`？

**A**: `.default` 包含了 `.plist()` 合成器，即使你显式添加其他合成器，Plist 合成器仍然会生成文件。要完全禁用 Plist 生成，必须不使用 `.default`。

### Q: 配置后 tuist generate 报错怎么办？

**A**: 检查以下常见问题：

1. **参数顺序错误**：确保 `additionalFiles` 在 `resourceSynthesizers` 之前
2. **使用了 `.default`**：改用手动指定合成器的方式
3. **模板不可用**：某些合成器模板（如 `.coreData()`、`.files()`）可能不可用

### Q: 如何恢复自动生成？

**A**: 删除 `resourceSynthesizers` 配置即可恢复默认行为：

```swift
// 删除或注释掉 resourceSynthesizers 配置
// resourceSynthesizers: [
//     .assets(),
//     .strings(),
// ]
```

### Q: 如果项目中没有 Info.plist 会怎样？

**A**: Tuist 会自动生成一个基础的 Info.plist。`resourceSynthesizers` 配置不影响这个。

### Q: .coreData() 和 .files() 合成器报错怎么办？

**A**: 这些合成器可能需要额外的参数或模板。如果不需要 CoreData 和文件合成功能，可以不添加它们：

```swift
// ✅ 简化配置，只包含必需的合成器
resourceSynthesizers: [
    .assets(),
    .strings(),
]
```

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
   - 使用手动指定合成器的方式（不使用 `.default`）

3. **保留其他资源合成器**
   - Assets - 自动生成图片资源访问代码
   - Strings - 自动生成本地化字符串访问代码

4. **验证配置**
   - 运行 `tuist generate` 后检查 `Derived/Sources/` 目录
   - 确认 `TuistPlists+<项目名>.swift` 不存在
   - 确认其他合成器文件正常生成

### ❌ 不推荐

1. 同时使用自动生成和手动管理
2. 完全禁用所有 resourceSynthesizers（除非不需要）
3. 使用 `.default + [...]` 试图排除 Plist（不会生效）

---

**最后更新**: 2026-02-28

**验证状态**: ✅ RxStudy 项目中验证通过
