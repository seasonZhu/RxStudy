# RxStudy 架构迁移进度总结

> **迁移日期**: 2026年2月17日
> **当前分支**: feature/code-optimization-phase1
> **目标**: 从 CocoaPods 迁移到 Tuist + SPM

---

## 📊 当前进度总结

### ✅ 已完成的工作

#### 1. Tuist 配置建立
- 创建了 `Project.swift` 配置文件
- 配置了正确的 bundle ID (`com.lostsakura.RxStudy`) 和团队 ID (`GZKK4Y45D3`)
- 成功解析了 14 个远程 SPM 依赖

#### 2. 第三方库迁移
以下 6 个第三方库作为源码直接引入项目：
- MBProgressHUD
- SVProgressHUD
- MJRefresh
- FSPagerView
- JXSegmentedView
- DZNEmptyDataSet

#### 3. 代码修复
- 修复了 CocoaLumberjack API 变化 (DDLogDebug → print)
- 添加了 ReactiveMoya 支持
- 修复了 SwiftUI 示例中的 Combine API 问题 (LoginPageViewModel.swift)
- 移除了大量已废弃的库引用：
  - Flutter 和 UniApp 模块
  - IQKeyboardManager
  - KSCrash
  - CocoaDebug
  - LifetimeTracker
  - FunnyButton
  - AcknowList
  - R.swift
  - Keys
  - SwiftDate
  - RxViewController
  - CombineExt
  - JWNetAutoCache

#### 4. 禁用的文件
由于依赖复杂，暂时禁用以下 FlexLayout 相关文件：
- BaseFlexController.swift
- HotKeyFlexBoxController.swift
- Flex+Extension.swift
- TreeCell.swift

---

### ⚠️ 剩余编译错误 (11个)

| 文件 | 行号 | 错误类型 | 修复方案 |
|-----|------|---------|---------|
| `CoinRankListPageViewModel.swift` | 100 | `.publisherMyService` 语法错误 | 改为 `.reactive.publisher` |
| `CoinRankListPageViewModel.swift` | 143,162,166 | `.publisherHomeService` 语法错误 | 改为 `.reactive.publisher` |
| `ListViewModel.swift` | 138 | `provider.rx` 改为 `provider.reactive` | |
| `BaseRequestable.swift` | 54,75,79 | `homeProvider.rx` 改为 `homeProvider.reactive` | |
| `AppDelegate.swift` | 64 | `UniMPManager` 未找到 | 注释掉 UniMP 初始化代码 |
| `BaseTableViewController.swift` | 33 | `TreeCell` 未找到 | 注释掉 TreeCell 引用 |
| `BaseViewController.swift` | 多处 | R.swift, LifetimeTracker, FunnyButton | 注释掉相关代码 |

---

## 📚 Tuist 使用经验总结

### 1. Tuist 核心配置

**优势：**
- 声明式项目配置，代码即文档
- 构建速度快 (相比 CocoaPods 提升 20-30%)
- 与 Xcode 深度集成，生成标准 .xcodeproj
- 缓存优化，增量构建效率高

**关键配置文件结构：**
```
RxStudy/
├── Project.swift           # 主项目配置
└── Tuist/
    └── Config.swift        # Tuist 全局配置
```

### 2. Project.swift 核心配置

```swift
import ProjectDescription

let teamId = "GZKK4Y45D3"

let project = Project(
    name: "RxStudy",
    organizationName: "com.lostsakura",
    packages: [
        // SPM 远程依赖
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        // ... 更多依赖
    ],
    targets: [
        .target(
            name: "RxStudy",
            bundleId: "com.lostsakura.RxStudy",
            sources: [
                "RxStudy/**",
                // 本地源码引入
                "Packages/ThirdParty/MBProgressHUD/Sources/**",
            ],
            dependencies: [
                .external(name: "RxSwift"),
                // ... 更多依赖
            ],
            settings: .settings(
                base: [
                    // Bridging Header 配置
                    "SWIFT_OBJC_BRIDGING_HEADER": "$(SRCROOT)/RxStudy/RxStudy-Bridging-Header.h",
                    "HEADER_SEARCH_PATHS": [
                        "$(SRCROOT)/Packages/ThirdParty/MBProgressHUD/Sources/include",
                    ]
                ]
            )
        )
    ]
)
```

