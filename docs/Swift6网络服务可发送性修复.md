# Swift 6 网络服务可发送性修复（Issue #15 / B1）

## 范围与基点

基点 `b57ff6d781f4a177d190c502697c4b4ee7f19fc6`，分支 `codex/swift6-migration`。复用 #10/#11 和 A1/A2/D2 基线，不重新建立基线。仅修复 SwiftUI 网络服务、返回值和取消桥接边界。保持 Swift 5（命令指定 5.9）、Flutter 关闭，未升级依赖。Podfile.lock 与 Pods/Manifest.lock SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`。

用户 `.DS_Store`、未跟踪迁移计划和本轮开始时已存在的工程文件变更均不纳入提交。验证使用当前工作区，工程文件另有改动，因此结果仅证明本工作区；不将其误称为干净检出构建。

## 实际诊断与选择

#11 记录六个无状态服务 shared 非 Sendable 告警。将 APIService、六个服务及 CategorySource 统一到 MainActor，provider 的创建和请求入口由同一 Actor 串行访问。HotKeyViewModel 的依赖默认参数初始化需 MainActor，因此只标记其初始化方法。

针对性构建实际发现：

- CategorySource 的非隔离要求与服务 MainActor 见证冲突：协议声明 MainActor。
- 返回 Page<InfoModel>、Page<MyHistoryCoin>、Banner 等跨 Actor 不可发送：纯值模型采用编译器检查的 Sendable，Page 仅在 Content: Sendable 时条件遵循。
- continuation.resume(with: result) 报 sending result risks causing data races：不跨边界传递第三方 Response，改为回调中使用原 Response.map 解码，传递 Sendable 的结果。
- 尝试整体隔离 AccountAPIService 会使 TargetType.headers 同步读取 cookieHeaderValue 报错；撤回该尝试。其 shared 既有告警属页面与账号状态所有权边界，留 #16 明确同步 Cookie 快照，未添加不安全兼容标记。

MainActor 约束服务状态访问，不表示网络 IO 在主线程同步执行。Moya 回调仍可能在任意线程执行；解码只访问该回调的 Response 和局部模型，不访问服务/UI 状态。

## 中文前后示例

修改前：

```swift
class HomeAPIService: APIService { /* provider 和 shared 无隔离 */ }
private final class AsyncRequestState: @unchecked Sendable {
    // continuation 的返回值是第三方 Response
}
func requestDecoded<T: Codable>(/* ... */) async throws -> T
```

修改后（简化展示）：

```swift
@MainActor
class HomeAPIService: APIService { /* provider 由主 Actor 访问 */ }
private final class AsyncRequestState<Value: Sendable>: @unchecked Sendable {
    // 锁保护状态，只将可发送的模型交给 continuation
}
@MainActor
func requestDecoded<T: Codable & Sendable>(/* ... */) async throws -> T
extension Page: Sendable where Content: Sendable {}
```

模型采用结构体，仅持有 String、Int、Bool、数组和同样可发送的结构体。可变字段仍可在各自值副本中修改；Sendable 不允许多个任务无保护地修改同一变量。没有把 provider、TargetType 或账号状态伪装为 Sendable，也没有给共享 Codable 泛型强加无关限制。

## 取消与错误安全边界

保留既有 `AsyncRequestState @unchecked Sendable`：所有 status、continuation、cancellable 的读写均由 NSLock 保护。完成或取消先锁定并摘除状态，解锁后恢复 continuation/取消请求，避免同步重入死锁。取消先于句柄安装时补做 cancel；完成与取消竞态仅一个取得 pending。此标记的安全依据是锁，不是主线程假设；未来将状态替换为编译器可检查的同步容器时可移除。此次未新增兼容标记。

回调先用原始 Response.map 和 getData 解码，保留业务错误及原始解析错误；随后才跨 continuation 传模型。任务返回前和 catch 中仍检查取消，取消优先于已经到达的失败结果。取消后回调可能仍进行一次局部解码，但不会再次恢复 continuation。

集成测试原先在 async main 同步等待 started，主 Actor 请求无法启动。将信号等待移入 detached 任务并 await 结果，保留真实 URLSession.stopLoading 和 CancellationError 断言。沿用现有公开行为接缝，不添加镜像测试。未执行模拟器或设备；开发者需验证成功、解析/业务/网络失败、快速取消与重复进入。

## 验证证据

完整命令、退出码和日志见下方自动汇总。构建使用现有 workspace 与 generic iOS、关闭签名，四项回查包含共享值模型影响。既有日志测试仍在 legacy 默认值断言失败，先前 D2 文档已记录同一失败，未改动日志系统来迎合测试。

工具链：Xcode 26.3（17C529）。最终验证于 2026-11-18 执行。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志 `Derived/swift6-issue15/SwiftUIStudy-Debug-settings.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志 `Derived/swift6-issue15/SwiftUIStudy-Debug-verified.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志 `Derived/swift6-issue15/SwiftUIStudy-Release-settings.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志 `Derived/swift6-issue15/SwiftUIStudy-Release-verified.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志 `Derived/swift6-issue15/RxStudy-Debug-settings.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志 `Derived/swift6-issue15/RxStudy-Debug-verified.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志 `Derived/swift6-issue15/RxStudy-Release-settings.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志 `Derived/swift6-issue15/RxStudy-Release-verified.log`。

```text
    CODE_SIGNING_ALLOWED = NO
    SWIFT_STRICT_CONCURRENCY = complete
    SWIFT_VERSION = 5.9
