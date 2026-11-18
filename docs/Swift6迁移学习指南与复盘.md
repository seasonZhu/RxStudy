# RxStudy 双 Target Swift 6 迁移学习指南与复盘

这份指南回答三个问题：编译器发现了什么，项目怎样解决，以及同样的错误下次该怎样判断。范围是从分叉点 `648f01214` 到收尾提交 `635d6cad8` 的已提交差异，覆盖 RxStudy、SwiftUIStudy、共享源码、本地维护库、脚本测试和工程配置。文末可按工单和文件回查实际 diff。

## 第一步：读懂编译器在保护什么

**数据竞争**发生在多个执行上下文同时访问同一份数据，且至少一方在写。两个请求的完成顺序颠倒则是另一类问题，即使同一 Actor 串行执行每次写入，旧请求也可能晚于新请求完成。账号的 revision 和 UniMP 的打开代次处理的是后者。

| 概念 | 在本仓库里怎么理解 |
| --- | --- |
| Swift 工具链与语言模式 | Xcode 26.3 是本轮使用的工具链。#11 用 Swift 5 加 `SWIFT_STRICT_CONCURRENCY=complete` 探测问题，#22/#23 才持久化两个 App Target 的 `SWIFT_VERSION=6`。最终看前端调用的 `-swift-version 6` |
| Actor 和 `@MainActor` | 给可变状态指定所有者。UIKit、SwiftUI 状态和路由导航适合主 Actor；Actor 方法跨 `await` 可交错，提交异步结果前仍可能需要检查请求代次 |
| `Sendable` | 类型承诺其值可安全跨隔离边界。由可发送成员组成的值模型容易获得编译器检查。`let shared = SomeClass()` 只固定引用，类内部仍可能可变 |
| `@Sendable` | 闭包的并发契约，编译器会检查捕获。`@MainActor @Sendable` 同时表达调用所在的隔离域与闭包的传递约束 |
| `sending` | 表达一次隔离区域的转移。编译器会检查转移之后原上下文是否还可能通过别名访问；缓存后端就是仓库里的实例 |
| `nonisolated` | 成员可从隔离域外调用，适用于只处理输入的路由 URL 拼装。函数体不能直接读取主 Actor 的可变状态 |
| `MainActor.assumeIsolated` | 在已有主执行器保证的同步回调中检查前提，再访问主 Actor。它不安排队列，前提错误会触发运行时失败 |
| 隔离遵循与隔离析构 | Swift 6.2 的 `Type: @MainActor Protocol` 限制该协议遵循的使用域；`isolated deinit` 允许在所属隔离域清理资源。本轮分别用于预览/代理与 WebView/Combine 清理 |

