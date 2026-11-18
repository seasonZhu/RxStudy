# Swift 6 账号与全局状态修复（Issue #14）

## 范围与所有权

基点 ec31ac28f32bc2553a23714d4dca15c424c6d0a4；分支 codex/swift6-migration。只实施 D2，保持 Swift 5、Flutter 关闭和锁定依赖。用户 .DS_Store 与未跟踪迁移计划保留。

账号模型、凭证、Relay 以及服务容器归 MainActor。同步 Moya 请求头和活动拦截不能等待 Actor，故只通过 OSAllocatedUnfairLock 读取可发送的 String/Bool 值快照；不向后台暴露模型或 Relay。登录先保存模型和 Cookie 快照再发送登录事件，退出先清空快照再发送退出事件，网络可达写入同时更新快照和 Relay。锁内不调用业务回调。

修改前：`AccountManager.shared.isLoginRelay.value ? ["cookie": AccountManager.shared.cookieHeaderValue] : nil`。
修改后：`AccountManager.requestHeaders`；主 Actor 内先计算 Cookie 字符串，再将该值写入锁。

账号登录 Rx 链和必要 ViewModel 写入显式使用 MainScheduler。Rx 闭包本身不承诺 MainActor：运行保证来自 observe(on:) 及调用端主 Actor 入口，不能将结论推广到任意订阅。MyViewModel 使用独立初始化签名，避免重写非隔离父类 init；两个分页 ViewModel 采用隔离协议遵循，而非更改所有分页协议与调用方。

NetworkMonitor 的 Subject、Relay、监听器集合和控制方法归 MainActor；后台 NWPath 回调构造 Sendable 状态值后交给主队列发布。删除监听器集合原有队列，避免双重所有权。取消令牌通过锁取走可发送取消闭包，在锁外执行一次；移除监听器通过 Task 回主 Actor，cancel 返回不意味着主 Actor 已完成移除。监听器原有 callback 与注册方式保留，本轮不调整订阅生命周期行为。

KeyConstants 与嵌套 APIKeys 均显式 MainActor（外层枚举隔离不会自动隔离嵌套类型）。资源完成闭包仅携带 Error 和 MainActor Sendable 完成函数，再到主队列处理；NSBundleResourceRequest 留在主 Actor 闭包中。原有资源读取失败回调与密钥首次访问缓存语义未改。

## 诊断对照与安全边界

#11 的实际诊断包括 AccountManager.shared 非 Sendable 共享状态、AccountServiceContainer._current 非隔离全局可变状态、NetworkMonitor.shared 及队列捕获 self/listener、KeyConstants.storage/myServiceYKey 和 request/callback 非 Sendable 捕获。修复后检查最终构建日志中的这些文件，并同时回查必要调用端的协议遵循与初始化告警。

修改前 `final class AccountManager` / `private static var _current`；修改后类型显式 `@MainActor`。修改前监听集合在 barrier 队列存取而回调主队列发布；修改后集合和发布由同一 Actor 拥有。NetworkStatus 与网络接口枚举声明 checked Sendable，编译器检查存储值。

未使用 @unchecked Sendable、@preconcurrency 或 nonisolated(unsafe)。OSAllocatedUnfairLock 是系统的同步边界，最低版本满足现有 iOS 17.6。MainActor 引用可以跨域携带，但访问状态仍须回到 Actor；Sendable 的网络状态值也不使 Rx/Combine 对象自动可发送。锁保护仅限请求快照和取消令牌，不能用来证明整个账号模型可被后台访问。

日志、路由、Provider/插件自身的全局诊断、网络活动计数和其他 UI/Rx/Combine 诊断分别留给 #19、#20、#17、#18 等任务；未切换语言模式。现有 SwiftLint 的三目 Void 调用告警保留。增量编译发射受缓存影响，不用告警总数证明整个工程安全。

## 验证范围

沿用既有账号会话、异步请求等脚本，不新增镜像测试。账号脚本主要覆盖 SwiftUI 会话，不代表 UIKit 账号行为已在设备验证。TDD 技能已读取，本轮没有新增已确认的行为测试接缝；使用已有脚本与编译器隔离检查验证。

Podfile.lock 与 Pods/Manifest.lock SHA-256 均为 6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff。设置核对 SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete、CODE_SIGNING_ALLOWED=NO；各项实际设置行及完整命令见下表后记录。

