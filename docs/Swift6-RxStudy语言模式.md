# RxStudy 切换 Swift 6 语言模式（#23）

## 范围与改动

在 `codex/swift6-migration` 的 `698103b96`（#22）之后，按 #9 的逐 Target 迁移顺序，仅修改 `RxStudy` 的 `612DBF6B220022BE007F73CC`（Debug）和 `612DBF6C220022BE007F73CC`（Release）。提交基点为 `5.9`，构建前工作区已有 `5.0`，两者均为 Swift 5 语言模式。本轮将这两处显式设为 Swift 6：

```diff
- SWIFT_VERSION = 5.9;
+ SWIFT_VERSION = 6;
```

工具链版本不等于语言模式；Swift 6 模式已经启用完整严格并发检查，不再额外设置 `SWIFT_STRICT_CONCURRENCY`，也不特设默认 Actor。SwiftUIStudy、项目级设置、Pods 和共享源码均未改动。五个修复文件只属于 RxStudy，不触发 SwiftUIStudy 两配置回查。实际构建在原工作区进行，保留 Xcode 工程重排、Pods 工程、`.DS_Store` 和未跟踪文档，不把它们纳入提交。`Podfile.lock` 与 `Pods/Manifest.lock` 的 SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`；Flutter 保持关闭（无 `.flutter-enabled`）。

## #11 诊断对照与学习记录

以下是 #11 Swift 5 complete 基线的代表性应用诊断及对应交付。前置提交已在当前分支；工单仍开放，本轮按明确指令以实际交付为准，不更改跟踪器状态。

| 前置 | 提交与中文说明 | #11 的诊断与修复边界 |
| --- | --- | --- |
| #12 | `cf85a1ac2`，[共享资源](Swift6共享资源修复.md) | 生成类型的静态资源不满足并发安全；SwiftGen 模板生成可发送的资源描述值，不把 UIKit 对象声明为可发送 |
| #13 | `ec31ac28f`，[共享模型与轮播](Swift6共享模型与轮播修复.md) | 延迟闭包捕获及组件库预览初始化隔离；轮播状态归主 Actor，手势和绑定不跨域 |
| #14 | `b57ff6d78`，[账号与全局状态](Swift6账号与全局状态修复.md) | `AccountManager.shared` 和 `AccountServiceContainer._current` 的共享状态；账号状态归主 Actor，网络侧仅取锁保护的快照 |
| #17 | `cbc3241a4`，[Rx 网络与 HUD](Swift6Rx网络与HUD隔离.md) | `NetworkActivityManager` 计数及 HUD 回调隔离；跨域携带令牌等值，显示和隐藏在 UI 域处理 |
| #18 | `afc64d511`，[回调与 UIKit](Swift6回调与UIKit隔离.md) | 监控回调、Rx/Combine 订阅和 UIKit 协议遵循；明确主 Actor 入口，只有已知调度保证的回调才使用 `assumeIsolated` |
| #19 | `d19f7a10b`，[日志导出与单例](Swift6日志导出与单例隔离.md) | 导出回调、`DDFileLogger` 和 Moya 对象跨队列捕获；在原回调域提取值后再入日志队列 |
| #20 | `712a94cbb`，[本地路由](Swift6本地路由隔离.md) | `apiArray`、`classMapArray` 和 `registerRouterList` 的全局可变状态；路由注册、匹配、跳转归主 Actor，本地源码随 App 编译 |
| #21 | `b745263ca`，[UniMP 隔离](Swift6-UniMP隔离.md) | SDK 实例和 `Any` 事件参数的隔离；回调先按分支确保队列或提取可发送值，不能把 SDK 实例整体跨域 |

以前置改动为例，`class ACarouselViewModel: ObservableObject` 变成 `@MainActor class ACarouselViewModel: ObservableObject`，是因为绑定状态由 UI 拥有，不是因为绑定本身可发送。网络日志从捕获 Moya `Response` 改为传递请求、数据、状态码和字符串头等值，后台记录仍留在原串行队列；把整个日志类移到主 Actor 既不能替代可发送性证明，也会改变时序。

未新增 `@preconcurrency`、`@unchecked Sendable` 或 `nonisolated(unsafe)`。沿用的日志 `@unchecked Sendable` 例外：`ModernLogging` 的 `fileLogger` 由配置锁发布；私有 `ExportLogger` 只封装配置完成的 `DDFileLogger`，滚动和快照遵循框架队列；`ModernNetworkLogger` 的配置由锁保护、计时状态仅在原串行队列读写；`NetworkActivityLogger` 锁保护配置且在回调域提取 `DataRequest`；`NetworkRequestLoggerPlugin` 锁保护级别、计时仅由原队列访问。自有例外在换成编译器能检查的锁内状态或 Actor 且保持时序后移除；私有包装在框架提供符合访问方式的 Sendable 声明后移除。UniMP 成功回调的局部 `nonisolated(unsafe)` 只在同步 `MainActor.assumeIsolated` 检查通过后访问同队列 SDK 实例，不跨队列或逃逸；待 SDK 导入签名明确主 Actor 后移除。具体安全前提见对应前置文档，完整台账留给 #24。

### 首轮失败与最小修复

- **本地路由（两个配置）**：`TheRouterApi.patternString`、`routerClass` 的静态 `var` 是非隔离全局共享可变状态，Swift 5 complete 产生告警，Swift 6 拒绝编译。协议只要求 `get`，仓库内没有写入，改为 `static let`，保持字符串及注册、跳转的主 Actor 边界。
- **缓存插件（两个配置）**：全局 `UserDefaults` 不是 Sendable；串行写入闭包捕获插件、Moya `TargetType` 和 `Response`，也是 #11 的遗留告警。将默认同名 suite 实例放进插件私有锁，在回调域提取缓存键、响应数据、状态码和字符串头，原串行队列仍负责编码和写入。存储格式、有效期、失败回退以及缓存键计算公式不变；写入不再在后台重复调用当前恒真的白名单，而是在原回调域判断。锁不保护 Moya 对象，也不改变回调的 Actor。
- **应用入口（首轮 Release 日志）**：`'UIApplicationMain' is deprecated` 是语言模式升级时的编译错误，不是并发或依赖问题。Swift 5 complete 仍能编译；同一最小 UIKit 入口探针在 Swift 5 / 6 下分别退出 `0 / 1`。按编译器建议从 `@UIApplicationMain` 改为 `@main`，不改生命周期方法。
- **缓存锁的迁移边界**：`OSAllocatedUnfairLock(uncheckedState:)` 是为封装不声明 Sendable 的缓存后端；入口以 `sending` 转移后端，唯一构造点使用插件独有的默认后端，所有读写、清理通过同一锁，只有 `Data` 等可发送值离开锁。若引入自定义后端，不可在锁外保留可变别名。若后端接口及默认实现能提供可检查的 Sendable 保证，改用 `initialState:` 或直接使用线程安全的存储接口后移除 unchecked 构造。
- **HUD 与 MJRefresh（两个配置，第二轮 Swift 6）**：`sending 'progress' risks causing data races` 和 `sending 'observer' risks causing data races` 在原版 Swift 5 complete 均有对应告警。HUD 用 `[progress]` 把每次 `Float` 变化按值传给主队列，避免后台循环和 UI 读写同一个 `var`。MJRefresh 的订阅已检查 Rx 主调度器；缩小 `MainActor.assumeIsolated`，仅读取 `component.state`，拿到枚举后在原回调同步投递，不把 Rx 观察者送入隔离闭包，也不更改 KVO 注册或释放时序。

## 构建取证

2026-11-18，Xcode 26.3（17C529）。Debug、Release 分用两个 Derived Data 路径；先从空目录尝试 Swift 6，然后在各自路径复现 Swift 5 complete、修复后回编、最后复验 Swift 6。完整输出和实参逐项保留在忽略目录 `Derived/swift6-issue23/`，不提交含本机路径的日志。下列命令中的 `$config` 分别为 `Debug`、`Release`，`$D` 为 `/tmp/rx23.J4ywTH`：

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration "$config" -destination generic/platform=iOS -derivedDataPath "$D/$config" CODE_SIGNING_ALLOWED=NO -showBuildSettings
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration "$config" -destination generic/platform=iOS -derivedDataPath "$D/$config" CODE_SIGNING_ALLOWED=NO build
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration "$config" -destination generic/platform=iOS -derivedDataPath "$D/$config" CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.0 SWIFT_STRICT_CONCURRENCY=complete build
xcodebuild -project Pods/Pods.xcodeproj -alltargets -configuration "$config" -sdk iphoneos CODE_SIGNING_ALLOWED=NO -showBuildSettings
```

