# Swift 6 回调与 UIKit 隔离（Issue #18 / C2）

基点 `cbc3241a4`，分支 `codex/swift6-migration`。开发者授权以已提交验证的 #14 为前置，忽略 GitHub OPEN 状态；复用 #17 LoadingProvider、活动令牌与收尾，不重复实现计数。保留用户 `.DS_Store`、工程文件和未跟踪迁移计划，不安装依赖、不开 Flutter、不切 Swift 6、不运行模拟器。构建针对当前工作区，不代表干净检出。

## 真实诊断与修改前后

源码基线见 `Derived/swift6-issue18/source-baseline.log`，退出 0 且 BUILD SUCCEEDED。通过更新源码时间戳触发真实编译，不能把先前增量构建无告警作为安全证据。#11 的 UIKit 协议、主题服务、刷新默认值、回调访问诊断仍存在；#17 新暴露的 Future.value 告警也已复现。

### Binder 与 UI 同步协议

前：`Binder(base) { view, value in view.count = value }`。
后：`Binder(base) { view, value in MainActor.assumeIsolated { view.count = value } }`。

锁定 RxSwift 的 Binder.swift 默认使用 MainScheduler()，在实际 binding 前调度，弱持有 target。灰度、网络错误页、MJRefresh 动作和状态、收藏编辑、导航按钮、个人信息、树列表、热词、Tab 选择和 WebView reload 绑定均沿用默认调度器；不新增 Task 或异步跳转，不改变事件顺序、重入和释放行为。assumeIsolated 是运行时检查和静态隔离接缝，不负责调度，也不是把 UIKit 对象变成 Sendable。MJRefresh 的 Observable.create 原有 MainScheduler.ensureExecutingOnScheduler() 保留，在检查后同步读取 state。

自有刷新、事件冒泡、SplashAnimatable 和 WebViewControllerDelegate 协议声明 MainActor；DZNEmptyDataSet、LifetimeTrackable、FSPagerView、JXSegmentedView、文档交互和 HasDelegate 使用具体类型的 `@MainActor` 协议遵循。外部协议没有被修改，也没有 @preconcurrency 掩盖。WebView Rx 代理和它的 Reactive 入口同在主 Actor，DelegateProxyType 使用隔离遵循，避免从 assumeIsolated 返回非 Sendable delegate。只允许在 UI 隔离域安装和访问代理。

UI 单例 themeService、主题切换与触觉反馈入口归主 Actor。屏幕尺寸、安全区常量、示例 UIView、Tab 工厂、布局数组工具和必要调用端也归主 Actor；不改变其值的计算方式。Header/Footer PreferenceKey 和 EnvironmentKey 的默认值从可变静态存储改为计算属性：`static var defaultValue: Value { [] }`，每次取得独立默认值，不再共享可变状态，无须给含 Anchor 的结构添加不安全 Sendable。

### Combine Future 异步接缝

前：`let value = try await response.value`，非 Sendable Future 从主 Actor 进入 Combine 非隔离异步 getter。
后：在主 Actor 建立 Future 的 sink，通过 `withCheckedContinuation` 只返回 Void；模型和错误仍在原回调侧消费，不把 Page、MoyaError 或 Future 跨 Actor 传递。Future 保证至多一次结果，成功从 receiveValue 恢复，失败从 completion 恢复，成功 completion 不重复恢复。仍然等待请求完成后返回，不改请求队列。

每次调用仍创建独立临时 ViewModel，withExtendedLifetime 保持它到等待结束，重复进入不会用同一消费订阅覆盖前一次等待。上游 cancellable 与 futureCancellable 分别持有，防止给消费订阅赋值时释放上游；isolated deinit 取消两者。沿用示例原有取消语义，没有增加 Task 取消到 Moya 的桥接；无 data 的 compactMap 仍可能不完成 Future，是既有示例限制，不声称本轮修复。

### 逐项调度边界

| 路径 | 原调度 | 修改后 |
| --- | --- | --- |
| Binder、MJRefresh 初始读取 | Binder 默认主调度器 / 显式主调度器检查 | 保持同步；assumeIsolated 声明已存在的保证 |
| Timer 图标与轮播回调 | 主 Actor UI 入口在主 RunLoop 安装 Timer | assumeIsolated 同步检查，间隔与顺序不变 |
| 录屏通知 | observer queue 为 .main | assumeIsolated 同步检查，不额外延迟 |
| 可达性触发首次页面刷新 | Alamofire 回调无静态 Actor 保证 | 主队列异步执行刷新及首次标记写入，UI 操作延后一轮 |
| PollingNetworkRequester HUD | action/stop/释放回调可能来自不同队列 | show/setMask 在同一主队列块，dismiss 异步入主队列；请求调度与结果 Subject 保持。不是 C1 活动计数 |
| SafariActivity.perform | 同步覆写无静态 UI 隔离 | 先取 URL 值，Task MainActor 再访问 UIApplication，打开动作异步执行 |
| Future 示例 | await 非隔离 value | 原 publisher 回调消费，Void continuation 恢复原主 Actor 调用者 |

