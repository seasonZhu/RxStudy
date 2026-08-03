---
name: rxstudy-ios
description: RxStudy iOS 项目专属知识库，包含 Tuist 项目结构、Target 配置、MVVM 架构、共享代码、网络层设计。当需要理解项目结构、使用项目 API 或遵循项目编码规范时使用此 skill。
---

# RxStudy iOS 项目知识库

## 项目概览

- **开发周期**: 2019 年至今
- **最低 iOS 版本**: iOS 17.6
- **Swift 版本**: 5.9
- **包管理**: Tuist (SPM)
- **当前分支**: `refactor/swiftui-migration`

## 项目结构

```
RxStudy/
├── Project.swift              # Tuist 项目配置
├── Tuist.swift                # Tuist 版本配置
├── Tuist/                     # Tuist 依赖包
├── RxStudy/                   # 主 Target (UIKit + RxSwift)
├── SwiftUIApp/               # SwiftUI Target (SwiftUI)
├── Shared/                    # 共享代码 (两个 Target 共用)
├── Packages/                  # 本地 SPM 包
└── Template/                  # 项目模板
```

## Target 配置

### RxStudy (UIKit + RxSwift)

| 配置项 | 值 |
|--------|-----|
| Bundle ID | `com.lostsakura.RxStudy` |
| App Name | 玩安卓 |
| 部署目标 | iOS 17.6 |

**核心依赖:**
- **响应式**: RxSwift, RxCocoa, RxRelay, RxDataSources, RxGesture, RxTheme, RxSwiftExt, RxOptional, RxBlocking, NSObject-Rx
- **网络**: Moya + RxMoya, Alamofire
- **布局**: SnapKit
- **图片**: Kingfisher
- **工具**: KeychainAccess, CocoaLumberjack, MarqueeLabel, SFSafeSymbols, ZipArchive
- **UI**: MBProgressHUD, SVProgressHUD, MJRefresh, JXSegmentedView, DZNEmptyDataSet, FSPagerView

### SwiftUIApp (SwiftUI)

| 配置项 | 值 |
|--------|-----|
| Bundle ID | `com.lostsakura.RxStudy.SwiftUIStudy` |
| App Name | 玩安卓(SwiftUI) |
| 部署目标 | iOS 17.6 |

**核心依赖:**
- **网络**: Moya, Alamofire
- **图片**: Kingfisher
- **WebView**: WebUI
- **UI**: ProgressHUD, SwiftUIIntrospect, SwiftUIX

## 共享代码 (Shared/)

```
Shared/
├── ACarousel/     # 轮播图组件
├── Models/        # 共享数据模型
│   ├── Banner.swift
│   ├── BaseModel.swift
│   ├── HotKey.swift
│   ├── Page.swift
│   └── WebLoadInfo.swift
└── Extensions/    # 共享扩展
```

**两个 Target 的 sources 配置:**
```swift
sources: [
    "Shared/ACarousel/**",
    "Shared/Models/**",
    "Shared/Extensions/**",
]
```

## 架构模式: MVVM

### RxStudy (UIKit)

```
View (UIViewController/UIView)
    ↓ 绑定
ViewModel (RxSwift Observable)
    ↓
Service (TargetType + Moya)
    ↓
Network (MoyaProvider)
```

**特点:**
- View 与 ViewModel 通过 RxSwift 绑定
- Service 实现 `TargetType` 协议定义 API
- 使用 `Observable<T>` 返回数据流

### SwiftUIApp (SwiftUI)

```
View (SwiftUI View)
    ↓ 绑定
ViewModel (@Observable/@State)
    ↓
APIService (async/await)
    ↓
Network (MoyaProvider)
```

**特点:**
- View 与 ViewModel 通过 `@State`/`@Published` 绑定
- Service 继承 `APIService` 协议
- 使用 `async/await` 处理异步

## 网络层对比

### RxStudy (响应式)