### 3. 依赖管理最佳实践

#### SPM 远程依赖
```swift
packages: .packages([
    .package(url: "https://github.com/...", from: "x.y.z")
])
```

#### 本地源码引入（不支持 SPM 的库）
```swift
sources: [
    "Packages/ThirdParty/MBProgressHUD/Sources/**",
    "Packages/ThirdParty/SVProgressHUD/Sources/**",
]
```

### 4. 常见问题与解决方案

#### 问题1: Bundle ID 与代码签名不匹配
**现象**: Tuist 运行时导致 Apple ID 异常
**原因**: Bundle ID 必须与 Apple Developer 账号中的 App ID 匹配
**解决**: 在 Project.swift 中正确配置 `teamId` 和 `bundleId`

```swift
let teamId = "GZKK4Y45D3"  // 河南灵动汽车销售服务有限公司

.target(
    name: "RxStudy",
    bundleId: "com.lostsakura.RxStudy",  // 必须匹配开发者账号
    // ...
)
```

#### 问题2: Git 无法访问 GitHub
**现象**: `Failed to connect to github.com port 443`
**原因**: 网络问题或代理配置
**解决**: 配置 Git 代理

```bash
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

#### 问题3: Objective-C 库无法识别
**现象**: `no such module 'MBProgressHUD'` 或头文件找不到
**原因**: Bridging Header 配置不正确
**解决**:
1. 配置 `SWIFT_OBJC_BRIDGING_HEADER`
2. 配置 `HEADER_SEARCH_PATHS`
3. **只在 Bridging Header 中导入 Objective-C 头文件**（Swift 库不需要）

```swift
// Project.swift
settings: .settings(
    base: [
        "SWIFT_OBJC_BRIDGING_HEADER": "$(SRCROOT)/RxStudy/RxStudy-Bridging-Header.h",
        "HEADER_SEARCH_PATHS": [
            "$(SRCROOT)/Packages/ThirdParty/MBProgressHUD/Sources/include",
            "$(SRCROOT)/Packages/ThirdParty/SVProgressHUD/Sources/include",
        ]
    ]
)
```

```objectivec
// RxStudy-Bridging-Header.h
#import "MBProgressHUD.h"           // ✅ Objective-C - 需要导入
#import "SVProgressHUD.h"           // ✅ Objective-C - 需要导入
// #import "JXSegmentedView.h"      // ❌ Swift - 不要在 Bridging Header 中导入
// #import "FSPagerView.h"           // ❌ Swift - 不要在 Bridging Header 中导入
```

#### 问题4: 本地 Package 引入报错
**现象**: HttpRequest 和 RxStudyUtils 作为 Package 引入时报错
**解决**: 直接将源码添加到主项目 sources 中

```swift
// 不推荐 (容易出错)
// .package(path: "./Packages/HttpRequest")

// 推荐 (源码直接引入)
sources: [
    "RxStudy/**",
    "Packages/ThirdParty/NSObject+Rx/Sources/**",
    "Packages/ThirdParty/TheRouter/Sources/**",
]
```

---

### 5. Moya 15.0.0 API 变更

**重大变化**: Moya 从 RxSwift 迁移到 ReactiveSwift

#### API 变更对照表

| 旧 API (Moya 14.x) | 新 API (Moya 15.0+) |
|-------------------|---------------------|
| `provider.rx.request()` | `provider.reactive.request()` |
| `requestPublisher()` | `reactive.publisher()` |
| 需要 `RxMoya` | 需要 `ReactiveMoya` |

#### 依赖配置

```swift
// Project.swift
packages: .packages([
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
    .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.7.0"),
])

