# Swift 6 最终验收与真机交接（#24）

2026-11-18，分支 `codex/swift6-migration`，四项构建共用提交基点 `b33ffd8caa9ecc463231bbb5a283943e197eb89c` 和原工作区。#9 是总规格，#11 已关闭并交付诊断基线。#22、#23 在 GitHub 仍开放，切换提交 `698103b96`、`b33ffd8ca` 已在本分支，按实际交付进入验收。跟踪器仍保留原状态。

构建包含原有工程文件、Pods 工程和 `HomeViewModel.swift` 本地差异，设备记录需注明是否使用该分页改动。两份锁文件的 SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`，Flutter 关闭。四项使用各自既有 Derived Data 路径执行 clean build，应用语言版本取自工程配置。

## 构建与脚本取证

工具链为 Xcode 26.3（17C529）。完整命令、原始输出及退出码均在本机忽略目录 `Derived/swift6-issue24/` 中，按同名 `.argv`、`.log`、`.exit` 配对。设置日志为 `<App>-<配置>.settings.log`，构建日志为 `<App>-<配置>.build.log`，另存应用实际 Swift 编译参数 `*.app-swift6.log`、模块语言版本 `*.module-modes.txt` 和告警/错误 `*.diagnostics.txt`。复跑时执行以下命令，优先使用自己的 Derived Data 路径。

```sh
for app in RxStudy SwiftUIStudy; do
  case "$app" in
    RxStudy) root=/tmp/rx23.J4ywTH ;;
    SwiftUIStudy) root=/tmp/rx22.V0batm ;;
  esac
  for config in Debug Release; do
    xcodebuild -workspace RxStudy.xcworkspace -scheme "$app" -configuration "$config" -destination generic/platform=iOS -derivedDataPath "$root/$config" CODE_SIGNING_ALLOWED=NO -showBuildSettings
    xcodebuild -workspace RxStudy.xcworkspace -scheme "$app" -configuration "$config" -destination generic/platform=iOS -derivedDataPath "$root/$config" CODE_SIGNING_ALLOWED=NO clean build
  done