Swift 6 验收不覆盖全局 Swift 版本；只有复现和修复阶段使用第三条命令。`*.argv`、`*.log`、`*.exit` 分别保存实参、原始输出、退出码；`first-build` 和 `second-build` 为两轮失败的 Swift 6 构建，两配置均退出 `65`；`swift5-complete`（修复前，两配置均退出 `0`）与 `swift5-repaired`（修复后）是对照。入口探针的实参及输出、退出码见 `entry.swift{5,6}.*`。

| 配置 | 修复后 Swift 5 complete 退出码 | 最终 settings / build / Pods settings 退出码 | App 生效设置 | 实际 App 编译参数 | 最终结论 |
| --- | --- | --- | --- | --- | --- |
| Debug | `0` | `0 / 0 / 0` | `SWIFT_VERSION=6`、`CODE_SIGNING_ALLOWED=NO` | `-module-name RxStudy`、`-swift-version 6` | `BUILD SUCCEEDED` |
| Release | `0` | `0 / 0 / 0` | `SWIFT_VERSION=6`、`CODE_SIGNING_ALLOWED=NO` | `-module-name RxStudy`、`-swift-version 6` | `BUILD SUCCEEDED` |

两配置均未显式设置 `SWIFT_STRICT_CONCURRENCY` 或 `SWIFT_DEFAULT_ACTOR_ISOLATION`。最终完整 App Swift 编译调用摘自原日志，见 `{Debug,Release}.app-swift6.log`；各模块实际语言模式及诊断明细分别见 `*.module-modes.txt` 与 `*.diagnostics.txt`。上述首轮、第二轮的 App 错误及对应并发告警均不再出现，没有未解释的本轮阻塞诊断或环境阻塞。未启动模拟器、未签名安装，设备行为尚未验证。