```swift
// Service 定义
enum HomeService {
    case banner
    case normalArticle(_ page: Int)
}

extension HomeService: TargetType {
    var baseURL: URL { URL(string: Api.baseUrl)! }
    var path: String { ... }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
}

// ViewModel 使用
func fetchBanner() -> Observable<[Banner]> {
    provider.rx.request(.banner)
        .map(BaseModel<[Banner]>.self)
        .map { try $0.getData() }
        .asObservable()
}
```

### SwiftUIApp (async/await)

```swift
// Service 定义
enum HomeAPI {
    case banner
    case normalArticle(page: Int)
}

extension HomeAPI: TargetType {
    var baseURL: URL { URL(string: Api.baseUrl)! }
    var path: String { ... }
    var method: Moya.Method { .get }
    var task: Task { .requestPlain }
}

// APIService 协议
protocol APIService {
    associatedtype Target: TargetType
    var provider: MoyaProvider<Target> { get }
}

// ViewModel 使用
func fetchBanner() async throws -> [Banner] {
    try await provider.requestDecoded(.banner, responseType: BaseModel<[Banner]>.self)
}
```

## API 错误处理

### SwiftUIApp 的 APIError

```swift
enum APIError: LocalizedError {
    case networkError(MoyaError)
    case parsingError(Error)
    case businessError(code: Int?, message: String?)
    case unknown
}
```

### BaseModel 的数据获取

```swift
extension BaseModel {
    func getData() throws -> T {
        guard isSuccess, let data = data else {
            throw APIError.businessError(code: errorCode, message: errorMsg)
        }
        return data
    }
}
```

## 代码规范

### 日志输出

使用 `logPrintDebug()` 代替 `print()` 进行调试日志输出。

### API 路由

通过 `Api` 枚举管理所有 API 路由：

```swift
enum Api {
    static let baseUrl = "https://www.wanandroid.com"
    enum Home {
        static let banner = "/banner/json"
        static let normalArticle = "/article/list"
    }
}
```

### SwiftUI 与 UIKit 差异

| 场景 | UIKit (RxStudy) | SwiftUI (SwiftUIApp) |
|------|-----------------|---------------------|
| 状态管理 | RxSwift (BehaviorRelay) | @State/@Published/@Observable |
| 导航 | UINavigationController | NavigationView |
| 列表 | UITableView/UICollectionView | List/ForEach |
| 网络回调 | Observable | async/await |
| 生命周期 | viewDidLoad 等 | onAppear |

### 第三方库选择

- **仅 RxStudy**: RxSwift 生态、MJRefresh、JXSegmentedView、SnapKit
- **仅 SwiftUIApp**: SwiftUIIntrospect、SwiftUIX、WebUI、ProgressHUD
- **共用**: Kingfisher、Moya、Alamofire、ACarousel (Shared)

## 开发注意事项

1. **Tuist 生成**: 修改 `Project.swift` 后需运行 `tuist generate`
2. **共享代码**: 放在 `Shared/` 目录，两个 Target 都会编译
3. **SwiftUI 迁移**: 当前分支 `refactor/swiftui-migration` 进行 UIKit → SwiftUI 迁移
4. **Bundle ID**: RxStudy 用 `com.lostsakura.RxStudy`，SwiftUIStudy 用 `com.lostsakura.RxStudy.SwiftUIStudy`
5. **网络层差异**: RxStudy 用 RxSwift 响应式，SwiftUIApp 用 async/await

## 相关文件路径

- 项目配置: `Project.swift`
- SwiftUI 入口: `SwiftUIApp/SwiftUIApp.swift`
- 网络服务基类: `SwiftUIApp/Network/APIService.swift`
- 共享模型: `Shared/Models/BaseModel.swift`
- UIKit Service 示例: `RxStudy/HttpRequest/Service/HomeService.swift`
- SwiftUI Service 示例: `SwiftUIApp/Network/HomeAPIService.swift`
