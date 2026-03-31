[根目录](../../CLAUDE.md) > [Packages](../) > **HttpRequest**

# HttpRequest 模块

## 模块职责

HttpRequest模块是项目的网络请求封装层，基于Moya和RxSwift实现统一的网络请求处理。提供API定义、服务层封装、请求插件、账户管理等功能。

## 入口与启动

- **包入口**: `Package.swift`
- **核心文件**: `Sources/Api/Api.swift`
- **账户管理**: `Sources/AccountManager/AccountManager.swift`
- **服务提供器**: `Sources/Service/Provider.swift`

## 对外接口

### API定义
```swift
public enum Api {
    public static let baseUrl = "https://www.wanandroid.com/"
    public static let newBaseUrl = "https://wanandroid.com/"

    enum Home { /* banner, article... */ }
    enum Project { /* tags, list... */ }
    enum PublicNumber { /* tags, list... */ }
    enum Account { /* login, register, logout */ }
    enum Tree { /* tags, list... */ }
    enum My { /* coinRank, collect... */ }
}
```

### 服务层
```swift
HomeService.shared.homeBanner() -> Single<[Banner]>
HomeService.shared.articleList(page: Int) -> Single<Page<[Info]>>
AccountService.shared.login(username: String, password: String) -> Single<AccountInfo>
```

### AccountManager
```swift
AccountManager.shared.isLoginRelay -> BehaviorRelay<Bool>
AccountManager.shared.accountInfo -> AccountInfo?
AccountManager.shared.cookieHeaderValue -> String
AccountManager.shared.autoLogin()
```

## 关键依赖与配置

| 依赖 | 用途 |
|------|------|
| Moya | 网络请求框架 |
| RxSwift/RxCocoa | 响应式编程 |
| KeychainAccess | 密钥链存储 |
| Alamofire | HTTP客户端 |

### 插件机制
- `NetworkDebuggingPlugin` - 调试日志
- `NetworkGZipPlugin` - GZip压缩
- `CustomNetworkActivityPlugin` - 网络状态监听
- `ResponseCachePlugin` - 响应缓存

## 数据模型

| 模型 | 文件 | 说明 |
|------|------|------|
| `AccountInfo` | `Sources/Model/AccountInfo.swift` | 用户账户信息 |
| `Banner` | `Sources/Model/Banner.swift` | 轮播图 |
| `Info` | `Sources/Model/Info.swift` | 文章/项目信息 |
| `CoinRank` | `Sources/Model/CoinRank.swift` | 积分排名 |
| `Page<T>` | `Sources/Model/Page.swift` | 分页数据 |
| `Tab` | `Sources/Model/Tab.swift` | Tab标签 |

## 测试与质量

- **单元测试**: 无
- **集成测试**: 无
- **建议**: 为各Service添加单元测试

## 常见问题 (FAQ)

**Q: 如何添加新的API接口?**
A: 在 `Api.swift` 中添加新的enum extension，然后在对应Service中添加方法。

**Q: 如何处理登录状态失效?**
A: 通过 `AccountManager.shared.isLoginRelay` 监听登录状态变化，在插件中自动跳转登录页。

**Q: 请求头如何自动添加登录Cookie?**
A: 通过 `CustomNetworkActivityPlugin` 插件，在 `prepare` 方法中检查 `AccountManager.shared.cookieHeaderValue`。

## 相关文件清单

| 文件 | 路径 |
|------|------|
| Api | `Sources/Api/Api.swift` |
| AccountManager | `Sources/AccountManager/AccountManager.swift` |
| Provider | `Sources/Service/Provider.swift` |
| HomeService | `Sources/Service/HomeService.swift` |
| AccountService | `Sources/Service/AccountService.swift` |
| ProjectService | `Sources/Service/ProjectService.swift` |
| PublicNumberService | `Sources/Service/PublicNumberService.swift` |
| TreeService | `Sources/Service/TreeService.swift` |

## 变更记录 (Changelog)

### 2026-03-24
- 创建模块文档
- 识别API结构和服务层
- 记录AccountManager单例模式