### 已有诊断与依赖边界

- #11 通过命令行把 Swift 5 complete 检查扩到 Pods；本轮最终命令不这么做。PinLayout、SnapKit、SwiftDate、LifetimeTracker 等的基线并发告警未复现，不能据此宣称依赖已修复或都能切换 Swift 6。实际编译中，CocoaLumberjack、SFSafeSymbols 采用各自的 Swift 6 设置，Moya、RxSwift/RxCocoa、CocoaDebug、LifetimeTracker 等依然使用 Swift 5。未发现必须升级依赖的编译证据，不升级、不强推全部 Pods 进 Swift 6。
- CocoaDebug、LifetimeTracker 出现在 Debug 的 App 链接设置，不在 Release 的 App 链接设置；构建依赖图仍可编译这些 Pod，所以不能仅用 Pod 出现在日志里判断 Release App 载入了它们。UniMP 仍使用锁定 `4.36` 的 Objective-C/二进制 SDK；本地 TheRouter 则直接随 RxStudy 以 Swift 6 编译，两者不能按同一方式解读语言模式。
- 分开保留非本轮迁移阻塞告警：应用的系统 API 弃用、WebKit 可选代理签名近似匹配、外部类型协议遵循、已有静态检查与未用值；依赖的弃用、泛型参数遮蔽、Rx 扩展导入告警和构建图中重复匹配 Moya 等。明细见最终构建日志，不把这些计作本轮已修复的并发诊断。

## 自动化验证