网络监听回查：NetworkMonitor 在 NWPath 回调先生成 Sendable NetworkStatus，再由主队列写 Subject/Relay；AppDelegate 的原生、Rx 和 legacy 回调先提取 Bool，再由主队列调用 AccountManager.updateNetworkReachability。#14 的实现已满足所有权，本轮不重复修改，也不把 Relay 交给后台。NetworkMonitor 的监听令牌管理、重复 start 和示例生命周期原有行为未扩展重构。

WKWebView JavaScript 泛型转换失败的 Error 原携带 Any?，触发 Sendable 关联值诊断。改携带 String(describing:)；唯一业务调用端仅打印该值。前：`.genericConversionsFailed(any)`；后：`.genericConversionsFailed(String(describing: any))`。不再保留任意对象，错误文本仍可用于调试；不改变成功泛型返回值。WebView/MyJueJin 的清理使用 isolated deinit，确保移除 message handler 位于主 Actor。

## Actor 与 Sendable 安全边界

本轮未增加 @unchecked Sendable、@preconcurrency 或 nonisolated(unsafe)。assumeIsolated 的依据逐项列于上表；当第三方提供带 MainActor 的闭包签名时，可移除对应桥接；若未来允许自定义后台 Binder 调度器、后台安装 Timer 或更换通知队列，必须先重建调度保证，不能复制这些断言到任意回调。

UI 协议隔离不会自动改变 Rx/Combine 任意闭包的执行队列。网络模型仍不是 Sendable，订阅不允许被后台 detached Task 任意共享。isolated deinit 依赖当前工具链支持，不等于普通 Swift 5.9 编译器支持所有本轮语法；SWIFT_VERSION=5.9 是语言模式，工具链另行记录。

## 验证范围与设备交接

遵循 tdd 技能的接缝原则，复用开发者授权的账号、请求和完整既有脚本，不增加只断言注解字符串的镜像测试。现有 macOS 脚本不能验证 UIKit 回调运行时 Actor 检查、Timer、订阅页面释放或 HUD 视觉行为；源码构建也不能替代设备验证。

开发者执行：

1. 登录、退出、切号；进出个人信息、收藏、积分与请求示例页，核对账号状态和请求头。
2. 首页、热词、树分类、项目页连续刷新/加载更多，快速进出并重复进入，确认 MJRefresh 动作、错误页和 Tab 切换无主线程断言，无旧页面重复响应。
3. WebView 成功回调、Rx reload 与代理安装，快速返回后再进入；观察 deinit/订阅销毁，确认不重复回调，脚本消息处理器不残留。
4. Future 示例并发执行两次，覆盖成功、业务/网络失败和离开页面，确认每次等待独立；Task 取消不会自动新增取消请求保证。
5. 切主题、灰度模式、触觉反馈、录屏状态；轮播自动滚动、手势干预和图标 Timer 示例无隔离检查失败。检查反复进入后的既有 Timer 生命周期。
6. 断网/恢复和首次网络授权，检查首次页面刷新和 Relay 更新；并行请求成功/失败/取消及重复取消，确认沿用 C1 收尾，没有残留 HUD。
7. Polling 请求停止、释放和前后台切换，确认异步关闭 HUD；分享 Safari 后能打开正确 URL。

设备验证由开发者执行，尚未执行。

## 剩余诊断归属

日志全局状态、导出捕获与 NetworkDebuggingPlugin 归 #19；TheRouter 与页面路由遵循归 #20；UniMP 归 #21。ResponseCachePlugin 的 UserDefaults/TargetType/Response 捕获为既有缓存边界，未改缓存策略，后续切换前须单独审计。锁定 Pods 的并发与弃用警告、SwiftLint、脚本输出、重复链接库及 AppIntents 提示保持单列，不宣称全工程无警告。

## 构建、脚本与完整执行证据