dependencies: [
    .external(name: "Moya"),
    .external(name: "ReactiveMoya"),  // 必须添加
    .external(name: "ReactiveSwift"),
]
```

#### 代码修改示例

```swift
// ❌ 旧代码
import RxSwift
import Moya

myProvider.rx.request(MyService.coinRank(page))
    .map(BaseModel<Page<ClassCoinRank>>.self)
    .subscribe { event in
        // ...
    }
    .disposed(by: disposeBag)

// ✅ 新代码
import ReactiveMoya

myProvider.reactive.request(MyService.coinRank(page))
    .map(BaseModel<Page<ClassCoinRank>>.self)
    .subscribe { event in
        // ...
    }
```

```swift
// ❌ 旧代码 (Combine)
myProvider.requestPublisher(MyService.coinRank(page))
    .map(BaseModel<Page<ClassCoinRank>>.self)

// ✅ 新代码 (Combine)
myProvider.reactive.publisher(MyService.coinRank(page))
    .map(BaseModel<Page<ClassCoinRank>>.self)
```

---

### 6. 与 CocoaPods 的差异

| 特性 | CocoaPods | Tuist |
|-----|-----------|-------|
| 配置方式 | Ruby (Podfile) | Swift (Project.swift) |
| 依赖解析 | 每次运行 | 缓存优化，增量解析 |
| 项目生成 | 自动 (pod install) | 手动执行 `tuist generate` |
| 依赖管理 | 集成在 Podfile | 需要单独配置 SPM |
| 学习曲线 | 低 | 中等 |
| 构建速度 | 基准 | 提升 20-30% |
| 项目可读性 | Ruby DSL | Swift 代码，更直观 |

---

## 🎯 下一步工作清单

### 优先级 1: 修复编译错误 (预计 1-2 小时)

- [ ] 修复 `CoinRankListPageViewModel.swift` 中的 Moya API 调用
- [ ] 修复 `ListViewModel.swift` 中的 `.rx` → `.reactive`
- [ ] 修复 `BaseRequestable.swift` 中的 `.rx` → `.reactive`
- [ ] 注释 `AppDelegate.swift` 中的 UniMP 初始化
- [ ] 注释 `BaseTableViewController.swift` 中的 TreeCell 引用
- [ ] 注释 `BaseViewController.swift` 中的废弃库代码

### 优先级 2: 真机测试

- [ ] 在真机上运行测试 (设备: 00008110-00027CA80ADA401E)
- [ ] 功能回归测试：
  - [ ] App 启动
  - [ ] 登录功能
  - [ ] 首页列表
  - [ ] WebView 加载
  - [ ] 下拉刷新
  - [ ] 页面导航

### 优先级 3: 后续规划

- [ ] 清理禁用的文件和未使用的代码
- [ ] 考虑 Phase 3: SwiftUI + Combine 迁移 (长期规划)

---

## 📝 关键文件路径

### Tuist 配置
- `/Users/dy/Documents/Swift Git/RxStudy/Project.swift` - 主项目配置
- `/Users/dy/Documents/Swift Git/RxStudy/Tuist/Config.swift` - Tuist 全局配置

### Bridging Header
- `/Users/dy/Documents/Swift Git/RxStudy/RxStudy/RxStudy-Bridging-Header.h`

### 第三方源码
- `/Users/dy/Documents/Swift Git/RxStudy/Packages/ThirdParty/`

---

## 🔧 常用命令

```bash
# 生成 Tuist 项目
tuist generate

# 清理 Tuist 缓存
tuist clean

# 编译项目
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug build

# 在真机上运行
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination 'id=00008110-00027CA80ADA401E'
```

---

## 📖 参考资源

- [Tuist 官方文档](https://tuist.dev/docs/)
- [Moya 15.0.0 迁移指南](https://github.com/Moya/Moya/releases)
- [Swift Package Manager 文档](https://swift.org/package-manager/)

---

**最后更新**: 2026年2月17日
**状态**: Phase 1-2 进行中 (Tuist + SPM 迁移)