逐文件执行 `python3 scripts/tests/<文件>`，完整输出、实参及退出码见 `Derived/swift6-issue23/*.final.*`。下面九个入口均退出 `0`：

- `test-account-session.py`、`test-async-request.py`、`test-async-request-integration.py`
- `test-category-source.py`、`test-flutter-bridge.py`、`test-pagination.py`
- `test-rxstudy-logging.py`、`test-upgrade-tuist.py`、`test_switch_flutter.py`

实际语言模式由编译命令验证，不加镜像测试；现有脚本没有 iOS 缓存/KVO/进度 UI 的设备测试接缝，对应场景留给下列真机步骤，不把宿主编译和夹具测试当作真机结果。

## 真机回归（待开发者执行）

在 Xcode 选择 `RxStudy` Scheme 和已签名的 iOS 17.6 或更新设备，Debug 验证调试工具，Release 复验正常业务。记录设备型号、系统、提交、构建配置、步骤和结果；通用设备构建不会安装或运行 App。

1. 冷启动，检查首页轮播手动与自动滚动、标签切换、主题颜色和图标；Debug 验证 CocoaDebug 与 LifetimeTracker，Release 确认不加载调试入口。
2. 首页、项目、搜索分别测试请求成功、断网失败、取消和快速返回重进；重叠请求结束后 HUD 应归零，旧结果不能更新离场页面。收藏列表下拉与上拉时检查刷新状态和分页；重复进出并用 Memory Graph 或 Allocations 检查页面与订阅释放。
3. 测试登录失败、登录成功、收藏与积分刷新、退出再进入；快速切换会话，确认旧请求不写回当前账号状态。
4. 从列表打开文章、返回和分享，验证 WebKit 导航与对话框回调；触发应用内路由及需登录的路由，检查匹配和返回栈。相同 URL 图片首次加载后重进，区分图片缓存命中与业务接口重载。
5. 发起网络请求后导出并打开日志压缩包，检查日志完整、按预期脱敏、分享 UI 正常。打开 UniMP、复用已有实例、触发事件和关闭；用测试资源覆盖一次失败回调。Flutter 保持关闭，不声称验证启用路径。
6. 在线搜索 `Kotlin` 并加载第一页，等待 `HomeService.queryKeyword` 经 `homeProvider` 写入。断网，重新搜索相同关键词的第一页，应回退到刚才的业务数据；换一个此前未查询的关键词，应不误用前一响应。该检查独立于图片缓存，Debug/Release 均需执行。

## 双轴审查

- **规范轴**：补齐路由常量的中文注释和缓存锁的所有权约束；读写键拼接是基点已有重复，不为迁移另抽象。复审无新增规范或安全阻塞。
- **规格轴**：两轮构建阻塞均已修复并复验；记录缓存判定时点并增加独立的响应缓存真机复测。最终证据表与九个脚本均经核对，未发现未满足的本轮编译交付项。

## 下一项：#24

代码前置已落地后，#24 仍需确认跟踪器上 #22、#23 的阻塞状态，再开始最终四项矩阵。可使用以下提示词：

> 执行 `$implement`，完成 seasonZhu/RxStudy #24「Swift 6 迁移：完成 Swift 6 四项编译验收与设备回归交接」。先读 #9/#11/#22/#23/#24、两份语言模式说明与前置学习记录；确认前置工单状态或明确按实际交付执行。在 `codex/swift6-migration` 保留用户改动、锁定依赖及 Flutter 关闭，用原 workspace、两个 App Scheme 各自 Debug/Release、`generic/platform=iOS`、关闭签名、不全局覆盖 Swift 版本，在同一基点取得四份设置、实际 App 模块 `-swift-version 6`、完整命令、日志、退出码和 `BUILD SUCCEEDED`。逐文件运行全部脚本，对照 #11 按范围归类诊断，汇总临时兼容标记台账与两个 App 的中文真机清单（设备、系统、提交、配置、步骤和结果字段）。实测由开发者执行，双轴审查后独立提交。
