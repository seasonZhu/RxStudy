[根目录](../../CLAUDE.md) > [RxStudy](../) > **Home**

# Home 模块

## 模块职责

首页模块负责展示WanAndroid首页内容，包括顶部Banner轮播图和文章列表。支持 下拉刷新、上拉加载更多、文章点击跳转等功能。

## 入口与启动

- **入口控制器**: `HomeController` (继承自 `BaseTableViewController`)
- **入口ViewModel**: `HomeViewModel`
- **初始化**: 通过 `HomeController.viewDidLoad()` 中的 `binding()` 方法绑定ViewModel

## 对外接口

### 控制器方法
```swift
// 文章点击处理
tableView.rx.modelSelected(Info.self)

// Banner点击
pagerView.delegate -> didSelectItemAt
```

### ViewModel输入/输出
```swift
// Inputs
func loadData(actionType: ScrollViewActionType)

// Outputs
let dataSource: BehaviorRelay<[Info]>      // 文章列表
let banners: BehaviorRelay<[Banner]>        // Banner数据
let refreshSubject: BehaviorSubject<MJRefreshAction>  // 刷新状态
```

## 关键依赖与配置

| 依赖 | 用途 |
|------|------|
| FSPagerView | Banner轮播组件 |
| MJRefresh | 下拉刷新/上拉加载 |
| Kingfisher | 图片加载 |
| SnapKit | 布局 |
| RxSwift/RxCocoa | 响应式绑定 |

### API接口
- `Api.Home.banner` - 获取Banner数据
- `Api.Home.topArticle` - 获取置顶文章
- `Api.Home.normalArticle` - 获取文章列表

## 数据模型

| 模型 | 文件 | 说明 |
|------|------|------|
| `Banner` | `Packages/HttpRequest/Sources/Model/Banner.swift` | 轮播图数据 |
| `Info` | `Packages/HttpRequest/Sources/Model/Info.swift` | 文章信息 |

## 测试与质量

- **单元测试**: 无
- **UI测试**: 无
- **lint检查**: 通过 `.swiftlint.yml` 配置

## 常见问题 (FAQ)

**Q: 如何添加新的Banner点击事件?**
A: 在 `FSPagerViewDelegate` 的 `didSelectItemAt` 方法中处理。

**Q: 文章列表如何实现分页?**
A: `HomeViewModel` 中维护 `pageNum` 变量，通过 `ScrollViewActionType.refresh/loadMore` 区分刷新和加载更多。

## 相关文件清单

| 文件 | 路径 |
|------|------|
| HomeController | `Home/Controller/HomeController.swift` |
| HomeViewModel | `Home/ViewModel/HomeViewModel.swift` |
| HotKeyController | `Home/Controller/HotKeyController.swift` |
| HotKeyFlexBoxController | `Home/Controller/HotKeyFlexBoxController.swift` |
| SearchResultController | `Home/Controller/SearchResultController.swift` |
| TabType | `TabType.swift` (根目录) |

## 变更记录 (Changelog)

### 2026-03-24
- 创建模块文档
- 识别入口点和接口