工具链 Xcode 26.3（17C529）。Podfile.lock 与 Pods/Manifest.lock 的 SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`，`.flutter-enabled` 不存在。两配置应用实际设置均为 `SWIFT_VERSION = 5.9`、`SWIFT_STRICT_CONCURRENCY = complete`、`CODE_SIGNING_ALLOWED = NO`。完整日志保存在仓库忽略的 Derived 目录；下列命令、退出码入库，日志未删减。matrix.json/tests.json 保存同一机器可读记录。

首次增量 targeted.log 退出 0；source-baseline.log 源码重编译退出 0。targeted2.log 退出 65，首个环境错误为全局 ModuleCache 的 Session.modulevalidation 与 SDKStatCaches 文件不存在，clang importer 创建失败。之后所有构建使用独立 `-derivedDataPath Derived/swift6-issue18/build`；targeted3、targeted4、targeted5 均退出 0。中途两次编辑脚本分别因匹配断言和缺少 Python re 导入提前中止，已修正，不计作成功验证；随后源码由真实编译覆盖。

针对性账号和请求脚本命令与最终同名脚本一致，日志为 `Derived/swift6-issue18/test-account-session.py.targeted.log`、`test-async-request.py.targeted.log`、`test-async-request-integration.py.targeted.log`，均退出 0。

### 审查前构建

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Debug -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue18/Debug-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Debug build
```

退出码 0；完整日志 `Derived/swift6-issue18/Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Release -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue18/Release-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Release build
```

退出码 0；完整日志 `Derived/swift6-issue18/Release-build.log`。

### 双轴审查与修复后最终构建

按 code-review 技能，将固定基点 cbc3241a4 到本轮工作区的 RxStudy 差异交给两个独立代理，明确排除用户文件（提交前审查，因此使用工作区差异）。Standards 依据 AGENTS.md、代码编写规范及技能气味清单；Spec 依据 #18、#9 与用户明确 C2 边界。

Standards 首次 1 项 P3：HomeController 新增隔离块缩进，已修复，独立复查剩余 0。Spec 首次 1 项 P2：首次可达性判断与写标记被异步边界拆开，可能多次刷新；已将读取、判断、刷新、写标记整体移入主队列，独立复查剩余 0。git diff --check 通过。

以下为修复后最终源码：RxStudy Debug/Release 与共享源码回查 SwiftUIStudy Debug 全部退出 0，日志均含 BUILD SUCCEEDED。SwiftUIStudy Release 非本轮验收项，未补跑完整双 Target 四项切换矩阵。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Debug -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/RxStudy-Debug-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Debug build
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/RxStudy-Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Release -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/RxStudy-Release-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Release build
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/RxStudy-Release-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme SwiftUIStudy -configuration Debug -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/SwiftUIStudy-Debug-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme SwiftUIStudy -configuration Debug build
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/SwiftUIStudy-Debug-build.log`。

### 诊断对照结果

source-baseline.log 与 targeted3/4/5、审查前 Release 源码编译及最终复验联合对照：本次处理的 Binder UI 访问、UI 协议遵循、主题服务/触觉反馈、屏幕常量/工厂/布局调用、刷新默认值、Future.value、JavaScript Any 错误关联值、WebView 析构、Timer/通知与可达回调隔离诊断不再出现。隔离传播新增的代理 Reactive 入口与 TagType.bottomOffset 诊断亦已修复。非 lint 保留告警清单分别在 reviewed/*-warnings.txt；不以最终增量日志告警数量代替源码检查。

首次全局缓存环境阻塞已通过独立缓存构建解除；最终编译无环境阻塞。自动化结果如下，设备检查尚未执行。

```sh
python3 scripts/tests/test-account-session.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test-account-session-final.log`。

```sh
python3 scripts/tests/test-async-request-integration.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test-async-request-integration-final.log`。

```sh
python3 scripts/tests/test-async-request.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test-async-request-final.log`。

```sh
python3 scripts/tests/test-category-source.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test-category-source-final.log`。

```sh
python3 scripts/tests/test-flutter-bridge.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test-flutter-bridge-final.log`。

```sh
python3 scripts/tests/test-pagination.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test-pagination-final.log`。

```sh
python3 scripts/tests/test-rxstudy-logging.py
```

退出码 1；完整日志 `Derived/swift6-issue18/reviewed/test-rxstudy-logging-final.log`。

```sh
python3 scripts/tests/test-upgrade-tuist.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test-upgrade-tuist-final.log`。

```sh
python3 scripts/tests/test_switch_flutter.py
```

退出码 0；完整日志 `Derived/swift6-issue18/reviewed/test_switch_flutter-final.log`。

最终完整运行现有 9 项脚本，8 项退出 0；test-rxstudy-logging.py 退出 1，仍为 `static let mode: LoggingMode = .legacy` 的“默认必须保持旧体系”断言失败，与前置任务记录一致，未修改或删除断言，不计通过。账号、异步请求、真实请求集成、分页等通过不代表 UIKit 设备行为通过。此前审查前完整脚本结果亦为 8/9，日志位于 Derived/swift6-issue18/*-final.log。

下一项就绪任务为 #19（日志跨队列捕获），提示词见 [Swift6-Issue19新对话提示词.md](Swift6-Issue19新对话提示词.md)。
