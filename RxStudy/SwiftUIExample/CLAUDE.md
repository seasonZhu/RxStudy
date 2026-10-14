[根目录](../../CLAUDE.md) > [RxStudy](../) > **SwiftUIExample**

# SwiftUIExample 模块

## 模块职责

SwiftUI示例模块是项目进行SwiftUI迁移的试点模块，展示了如何在RxSwift项目中引入SwiftUI进行UI开发。该模块包含SwiftUI页面的完整实现，包括网络请求、状态管理、上下拉刷新等功能。

## 入口与启动

- **示例页面**: `CoinRankListPage` (积分排行榜)
- **对应ViewModel**: `CoinRankListPageViewModel`
- **状态管理**: `AppState`, `State.swift`

## 对外接口

### SwiftUI页面
```swift
// 入口页面
CoinRankListPage()

// 登录页面
LoginPage()
```

### ViewModel
```swift
// CoinRankListPageViewModel
@Published var coinRanks: [ClassCoinRank] = []
@Published var isLoading: Bool = false
@Published var error: Error?

func loadData()
func loadMore()
```

## 关键依赖与配置

| 依赖 | 用途 |
|------|------|
| SwiftUIX | SwiftUI扩展库 |
| swiftui-introspect | UIKit introspection for SwiftUI |
| Refresh | SwiftUI下拉刷新组件 |
| ACarousel | SwiftUI轮播组件 |
| Combine | 状态管理 |

### API接口
- `Api.My.coinRank` - 获取积分排行榜

## 数据模型

| 模型 | 文件 | 说明 |
|------|------|------|
| `ClassCoinRank` | `SwiftUIExample/Model/ClassCoinRank.swift` | 积分排名数据 |
| `ClassBanner` | `SwiftUIExample/Model/ClassBanner.swift` | Banner数据 |
| `AppState` | `SwiftUIExample/Model/AppState.swift` | 全局状态 |

## 测试与质量

- **单元测试**: 无
- **UI测试**: 无
- **SwiftUI预览**: 支持 (通过 `PreviewProvider`)

## 常见问题 (FAQ)

**Q: 如何在SwiftUI中使用RxSwift?**
A: 通过 `@Published` 属性包装RxSwift的 `BehaviorRelay`，或使用 `CurrentValueSubject`。

**Q: SwiftUI如何调用UIKit组件?**
A: 使用 `UIViewControllerRepresentable` 或 `UIViewRepresentable`。

**Q: 如何实现SwiftUI下拉刷新?**
A: 使用 `Refresh` 库提供的 `refreshable` modifier 或自定义 `PullToRefresh` 组件。

## 相关文件清单

| 文件 | 路径 |
|------|------|
| CoinRankListPage | `SwiftUIExample/Page/CoinRankListPage.swift` |
| LoginPage | `SwiftUIExample/Page/LoginPage.swift` |
| CoinRankListPageViewModel | `SwiftUIExample/ViewModel/CoinRankListPageViewModel.swift` |
| AppState | `SwiftUIExample/Model/AppState.swift` |
| Header/Header.swift | `SwiftUIExample/View/Refresh/Header.swift` |
| Footer/Footer.swift | `SwiftUIExample/View/Refresh/Footer.swift` |

## 变更记录 (Changelog)

### 2026-03-24
- 创建模块文档
- 识别SwiftUI迁移示例页面
- 记录Refresh下拉刷新实现方式