done
```

| App | 配置 | 设置 / 构建退出码 | 生效版本 / 实际前端参数 | 结果 |
| --- | --- | --- | --- | --- |
| RxStudy | Debug | `0 / 0` | `6` / `-module-name RxStudy -swift-version 6` | BUILD SUCCEEDED |
| RxStudy | Release | `0 / 0` | `6` / `-module-name RxStudy -swift-version 6` | BUILD SUCCEEDED |
| SwiftUIStudy | Debug | `0 / 0` | `6` / `-module-name SwiftUIStudy -swift-version 6` | BUILD SUCCEEDED |
| SwiftUIStudy | Release | `0 / 0` | `6` / `-module-name SwiftUIStudy -swift-version 6` | BUILD SUCCEEDED |

表中参数按用途摘录，完整参数及顺序见实际调用日志。四项均采用通用 iOS 目的地，`CODE_SIGNING_ALLOWED=NO`，未显式设置 `SWIFT_STRICT_CONCURRENCY`、`SWIFT_DEFAULT_ACTOR_ISOLATION`。无构建环境阻塞。取证目录的 `before.txt`、`after.txt` 比对一致，覆盖已有跟踪差异、两个未跟踪文件及锁文件，构建完成后仍无 `.flutter-enabled`。

九个脚本均逐文件执行 `python3 scripts/tests/<文件名>` 并退出 `0`，各自命令、完整输出及退出码与构建取证同目录。

- `test-account-session.py`、`test-async-request-integration.py`、`test-async-request.py`
- `test-category-source.py`、`test-flutter-bridge.py`、`test-pagination.py`
- `test-rxstudy-logging.py`、`test-upgrade-tuist.py`、`test_switch_flutter.py`

本轮是验收和文档交接，无新增行为接缝，沿用既有宿主 Swift 编译及夹具测试；离页时的设备调度、HUD 和 UniMP 回调由真机清单覆盖。Flutter 相关脚本覆盖现有桥接及开关测试，应用的设备验收配置仍关闭 Flutter。

## #11 诊断对照与学习记录

#11 用 Swift 5 和命令行 `SWIFT_STRICT_CONCURRENCY=complete` 收集诊断，覆盖同时传播到 Pods。最终构建保留依赖各自设置，Swift 6 应用模块执行完整严格并发检查。两批诊断的检查强度、模块和优化范围不同，按来源及问题对照。

| #11 来源与代表诊断 | 已交付的修复及边界 |
| --- | --- |
| Shared 资源静态值持有非 Sendable 类型 | #12 在 SwiftGen 模板及生成产物上使用可发送资源描述值，UIKit 对象在调用处解析 |
| Shared 轮播手势与延迟闭包、组件预览隔离 | #13 将轮播 ViewModel 与界面交互置于主 Actor |
| 账号单例、服务容器全局可变状态 | #14 账号状态归主 Actor，请求侧使用锁保护的值快照 |
| SwiftUI Moya 响应、continuation 与共享服务 | #15 在回调域解码，桥接仅传 `Value: Sendable` |
| SwiftUI 页面任务捕获 ViewModel、HUD 共享状态 | #16 页面状态与本地 HUD 归主 Actor，旧请求结果由页面状态控制 |
| Rx 插件、网络计数、HUD 调度 | #17 令牌与计数生命周期明确，显示隐藏由 UI 域处理 |
| UIKit 协议遵循、Rx/Combine 及监控回调 | #18 在已知调度保证处同步进入 UI 隔离域，协议明确主 Actor |
| 日志单例、导出、Moya 响应跨队列捕获 | #19 在回调域提取值，锁保护配置，原串行队列处理日志 |
| 本地路由静态可变注册表与参数 | #20 路由注册与跳转归主 Actor，源码随 RxStudy 编译 |
| UniMP SDK 实例与 Any 参数 | #21 按回调分支提取可发送值或同步检查主 Actor |
| Rx 缓存对象和 Moya 捕获、路由静态属性、HUD 变量及刷新观察者 | #23 锁住插件独有后端，后台只接收值；只读路由声明改 `static let`；按值捕获进度；主 Actor 块仅同步读取刷新状态 |
| Swift 6 应用入口弃用错误（在 #23 切换时观察） | `@UIApplicationMain` 改为 `@main`，保留 UIKit 生命周期方法 |

修改前 `class ACarouselViewModel: ObservableObject` 的延迟处理能触及离开 UI 隔离域的状态。修改后 `@MainActor class ACarouselViewModel: ObservableObject` 把绑定、手势与界面状态交由同一 Actor。网络桥接从非泛型 `AsyncRequestState` 到 `AsyncRequestState<Value: Sendable>`，在传入 continuation 前已解码响应。Actor 约束状态在哪里访问，Sendable 约束什么值可以跨域。更完整的编译错误和代码示例见 [RxStudy 语言模式](Swift6-RxStudy语言模式.md)、[SwiftUIStudy 语言模式](Swift6-SwiftUIStudy语言模式.md)及 [#11 基线](Swift6严格并发诊断.md)。

### 最终诊断与既有告警

- 四份构建未复现上表的应用、共享及本地路由并发诊断。本轮仅验收和记录，表中的代码修复来自前置提交。按构建原文复核，未发现未解释的 #24 阻塞诊断。
- 既有依赖并发告警（`*.concurrency-diagnostics.txt`）为 Moya 的 `cURLDescription(calling:)` 可发送性不匹配及 `MoyaRequestInterceptor.prepare` 可变属性（四项都有），还有 RxStudy Debug 的 RxSwift `RecursiveLock` 需重述继承的 `@unchecked Sendable`。#11 在 PinLayout、SnapKit、SwiftDate、LifetimeTracker 等依赖中的其他告警，本轮依赖检查强度不同，不能据此判定已修复。
- 实际模块参数确认 RxStudy 的 CocoaLumberjack 与 SFSafeSymbols 使用 Swift 6，Moya、RxSwift/RxCocoa、CocoaDebug、LifetimeTracker 等使用 Swift 5。SwiftUIStudy 的 Alamofire、Kingfisher、Moya 和 ProgressHUD 均使用 Swift 5。UniMP 继续链接锁定的 Objective-C/二进制 SDK 4.36。本轮无需要升级锁定依赖的构建证据。
- 其他应用告警包括 WebKit 可选代理近似匹配、弃用 API（如 SwiftUI 热词导航）、外部协议遵循、隐式转换及未用值。SwiftLint 还扫描到了其他 Target、测试和本机 Derived 路径，其静态检查告警与 App Swift 前端诊断分别理解。
- 其他依赖与构建告警包括旧系统 API 弃用、泛型参数遮蔽、Moya 同模块导入和多 Target 匹配、重复链接库、资源未指派及缺少 AccentColor、方向配置、构建脚本缺少输出声明、AppIntents 元数据跳过。逐项原文见 `*.diagnostics.txt` 和完整构建日志。

### 兼容标记台账

应用、本地模块和共享源码共核对六处 `@unchecked Sendable`、一处 `nonisolated(unsafe)`、一处 `uncheckedState:`，无 `@preconcurrency`。以下沿用前置交付。

| 声明 | 必要性与安全前提 | 移除条件 |
| --- | --- | --- |
| `AsyncRequestState<Value>` | 取消与响应可来自不同线程，NSLock 保护结果、continuation、取消句柄，锁内摘除后解锁执行 | 可检查同步容器保持取消和完成只终结一次 |
| `ModernLogging` | 导出跨队列需读取已配置 logger，配置锁负责发布 | 将配置发布和读取改为编译器可检查的隔离 |
| `ModernLogging.ExportLogger` | 封装已配置的 DDFileLogger，滚动和快照依框架队列契约 | 框架提供适用于该访问方式的 Sendable 接口 |
| `ModernNetworkLogger` | 插件跨回调访问，锁保护配置，计时由原串行队列持有 | 可检查的隔离保持队列时序 |
| `NetworkActivityLogger` | 监听回调跨队列，配置有锁，DataRequest 在回调域提取值 | 可检查同步容器和可发送快照覆盖所有入口 |
| `NetworkRequestLoggerPlugin` | 日志级别有锁，计时仅由原队列访问 | 用可检查的隔离保留日志顺序 |
| `UniMPManager` 成功回调的局部 `nonisolated(unsafe)` | ObjC 签名缺少隔离信息；SDK 实例仅在同步 `MainActor.assumeIsolated` 检查通过后访问，无逃逸 | SDK 导入签名明确主 Actor；设备覆盖首次打开与实例复用 |
| `ResponseCachePlugin` 的 `uncheckedState:` | 后端接口缺 Sendable；`sending` 交接独有后端，所有访问经同一锁，跨域仅传值 | 后端提供可检查的 Sendable 保证，或迁移到同等隔离的存储接口 |

Rx Binder 默认主调度器、MJRefresh 主调度器检查、主 RunLoop 上的 Timer 和指定主队列的通知提供同步 `assumeIsolated` 的运行时前提。该调用不负责调度，调度约定变更时需重查。回调签名能静态表达主 Actor 后可移除相应桥接。UniMP 关闭和事件回调各自的条件见 [UniMP 隔离说明](Swift6-UniMP隔离.md)。Pods 继续使用其原生模式，移除 Swift 5 兼容保留需对应模块构建与行为回归证据。

## 双 App 真机回归

由开发者在 Xcode 用签名设备执行，建议最低支持的 iOS 17.6 设备与当前支持设备均记录。每个 App 跑 Debug 与 Release。每条记录填写 **App、设备型号、iOS 版本、提交、工作区差异、配置、用例编号、实际步骤、预期、实际结果、通过/失败/不适用、日志或截图**。当前全部待执行。

| 编号 | App | 步骤与预期 |
| --- | --- | --- |
| 1 | 双 App | 冷启动、切前后台、切标签；滚动首页轮播后等待自动滚动，无重复计时与资源缺失。RxStudy Debug 查调试入口，Release 确认入口不出现 |
| 2 | 双 App | 首页、项目、公众号、体系和搜索验证加载、下拉刷新、连续分页、末页提示、返回重进；点击文章、分享及返回，检查导航栈及 WebKit 加载 |
| 3 | 双 App | 正常联网完成请求，再断网触发失败；恢复网络后重试。请求中快速离页以触发取消，再重进发新请求。检查旧结果不会覆盖新页面、网络错误提示正常 |
| 4 | 双 App | 并发触发两处加载，分别以成功、失败或取消结束；HUD 和下拉/上拉状态最终清空，完成时无持续遮挡或重复提示 |
| 5 | 双 App | 反复进入退出搜索、列表、Web 页；结合 Memory Graph 或 Allocations 检查页面和订阅释放，离场观察者无重复通知 |
| 6 | 双 App | 首次加载同一张图片后退出重进，记录网络追踪，区分页面数据请求与图片下载；切换浅色、深色并检查主题颜色、图标、占位资源 |
| 7 | 双 App | 测试账号登录失败、成功、收藏、积分、退出和重登；确认旧登录结果不覆盖新会话 |
| 8 | RxStudy | 在调试入口用 `wandroid://hotkey?source=device` 检查已注册路由和 query，再测正确参数、缺失参数、未知路径和返回；检查页面仅打开一次、无崩溃或错误回调；在退出登录后打开受保护的入口，检查登录拦截及返回 |
| 9 | SwiftUIStudy | 通过标签及页面链接打开文章与详情，返回后检查导航状态和重复点击；本地 TheRouter 与 UniMP 记不适用 |
| 10 | RxStudy | 在「我的」打开 UniMP，检查 wgt 安装、版本日志、闪屏，再首次打开、复用、双向事件、关闭后重开；测试缺失资源的失败提示。确认回调顺序与实例一致、无主 Actor 断言崩溃。若资源不可用，登记阻塞 |
| 11 | 双 App | 确认验收配置下 Flutter 入口不可用；本轮设备矩阵保持 Flutter 关闭 |