Actor、async/await 和 Sendable 早于 Swift 6。这里最直接的升级变化是严格检查成为语言模式的一部分，先前的许多告警会成为错误。Swift 6.2 的新能力还取决于编译器版本。本轮 App 构建没有显式启用模块默认主 Actor。阅读官方说明：[Swift 6 检查配置](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/enabledataracesafety/)、[数据竞争安全](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/dataracesafety/)、[Swift 6.2 隔离遵循](https://developer.apple.com/videos/play/wwdc2025/245/)。

### 用三步读一条报错

1. 找**状态**。报错中的 `self` 是页面、网络响应还是全局注册表？列出哪里读、哪里写。
2. 找**边界**。标出 `Task`、回调、`await`、同步协议要求和 GCD 队列。Rx 的 `observe(on:)` 可以给出运行时调度约定，闭包类型仍须单独检查。
3. 选**所有权**。UI 状态归主 Actor，跨域数据优先提取值，同步第三方协议无法等待 Actor 时可考虑受锁快照。先明确锁保护哪一份状态、何时释放及回调是否会重入，再考虑兼容标记。

## 第二步：按项目里的实际改动学习

下表的「编译约束」指在现有语言模式及调用边界下需要解决的问题。「项目选择」是满足约束并保留行为的具体实现，可以用其他同样安全的设计替代。测试和行为补强按其实际作用说明。

| 工单与代码位置 | 观察到的问题与前后变化 | 哪部分是 Swift 6 要求 |
| --- | --- | --- |
| #12 `Assets.stencil`、`swiftgen.yml` | 静态资源持有带可变名称和惰性缓存的类。改为只保存 `let name` 的 `Sendable` 值类型，使用时解析颜色、图片。调整模板，构建重新生成 | 静态共享资源须有可检查的并发安全。值描述符与计算属性是项目选择。生成物由模板产生 |
| #13 `ACarousel`、`ACarouselViewModel` | 延迟和手势捕获未隔离的轮播状态，预览入口调用 UI 初始化。ViewModel 归主 Actor，LibraryContentProvider 预览遵循隔离到主 Actor | 共享可变状态和协议见证必须满足隔离检查。既有 Binding、KeyPath、手势留在一个域内即可 |
| #14 Rx 账号、网络监控与资源加载 | 账号单例、Relay 和服务容器原来可由多处取用。会话状态集中到主 Actor，Moya 同步请求头只读锁内字符串快照。NWPath 回调先取状态值，主队列再发布。资源回调传 Error 和完成函数，资源请求对象留在 UI 域 | 全局可变状态须安全隔离。使用锁兼容同步请求头是设计选择。具体 ViewModel 的隔离遵循与调用方调整由状态所有权变化引出 |
| #15 SwiftUI 服务、共享模型与请求桥接 | 非 Sendable 服务单例改主 Actor；跨域 `Banner`、`HotKey`、`Page<Content>` 等采用值模型，`Page` 按泛型参数条件遵循。Moya 回调域内解码，用 `AsyncRequestState<Value: Sendable>` 交付结果 | 服务与 continuation 传值要通过隔离和可发送性检查。解码位置、终结状态锁和取消句柄都由项目选择；集成测试保护完成/取消的语义 |
| #16 SwiftUI 页面、账号服务、本地 ProgressHUD 与分享 | 页面任务以前捕获非隔离 ViewModel，现在状态和初始化统一在主 Actor。账号同步头使用 Cookie 快照，认证 revision 拦截旧结果。ShareSheet 先提取 URL，再让主 Actor 打开。HUD 的共享 UI 状态归主 Actor | UI 访问和任务捕获须满足隔离。Cookie 快照和 revision 分别解决同步调用与异步结果顺序；revision 本身不是语言要求 |
| #17 Rx Provider、HUD 与调用者 | 全局 Moya Provider 和可变活动计数原来没有清晰所有权。Provider 入口、HUD UI 调用归主 Actor。每个加载请求使用独立 UUID，锁内移除令牌，取消和完成共用收尾 | 全局状态和 HUD 闭包须满足检查。UUID 处理并发请求、取消早于 willSend、重复完成，是行为修复。插桩测试验证收尾 |
| #18 UIKit、Rx/Combine 与示例 | Binder、MJRefresh、Timer、录屏用已存在的主调度保证做同步隔离检查；可达性及轮询 HUD 明确调度到主队列。主题、布局、Tab、手势及导航协议按 UI 所有权标注。偏好默认值不可变。JavaScript Error 将任意值转成描述文本。Future 在原回调消费模型，只用 Void continuation 等待，分别持有上下游订阅，隔离析构负责清理 | 协议见证、调用域及跨域捕获须成立。保留既有同步语义、错误描述与订阅寿命是项目选择。Future 示例仍沿用原有取消语义 |
| #19 日志与导出 | 回调配置用锁保护，外部回调在锁外调用。Moya 请求和响应先提取 DataRequest 或请求、数据、头、状态码等值。导出 completion 明确在主 Actor；写日志和计时仍由原队列负责 | 共享配置与后台捕获须有安全边界。保留原队列与同步调用时序是项目选择；日志测试覆盖输出及回调 |
| #20 本地 TheRouter | 注册、拦截、服务实例和 UIKit 导航集中在主 Actor，纯 URL 拼装标记 `nonisolated`。服务注册由异步写表改为主 Actor 同步写入 | 注册表和 UI 访问须隔离。统一到主 Actor 使同步构造器和 `[String: Any]` 留在原调用链 |
| #21 UniMP | SDK 实例和 UIKit 入口归主 Actor。ObjC delegate 先按回调要求处理：事件在原线程同步应答，观察者快照在锁外调用；打开成功和同步闪屏依赖运行时主 Actor 检查，SDK 的全路径调度契约仍待确认；关闭比较打开代次，迟到的旧关闭不清空新实例 | SDK 对象与 `Any` 的使用要符合隔离。原事件应答顺序、关闭代次及分支调度是项目选择。SDK 契约是兼容措施的必要前提 |
| #22 SwiftUIStudy 工程配置 | Debug、Release 的 App 设置持久化为 Swift 6，构建实参逐配置核实 | 两配置使用 Swift 6 是迁移目标。依赖模块遵循各自设置 |
| #23 RxStudy 工程与阻塞修复 | 两配置切 Swift 6。UIKit 入口 `@UIApplicationMain` 换 `@main`，只读路由 `static var` 改 `static let`。缓存后端转移进独有锁，Moya 回调提取缓存值后再交给原写入队列。HUD 用 `[progress]` 捕获本次 Float；MJRefresh 的隔离块仅取枚举，原回调投递给观察者 | 入口迁移来自实际弃用错误。全局可变状态与进度、观察者的跨域使用来自实际严格并发错误。缓存后端的锁与队列保留是具体实现 |
| #9 收尾工程文件 | App 与 Pods 工程文件均在 `635d6cad8` 有大块序列化差异，另有文档归档。检查提交与语言模式说明时，将此批与 #22/#23 的版本设置分开读 | 工程文件序列化差异本身不是 Swift 6 语义要求。迁移证据是实际 App 设置、前端参数和构建结果 |

#10 提供原始构建基线，#11 记录严格检查诊断，#24 汇总四项最终构建、逐脚本验证与兼容台账。这几批在本分支只新增文档。原始诊断和最终验证见 [#11 严格并发诊断](Swift6严格并发诊断.md)、[#24 最终验收](Swift6最终验收与真机交接.md)。

### 四个可以自己讲出来的例子

**共享值。** `static let asset = ColorAsset(...)` 曾引用一个带 `lazy` 写入的对象。只把外部属性声明成 `let` 无法保护对象内部。把描述符保留为可发送的字符串值，资源对象在使用处获取，编译器可以检查描述符的存储成员。打开 [共享资源修复](Swift6共享资源修复.md)。

**同步协议。** Moya 的 `headers` 是同步属性，不能在里面等待主 Actor。账号先在主 Actor 生成 Cookie 字符串，然后同步读取锁内快照。画出「会话 → 值快照 → 请求头」三段，就能看出 Relay 和会话对象始终由 UI 域持有。打开 [Rx 账号状态](Swift6账号与全局状态修复.md) 和 [SwiftUI 页面及 HUD](Swift6页面状态与本地HUD隔离.md)。

**异步桥接。** Moya 回调拿到 Response 后在本域解码，再恢复 continuation。取消和响应竞争时，在锁内决定唯一终结者，解锁后才取消底层请求或恢复 continuation。这样同步回调重入时不会撞到仍持有的锁。打开 [SwiftUI 网络服务](Swift6网络服务可发送性修复.md)。

**同一请求结束两次。** 以全局计数对每次结束都减一，重复结束会提前隐藏其他请求的 HUD。UUID 令牌在集合里只能成功移除一次，最后一个请求结束才收敛。Swift 6 提醒我们明确状态所有权；令牌解决具体业务竞态。打开 [Rx 网络和 HUD](Swift6Rx网络与HUD隔离.md)。

### 兼容标记的审查方式

`@unchecked Sendable` 由开发者证明安全。仓库里的请求桥接、日志单例和包装器用它表达编译器目前无法验证的锁或队列约定。审查时检查所有读写是否通过同一约定，以及锁外调用是否有独立值。UniMP 的局部 `nonisolated(unsafe)` 只桥接本次同步回调，仍要通过 `assumeIsolated` 检查。缓存 `uncheckedState:` 的前提是独有后端转移后仅由锁访问。每项的安全依据和移除条件见 [兼容标记台账](Swift6最终验收与真机交接.md#兼容标记台账)。

建议按「共享资源 → 轮播 → 账号快照 → async 请求桥接 → Rx HUD → UniMP」顺序读。每看一段，试着标出状态所有者、每条跨域边界、传递的值，以及完成/取消/关闭能出现的顺序。用 `git show <提交> -- <文件>` 对照修改前后，再看分批日志确认是哪一条诊断推动了修改。

## 复盘

1. **优先提高真机结果的可追溯性。** 本次物理设备的选择器曾将 UniMP 点击落到其他页面，截图通道也报错。SwiftUIStudy Release 自动化里见过首页空态，开发者手测总体未发现问题。后续可在设备用例开始前记录支持的输入方式与证据来源，给每个配置保留步骤、实际结果和日志时间。对离页取消、HUD、UniMP，先确认有请求或回调级证据，再记录已验证的行为。已有启动冒烟与人工回归可继续分别记录。
2. **让确定性检查成为一个复用入口。** 本轮要分别执行四项 workspace 构建和九个 Python 脚本，还要提取 App 的 Swift 前端参数。仓库已有 `scripts/tests/` 入口，未发现当前树内的 `.github/workflows/`。下一次可将既有命令封装为一个可本机复用的验收入口，检查退出码、成功标记、前端模块名和 Swift 版本，并保留失败时的原日志。在有可用 macOS runner 时复用同一入口。
3. **让分批修复和工单同步好找。** 本次 #22/#23 的提交已经落地时 GitHub 仍开放，#24 需按实际交付继续。以后每批结束时用工单链接记录提交、验证层级和仍需真机确认的项。对于第三方调度假设，在对应模块文档保留依据与移除条件，审查时按需读取，避免重复写进全局代理指令。

## 逐提交文件索引

以下由 Git 历史生成，包含代码、测试和构建配置。重复出现的路径代表经过不同修复批次。文件链接指向当前树，历史差异以各小节提交为准。

### `cf85a1ac2` 修复共享资源生成类型的可发送性 #12

- [Template/SwiftGen/Assets.stencil](../Template/SwiftGen/Assets.stencil)
- [swiftgen.yml](../swiftgen.yml)

### `ec31ac28f` fix: 明确共享轮播的主 Actor 边界 (#13)

[#13 分批诊断、修改示例与验证](Swift6共享模型与轮播修复.md)

- [Shared/ACarousel/ACarousel.swift](../Shared/ACarousel/ACarousel.swift)
- [Shared/ACarousel/ACarouselViewModel.swift](../Shared/ACarousel/ACarouselViewModel.swift)

### `b57ff6d78` 修复账号与全局状态的并发所有权 #14

- [RxStudy/Account/Manager/AccountManageable.swift](../RxStudy/Account/Manager/AccountManageable.swift)
- [RxStudy/Account/Manager/AccountManager.swift](../RxStudy/Account/Manager/AccountManager.swift)
- [RxStudy/Account/Manager/AccountServiceContainer.swift](../RxStudy/Account/Manager/AccountServiceContainer.swift)
- [RxStudy/Extension/AppDelegate+Extension/AppDelegate+NetworkConfig.swift](../RxStudy/Extension/AppDelegate%2BExtension/AppDelegate%2BNetworkConfig.swift)
- [RxStudy/Extension/Moya+Extension.swift](../RxStudy/Extension/Moya%2BExtension.swift)
- [RxStudy/Extension/Utils/KeyConstants.swift](../RxStudy/Extension/Utils/KeyConstants.swift)
- [RxStudy/Extension/Utils/NetworkMonitor.swift](../RxStudy/Extension/Utils/NetworkMonitor.swift)
- [RxStudy/Home/ViewModel/HomeViewModel.swift](../RxStudy/Home/ViewModel/HomeViewModel.swift)
- [RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift](../RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift)
- [RxStudy/HttpRequest/Service/Provider.swift](../RxStudy/HttpRequest/Service/Provider.swift)
- [RxStudy/My/ViewModel/MessageViewModel.swift](../RxStudy/My/ViewModel/MessageViewModel.swift)
- [RxStudy/My/ViewModel/MyCollectionViewModel.swift](../RxStudy/My/ViewModel/MyCollectionViewModel.swift)
- [RxStudy/My/ViewModel/MyViewModel.swift](../RxStudy/My/ViewModel/MyViewModel.swift)
- [RxStudy/WebView/ViewModel/WebViewModel.swift](../RxStudy/WebView/ViewModel/WebViewModel.swift)

### `b5f73640d` 修复 SwiftUI 网络服务隔离与可发送性边界 (#15)

[#15 分批诊断、修改示例与验证](Swift6网络服务可发送性修复.md)

- [Shared/Models/Banner.swift](../Shared/Models/Banner.swift)
- [Shared/Models/HotKey.swift](../Shared/Models/HotKey.swift)
- [Shared/Models/Page.swift](../Shared/Models/Page.swift)
- [SwiftUIStudy/Features/Search/HotKeyViewModel.swift](../SwiftUIStudy/Features/Search/HotKeyViewModel.swift)
- [SwiftUIStudy/Models/CoinCollectModels.swift](../SwiftUIStudy/Models/CoinCollectModels.swift)
- [SwiftUIStudy/Models/CommonModels.swift](../SwiftUIStudy/Models/CommonModels.swift)
- [SwiftUIStudy/Models/EmptyModel.swift](../SwiftUIStudy/Models/EmptyModel.swift)
- [SwiftUIStudy/Network/APIService.swift](../SwiftUIStudy/Network/APIService.swift)
- [SwiftUIStudy/Network/CategoryAPIProtocol.swift](../SwiftUIStudy/Network/CategoryAPIProtocol.swift)
- [SwiftUIStudy/Network/CoinAPIService.swift](../SwiftUIStudy/Network/CoinAPIService.swift)
- [SwiftUIStudy/Network/CollectAPIService.swift](../SwiftUIStudy/Network/CollectAPIService.swift)
- [SwiftUIStudy/Network/HomeAPIService.swift](../SwiftUIStudy/Network/HomeAPIService.swift)
- [SwiftUIStudy/Network/ProjectAPIService.swift](../SwiftUIStudy/Network/ProjectAPIService.swift)
- [SwiftUIStudy/Network/PublicNumberAPIService.swift](../SwiftUIStudy/Network/PublicNumberAPIService.swift)
- [SwiftUIStudy/Network/TreeAPIService.swift](../SwiftUIStudy/Network/TreeAPIService.swift)
- [scripts/tests/async-request-integration-tests.swift](../scripts/tests/async-request-integration-tests.swift)

### `5201fb191` fix: 隔离 SwiftUI 页面状态与本地 HUD (#16)

[#16 分批诊断、修改示例与验证](Swift6页面状态与本地HUD隔离.md)

- [Packages/ThirdParty/ProgressHUD/SwiftUI/Sources/ProgressHUD.swift](../Packages/ThirdParty/ProgressHUD/SwiftUI/Sources/ProgressHUD.swift)
- [SwiftUIStudy/Components/ShareSheet.swift](../SwiftUIStudy/Components/ShareSheet.swift)
- [SwiftUIStudy/Features/Login/LoginViewModel.swift](../SwiftUIStudy/Features/Login/LoginViewModel.swift)
- [SwiftUIStudy/Features/Mine/MineViewModel.swift](../SwiftUIStudy/Features/Mine/MineViewModel.swift)
- [SwiftUIStudy/Features/Project/ProjectViewModel.swift](../SwiftUIStudy/Features/Project/ProjectViewModel.swift)
- [SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift](../SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift)
- [SwiftUIStudy/Features/Search/HotKeyViewModel.swift](../SwiftUIStudy/Features/Search/HotKeyViewModel.swift)
- [SwiftUIStudy/Features/Tree/TreeViewModel.swift](../SwiftUIStudy/Features/Tree/TreeViewModel.swift)
- [SwiftUIStudy/Network/AccountAPIService.swift](../SwiftUIStudy/Network/AccountAPIService.swift)
- [SwiftUIStudy/Network/CoinAPIService.swift](../SwiftUIStudy/Network/CoinAPIService.swift)
- [SwiftUIStudy/Network/CollectAPIService.swift](../SwiftUIStudy/Network/CollectAPIService.swift)

### `cbc3241a4` 修复 Rx 网络加载与 HUD 隔离边界 (#17)

[#17 分批诊断、修改示例与验证](Swift6Rx网络与HUD隔离.md)

- [RxStudy/Account/ViewModel/ListViewModel.swift](../RxStudy/Account/ViewModel/ListViewModel.swift)
- [RxStudy/Base/BaseRequestable.swift](../RxStudy/Base/BaseRequestable.swift)
- [RxStudy/Extension/Utils/HUD.swift](../RxStudy/Extension/Utils/HUD.swift)
- [RxStudy/Home/ViewModel/HomeViewModel.swift](../RxStudy/Home/ViewModel/HomeViewModel.swift)
- [RxStudy/Home/ViewModel/HotKeyViewModel.swift](../RxStudy/Home/ViewModel/HotKeyViewModel.swift)
- [RxStudy/Home/ViewModel/SearchResultViewModel.swift](../RxStudy/Home/ViewModel/SearchResultViewModel.swift)
- [RxStudy/HttpRequest/Plugin/CustomNetworkActivityPlugin.swift](../RxStudy/HttpRequest/Plugin/CustomNetworkActivityPlugin.swift)
- [RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift](../RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift)
- [RxStudy/HttpRequest/Plugin/RequestLoadingPlugin.swift](../RxStudy/HttpRequest/Plugin/RequestLoadingPlugin.swift)
- [RxStudy/HttpRequest/Plugin/ResponseInterceptorPlugin.swift](../RxStudy/HttpRequest/Plugin/ResponseInterceptorPlugin.swift)
- [RxStudy/HttpRequest/Service/Provider.swift](../RxStudy/HttpRequest/Service/Provider.swift)
- [RxStudy/My/ViewModel/CoinRankViewModel.swift](../RxStudy/My/ViewModel/CoinRankViewModel.swift)
- [RxStudy/My/ViewModel/MyCoinViewModel.swift](../RxStudy/My/ViewModel/MyCoinViewModel.swift)
- [RxStudy/My/ViewModel/ToolViewModel.swift](../RxStudy/My/ViewModel/ToolViewModel.swift)
- [RxStudy/RxSwiftExample/RxSwiftCoinRankListController.swift](../RxStudy/RxSwiftExample/RxSwiftCoinRankListController.swift)
- [RxStudy/SwiftUIExample/ViewModel/CoinRankListPageViewModel.swift](../RxStudy/SwiftUIExample/ViewModel/CoinRankListPageViewModel.swift)
- [RxStudy/Tabs/ViewModel/SingleTabListViewModel.swift](../RxStudy/Tabs/ViewModel/SingleTabListViewModel.swift)
- [RxStudy/Tabs/ViewModel/TabsViewModel.swift](../RxStudy/Tabs/ViewModel/TabsViewModel.swift)
- [scripts/tests/async-request-integration-tests.swift](../scripts/tests/async-request-integration-tests.swift)
- [scripts/tests/loading-hud-spy.swift](../scripts/tests/loading-hud-spy.swift)
- [scripts/tests/test-async-request-integration.py](../scripts/tests/test-async-request-integration.py)

### `afc64d511` 修复 Rx Combine 回调与 UIKit 隔离边界 (#18)

[#18 分批诊断、修改示例与验证](Swift6回调与UIKit隔离.md)

- [RxStudy/Account/View/GrayView.swift](../RxStudy/Account/View/GrayView.swift)
- [RxStudy/Base/BaseTableViewController.swift](../RxStudy/Base/BaseTableViewController.swift)
- [RxStudy/Base/BaseViewController.swift](../RxStudy/Base/BaseViewController.swift)
- [RxStudy/Base/Setter.swift](../RxStudy/Base/Setter.swift)
- [RxStudy/Base/TabBarViewControllerChildrenRefreshProtocol.swift](../RxStudy/Base/TabBarViewControllerChildrenRefreshProtocol.swift)
- [RxStudy/Base/Theme.swift](../RxStudy/Base/Theme.swift)
- [RxStudy/Constant/Constant.swift](../RxStudy/Constant/Constant.swift)
- [RxStudy/CustomTabBarExample/CustomTabItem.swift](../RxStudy/CustomTabBarExample/CustomTabItem.swift)
- [RxStudy/Extension/AppDelegate+Extension/AppDelegate+ScreenCapture.swift](../RxStudy/Extension/AppDelegate%2BExtension/AppDelegate%2BScreenCapture.swift)
- [RxStudy/Extension/FSPagerView+RxSwift/RxFSPagerViewDelegateProxy.swift](../RxStudy/Extension/FSPagerView%2BRxSwift/RxFSPagerViewDelegateProxy.swift)
- [RxStudy/Extension/MJRefresh+RxSwift/MJRefresh+RxSwift.swift](../RxStudy/Extension/MJRefresh%2BRxSwift/MJRefresh%2BRxSwift.swift)
- [RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift](../RxStudy/Extension/MJRefresh%2BRxSwift/UIScrollView%2BRxSwift.swift)
- [RxStudy/Extension/RevealingSplashView/SplashAnimatable.swift](../RxStudy/Extension/RevealingSplashView/SplashAnimatable.swift)
- [RxStudy/Extension/Rx+Operators.swift](../RxStudy/Extension/Rx%2BOperators.swift)
- [RxStudy/Extension/SnapKitExtension/ConstraintArray+Extensions.swift](../RxStudy/Extension/SnapKitExtension/ConstraintArray%2BExtensions.swift)
- [RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift](../RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift)
- [RxStudy/Extension/Utils/PollingNetworkRequester.swift](../RxStudy/Extension/Utils/PollingNetworkRequester.swift)
- [RxStudy/Extension/WebView+Extension.swift](../RxStudy/Extension/WebView%2BExtension.swift)
- [RxStudy/Home/Controller/HomeController.swift](../RxStudy/Home/Controller/HomeController.swift)
- [RxStudy/Home/Controller/HotKeyController.swift](../RxStudy/Home/Controller/HotKeyController.swift)
- [RxStudy/Home/Enum/OtherApp.swift](../RxStudy/Home/Enum/OtherApp.swift)
- [RxStudy/InnerViewEvent/InnerEventResponsible.swift](../RxStudy/InnerViewEvent/InnerEventResponsible.swift)
- [RxStudy/My/Controller/AppIconSelectController.swift](../RxStudy/My/Controller/AppIconSelectController.swift)
- [RxStudy/My/Controller/MyCollectionController.swift](../RxStudy/My/Controller/MyCollectionController.swift)
- [RxStudy/My/Controller/MyJueJinController.swift](../RxStudy/My/Controller/MyJueJinController.swift)
- [RxStudy/My/View/MessageCell.swift](../RxStudy/My/View/MessageCell.swift)
- [RxStudy/My/View/MyView.swift](../RxStudy/My/View/MyView.swift)
- [RxStudy/RxSwiftExample/RxSwiftCoinRankListController.swift](../RxStudy/RxSwiftExample/RxSwiftCoinRankListController.swift)
- [RxStudy/SwiftUIExample/View/Refresh/FooterKey.swift](../RxStudy/SwiftUIExample/View/Refresh/FooterKey.swift)
- [RxStudy/SwiftUIExample/View/Refresh/HeaderKey.swift](../RxStudy/SwiftUIExample/View/Refresh/HeaderKey.swift)
- [RxStudy/TabType.swift](../RxStudy/TabType.swift)
- [RxStudy/Tabs/Controller/TabsController.swift](../RxStudy/Tabs/Controller/TabsController.swift)
- [RxStudy/Tabs/Controller/TreeController.swift](../RxStudy/Tabs/Controller/TreeController.swift)
- [RxStudy/Tabs/Enum/TagType.swift](../RxStudy/Tabs/Enum/TagType.swift)
- [RxStudy/ViewController.swift](../RxStudy/ViewController.swift)
- [RxStudy/WebView/Controller/DownloadWebController.swift](../RxStudy/WebView/Controller/DownloadWebController.swift)
- [RxStudy/WebView/Controller/WebViewController.swift](../RxStudy/WebView/Controller/WebViewController.swift)
- [RxStudy/WebView/RxDelegateTest/RxWebViewControllerDelegateProxy.swift](../RxStudy/WebView/RxDelegateTest/RxWebViewControllerDelegateProxy.swift)
- [RxStudy/WebView/RxDelegateTest/WebViewController+Rx.swift](../RxStudy/WebView/RxDelegateTest/WebViewController%2BRx.swift)
- [RxStudy/WebView/View/SafariActivity.swift](../RxStudy/WebView/View/SafariActivity.swift)

### `d19f7a10b` 修复日志导出与日志单例的跨队列边界 (#19)

[#19 分批诊断、修改示例与验证](Swift6日志导出与单例隔离.md)

- [RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift](../RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift)
- [RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift](../RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift)
- [RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift](../RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift)
- [RxStudy/Log/LogUtils.swift](../RxStudy/Log/LogUtils.swift)
- [RxStudy/Log/Modern/ModernLogging.swift](../RxStudy/Log/Modern/ModernLogging.swift)
- [RxStudy/Log/Modern/ModernNetworkLogger.swift](../RxStudy/Log/Modern/ModernNetworkLogger.swift)
- [scripts/tests/rxstudy-logging-tests.swift](../scripts/tests/rxstudy-logging-tests.swift)
- [scripts/tests/test-rxstudy-logging.py](../scripts/tests/test-rxstudy-logging.py)

### `712a94cbb` 修复本地路由的主 Actor 隔离 (#20)

[#20 分批诊断、修改示例与验证](Swift6本地路由隔离.md)

- [Packages/ThirdParty/TheRouter/Sources/TheRouerBridge.swift](../Packages/ThirdParty/TheRouter/Sources/TheRouerBridge.swift)
- [Packages/ThirdParty/TheRouter/Sources/TheRouter+Generate.swift](../Packages/ThirdParty/TheRouter/Sources/TheRouter%2BGenerate.swift)
- [Packages/ThirdParty/TheRouter/Sources/TheRouter.swift](../Packages/ThirdParty/TheRouter/Sources/TheRouter.swift)
- [Packages/ThirdParty/TheRouter/Sources/TheRouterBuilder.swift](../Packages/ThirdParty/TheRouter/Sources/TheRouterBuilder.swift)
- [Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift](../Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift)
- [Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift](../Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift)
- [Packages/ThirdParty/TheRouter/Sources/TheRouterable.swift](../Packages/ThirdParty/TheRouter/Sources/TheRouterable.swift)

### `b745263ca` 隔离 UniMP 入口与 SDK 回调（#21）

[#21 分批诊断、修改示例与验证](Swift6-UniMP隔离.md)

- [RxStudy/UniMP/UniMPManager.swift](../RxStudy/UniMP/UniMPManager.swift)

### `698103b96` 切换 SwiftUIStudy 为 Swift 6 语言模式（#22）

[#22 分批诊断、修改示例与验证](Swift6-SwiftUIStudy语言模式.md)

- [RxStudy.xcodeproj/project.pbxproj](../RxStudy.xcodeproj/project.pbxproj)

### `b33ffd8ca` 切换 RxStudy 为 Swift 6 语言模式（#23）

[#23 分批诊断、修改示例与验证](Swift6-RxStudy语言模式.md)

- [RxStudy.xcodeproj/project.pbxproj](../RxStudy.xcodeproj/project.pbxproj)
- [RxStudy/AppDelegate.swift](../RxStudy/AppDelegate.swift)
- [RxStudy/Extension/MBProgressHUD+Extension.swift](../RxStudy/Extension/MBProgressHUD%2BExtension.swift)
- [RxStudy/Extension/MJRefresh+RxSwift/MJRefresh+RxSwift.swift](../RxStudy/Extension/MJRefresh%2BRxSwift/MJRefresh%2BRxSwift.swift)
- [RxStudy/Home/Controller/HotKeyController.swift](../RxStudy/Home/Controller/HotKeyController.swift)
- [RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift](../RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift)

### `635d6cad8` 进行收尾（#9）

- [Pods/Pods.xcodeproj/project.pbxproj](../Pods/Pods.xcodeproj/project.pbxproj)
- [RxStudy.xcodeproj/project.pbxproj](../RxStudy.xcodeproj/project.pbxproj)