设备验证由开发者执行：登录、退出、切号、自动登录、收藏增删、积分和未读消息、断网恢复、重复进入页面、监听取消、资源密钥加载。未运行模拟器，编译通过不等于设备行为通过。

## 独立审查

按 code-review 技能对基点以来本任务源码运行两个独立审查代理：Standards 1 项非阻塞建议（独立初始化签名缺少说明，已补中文解释），Spec 源码 0 项发现。后续补充文档与构建结果由主代理核对；用户文件不纳入提交。

## 下一项就绪任务提示词

执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #15（Swift 6 迁移：修复 SwiftUI 网络服务的可发送性边界）。先读取 #15、父规格 #9、#11 及已有 Swift6 诊断和修复文档。保持 codex/swift6-migration、用户文件、锁定依赖、Flutter 关闭和 Swift 5 模式。只实施 B1，以真实诊断确定隔离与传值安全，不使用无依据的兼容标记。复用已有基线，先改源码并针对性编译；稳定后按 Issue 验收执行严格并发构建和完整脚本，记录完整命令、设置、退出码、日志与既有日志测试失败。附中文前后示例、安全边界，完成双轴审查和独立提交，设备验证由开发者执行。

## 最终执行记录

工具链：Xcode 26.3（17C529）。完整日志与结构化记录保存在忽略目录 Derived/swift6-d2/，修改前基线保存在 Derived/swift6-d2-before/。最终 RxStudy 两配置已在取消令牌最后修改后复验。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0；日志 `Derived/swift6-d2/RxStudy-Debug-showBuildSettings.log`。

生效设置：

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-d2/RxStudy-Debug-build.log`。

BUILD SUCCEEDED；本轮所有权相关文件并发诊断 0 条。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0；日志 `Derived/swift6-d2/RxStudy-Release-showBuildSettings.log`。

生效设置：

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-d2/RxStudy-Release-build.log`。

BUILD SUCCEEDED；本轮所有权相关文件并发诊断 0 条。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0；日志 `Derived/swift6-d2/SwiftUIStudy-Debug-showBuildSettings.log`。

生效设置：

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-d2/SwiftUIStudy-Debug-build.log`。

BUILD SUCCEEDED；本轮所有权相关文件并发诊断 0 条。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0；日志 `Derived/swift6-d2/SwiftUIStudy-Release-showBuildSettings.log`。

生效设置：

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-d2/SwiftUIStudy-Release-build.log`。

BUILD SUCCEEDED；本轮所有权相关文件并发诊断 0 条。

```sh
python3 scripts/tests/test-account-session.py
```

退出码 0；日志 `Derived/swift6-d2/test-account-session.log`。

```sh
python3 scripts/tests/test-async-request-integration.py
```

退出码 0；日志 `Derived/swift6-d2/test-async-request-integration.log`。

```sh
python3 scripts/tests/test-async-request.py
```

退出码 0；日志 `Derived/swift6-d2/test-async-request.log`。

```sh
python3 scripts/tests/test-category-source.py
```

退出码 0；日志 `Derived/swift6-d2/test-category-source.log`。

```sh
python3 scripts/tests/test-flutter-bridge.py
```

退出码 0；日志 `Derived/swift6-d2/test-flutter-bridge.log`。

```sh
python3 scripts/tests/test-pagination.py
```

退出码 0；日志 `Derived/swift6-d2/test-pagination.log`。

```sh
python3 scripts/tests/test-rxstudy-logging.py
```

退出码 1；日志 `Derived/swift6-d2/test-rxstudy-logging.log`。

```sh
python3 scripts/tests/test-upgrade-tuist.py
```

退出码 0；日志 `Derived/swift6-d2/test-upgrade-tuist.log`。

```sh
python3 scripts/tests/test_switch_flutter.py
```

退出码 0；日志 `Derived/swift6-d2/test_switch_flutter.log`。

完整脚本共 9 项：8 项退出 0；日志测试退出 1，仍在默认 legacy 断言失败，与修改前基线一致。没有将该失败计为通过。其他任务的依赖、网络插件、日志、路由与 UI 并发告警保留；全部规格的 Swift 6 迁移尚未完成。