补充回归（RxStudy）在「我的」执行日志导出，验证导出完成后分享、本地打开与取消返回，检查文件可读及 UI 状态正常。

## 双轴审查

- 规范轴发现 0 项规范违规、0 项代码异味。已按建议补充可直接使用的路由地址，最终差异空白检查通过。
- 规格轴复核四项构建、九个脚本、诊断归属、兼容台账和设备交接。已补齐初审指出的取证段及告警归属，增加登录拦截与日志导出回归。最终构建和脚本证据逐项核验后，设备行为仍待开发者执行。

## 下一项就绪任务

当前迁移工单中，#24 后的就绪交接是开发者真机回归。GitHub 尚无后续迁移工单可接手，Tuist 同步属于 #9 范围外。

> 继续 seasonZhu/RxStudy #24 的双 App 真机回归。使用本次 Swift 6 验收基点，记录提交和本地差异，保留依赖锁及 Flutter 关闭。按《Swift6最终验收与真机交接》在签名真机上执行 RxStudy、SwiftUIStudy 的 Debug/Release 用例，记录型号、系统、步骤、预期与实际结果，附日志或截图。对失败项保留复现步骤，重点记录 UniMP 首开、复用、事件和关闭顺序，以及两 App 的取消与 HUD 收敛。不适用与设备阻塞逐项填写。