```

```sh
python3 scripts/tests/test-account-session.py
```

退出码：0；日志 `Derived/swift6-issue15/test-account-session-verified.log`。

```sh
python3 scripts/tests/test-async-request-integration.py
```

退出码：0；日志 `Derived/swift6-issue15/test-async-request-integration-verified.log`。

```sh
python3 scripts/tests/test-async-request.py
```

退出码：0；日志 `Derived/swift6-issue15/test-async-request-verified.log`。

```sh
python3 scripts/tests/test-category-source.py
```

退出码：0；日志 `Derived/swift6-issue15/test-category-source-verified.log`。

```sh
python3 scripts/tests/test-flutter-bridge.py
```

退出码：0；日志 `Derived/swift6-issue15/test-flutter-bridge-verified.log`。

```sh
python3 scripts/tests/test-pagination.py
```

退出码：0；日志 `Derived/swift6-issue15/test-pagination-verified.log`。

```sh
python3 scripts/tests/test-rxstudy-logging.py
```

退出码：1；日志 `Derived/swift6-issue15/test-rxstudy-logging-verified.log`。

```sh
python3 scripts/tests/test-upgrade-tuist.py
```

退出码：0；日志 `Derived/swift6-issue15/test-upgrade-tuist-verified.log`。

```sh
python3 scripts/tests/test_switch_flutter.py
```

退出码：0；日志 `Derived/swift6-issue15/test_switch_flutter-verified.log`。

## 诊断对照与剩余边界

六个无状态服务 shared 告警、分类见证隔离告警、本轮返回值不可发送与 continuation result 发送告警在最终日志中均未再出现。构建缓存和优化会影响告警发射，未用总数差值声称清除所有迁移诊断。以下为本轮 SwiftUIStudy 源码剩余诊断（按原文去重）；页面、账号与 HUD 留 #16，第三方依赖告警留既有依赖任务。

```text
SwiftUIStudy/Components/ShareSheet.swift:41:46: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context
SwiftUIStudy/Components/ShareSheet.swift:42:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context
SwiftUIStudy/Components/ShareSheet.swift:42:34: warning: call to main actor-isolated instance method 'open(_:options:completionHandler:)' in a synchronous nonisolated context
SwiftUIStudy/Components/WebUIController.swift:150:14: warning: instance method 'webView(_:decidePolicyFor:decisionHandler:)' nearly matches optional requirement 'webView(_:decidePolicyFor:decisionHandler:)' of protocol 'WKNavigationDelegate'
SwiftUIStudy/Components/WebUIController.swift:196:14: warning: instance method 'webView(_:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)' nearly matches optional requirement 'webView(_:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)' of protocol 'WKUIDelegate'
SwiftUIStudy/Components/WebUIController.swift:200:14: warning: instance method 'webView(_:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)' nearly matches optional requirement 'webView(_:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)' of protocol 'WKUIDelegate'
SwiftUIStudy/Components/WebUIController.swift:204:14: warning: instance method 'webView(_:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)' nearly matches optional requirement 'webView(_:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)' of protocol 'WKUIDelegate'
SwiftUIStudy/Features/Project/ProjectView.swift:91:33: warning: sending 'self.viewModel' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:138:21: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:138:35: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:149:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:149:35: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:160:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:160:27: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:45:17: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:52:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:68:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:68:27: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:74:31: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in an isolated closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:81:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:81:35: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Project/ProjectViewModel.swift:90:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberView.swift:91:33: warning: sending 'self.viewModel' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:136:21: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:136:35: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:147:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:147:35: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:158:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:158:27: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:45:17: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:51:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:67:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:67:36: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:72:31: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in an isolated closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:79:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:79:35: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:88:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Search/HotKeyView.swift:41:17: warning: 'init(destination:isActive:label:)' was deprecated in iOS 16.0: use NavigationLink(value:label:), or navigationDestination(isPresented:destination:), inside a NavigationStack or NavigationSplitView
SwiftUIStudy/Features/Search/HotKeyViewModel.swift:39:23: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Tree/TreeView.swift:142:37: warning: sending 'self.viewModel' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Tree/TreeViewModel.swift:28:17: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Tree/TreeViewModel.swift:33:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Tree/TreeViewModel.swift:49:17: warning: capture of 'self' with non-Sendable type 'TreeViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Tree/TreeViewModel.swift:49:27: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Tree/TreeViewModel.swift:54:17: warning: capture of 'self' with non-Sendable type 'TreeViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode
SwiftUIStudy/Features/Tree/TreeViewModel.swift:54:35: warning: sending 'self' risks causing data races; this is an error in the Swift 6 language mode
SwiftUIStudy/Network/AccountAPIService.swift:72:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'AccountAPIService' may have shared mutable state; this is an error in the Swift 6 language mode
```

## 双轴审查

固定基点 `b57ff6d781f4a177d190c502697c4b4ee7f19fc6`；审查本任务工作区差异，排除用户工程文件和用户文件。两名独立审查代理按 code-review 技能并行审查。

### Standards

0 项发现。符合精准修改、中文说明与现有风格；锁内摘除状态、锁外取消和恢复 continuation，未发现需处理的规范违反或代码气味。

### Spec

0 项源码问题。使用原始 Response.map 保留错误语义，只跨域传递 Sendable 模型；真实取消测试保留底层取消断言。最终命令与结果已补齐。

两轴分别为 0 项；设备验证待开发者执行，日志 legacy 断言失败不计通过。
