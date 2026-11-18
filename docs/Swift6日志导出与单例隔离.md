# Swift 6 日志导出与单例隔离（Issue #19 / D1）

基点 afc64d5115ab1b6b7a75435ad4091c3f556b1ef7，分支 codex/swift6-migration。保留用户 .DS_Store、工程文件及未跟踪迁移计划；不安装或升级依赖、不启用 Flutter、不切语言模式、不运行模拟器。构建验证当前工作区，不能等同于干净检出。

## 诊断与中文前后示例

#11 严格诊断与 #18 遗留记录中的日志问题，本轮通过触碰六个日志源码触发重新编译复现，完整日志 Derived/swift6-issue19/source-baseline.log，退出 0、BUILD SUCCEEDED。首次修复 targeted.log 同样退出 0。

前：`static var logcat: ((String) -> Void)?`。后：`OSAllocatedUnfairLock<(@Sendable (String) -> Void)?>` 保存回调，计算属性在锁内读写，取出快照后在调用者原队列同步调用。锁不覆盖外部回调，允许重入；不引入 Task，不更改打印顺序。Sendable 要求注册方自行保护捕获状态，不意味着回调在主线程。当前没有注册调用端。

前：`exportLogs(completion: @escaping (Result<URL, Error>) -> Void)`。后：`@escaping @MainActor @Sendable (Result<URL, Error>) -> Void`。原先所有成功/失败分支已异步投递主队列，现在把既有保证写入类型；URL、Error 结果仍原样交付。归档闭包也要求 Sendable，测试及未来注入方不得捕获无保护的可变对象。

前：在后台闭包捕获 Moya `RequestType`、`Response` 和 `MoyaError`。后：RequestType 在原回调域转换成锁定 Alamofire 已声明可发送的 DataRequest；响应提取 URLRequest、Data、状态码、字符串头和错误描述后才进入原串行队列。错误仍以 String(describing:) 的同一文本打印，返回与计时清理条件保留，不改弃用插件的单 startTime 计时策略。第三方 Moya 类型没有被追认 Sendable，也未使用 @preconcurrency 掩盖诊断。

NetworkDebuggingPlugin.Options 和 LogOptions 仅含不可变选项及 Int，显式遵循 Sendable。realParameters 仅在原回调域同步格式化，返回本地 `[String: Any]?`，避免锁定 Alamofire.Parameters 的 Sendable 类型别名要求；不将任意参数跨队列传送，不修改既有响应选项位值。

## 所有权、调度及兼容边界

| 对象 | 所有权及同步 | 调度语义及边界 |
| --- | --- | --- |
| ModernLogging | final、@unchecked Sendable；fileLogger 仅由 configurationLock 发布和读取，初始化参数不可变、压缩闭包 Sendable | 原 exportQueue 等待 flush，调用框架 roll，完成后再入 exportQueue 复制与压缩，结果主队列异步回调 |
| 私有 ExportLogger | @unchecked Sendable，仅封装配置完成后不再修改的 DDFileLogger 引用，不暴露给业务调用端 | 锁定 CocoaLumberjack 3.9.0 的 rollLogFileWithCompletionBlock 自行入全局日志队列及 loggerQueue，再由 completionQueue 完成；快照仍在 loggerQueue.sync 内复制，压缩仍在导出队列 |
| ModernNetworkLogger | final、@unchecked Sendable；level/filterPredicate 由配置锁保护，startedAt/loggedStarts 仅原串行 queue 使用 | 通知先取 DataRequest 再异步入原队列；stop 清理仍异步，start/stop 的观察者语义不变 |
| NetworkActivityLogger | final、@unchecked Sendable；配置加锁 | 先从 Notification 提取 DataRequest，不捕获非 Sendable Notification；网络读取、打印仍在原队列 |
| NetworkRequestLoggerPlugin | final、@unchecked Sendable；level 由锁保护，startTime 仅原 queue 访问 | 请求和响应值提取发生在回调域；打印、计时及清理仍在原队列 |
| LogUtils | Sendable 回调由 OSAllocatedUnfairLock 保护 | 原线程同步快照调用，随后原顺序写 DDLog |

四个日志类及私有 ExportLogger 的 unchecked 声明是人工检查后的兼容边界，不是任意成员自动线程安全。level 可并发读写，但一次日志过程中配置变更仍可能影响后续读取，沿用原行为。filterPredicate 设置后调用者不得再修改其对象或无锁捕获状态；block 谓词捕获必须能在日志队列安全使用；这是 Foundation 任意谓词的边界。对象观察者的并发 start/stop 未新增生命周期保证。

移除条件：第三方提供满足实际访问方式的 Sendable 声明时移除 ExportLogger 桥；自有对象全部改为编译器可验证的锁内状态或 Actor 所有权时移除 unchecked。不能直接把日志类整体改 MainActor，否则会改变后台日志时序；不能给 DDFileLogger/Moya 类型添加全局 retroactive Sendable。未增加 nonisolated(unsafe) 或 @preconcurrency。

## 既有脚本与配置差异

历史提交 61e84ca53（继续优化日志打印）已明确把 LoggingConfiguration 从 legacy 改为 modern，早于本轮迁移。文档和脚本仍要求 legacy 是陈旧契约。D1 保留应用配置不变，脚本仍断言当前默认 modern；测试副本改为匹配明确的配置声明，分别生成 legacy、modern 脱敏关、modern 脱敏开，而不是只替换 `= .legacy` 导致 legacy 分支根本未生成。没有删掉默认值断言，也没有通过回退应用配置规避失败。

沿用已授权的真实日志/归档测试接缝，补充同时重复导出两次、独立 URL、可解压及主线程完成检查；测试消费端显式 MainActor，避免 Sendable completion 捕获测试局部状态的警告。现有成功、未启用、未初始化、无日志、压缩失败测试保持。脚本用 macOS 真实 CocoaPods 依赖临时副本，不代表 iOS 设备运行验证。

## 开发者设备验证步骤

1. 保持当前 Modern，Debug 启动并产生成功及失败请求，触发导出，确认界面不阻塞、成功仅回调一次且位于主线程；解压 ZIP，检查最近 marker、文件目录及正文。Release 核对只保留预期摘要，不启用 Debug 控制台正文。
2. 连续及同时提交两次导出，记录各次回调、URL 和完成顺序；确认两个唯一 ZIP 均可解压，不覆盖、无临时快照残留。原 API 不承诺不同调用之间严格按提交顺序完成；单次 flush→roll→snapshot→zip→completion 顺序必须保持。
3. 在开发测试入口分别使用未 start 实例、空日志目录、注入返回 false 的压缩闭包，核对未初始化、无日志及压缩失败结果，失败仅回调一次，均异步在主线程；失败归档不残留。临时编译 legacy 验证 inactiveMode，完成后恢复 modern；不在本次提交中修改配置。
4. 导出期间并发请求、轮转及反复进出页面，检查主线程检查、崩溃、重复日志和释放行为。legacy 的 DEBUG/Release 输出、过滤谓词及停止再启动行为按原约定核对。

以上设备步骤由开发者执行，尚未执行。没有新增日志导出 UI。

## 验证证据

工具链 Xcode 26.3（17C529）。Podfile.lock 与 Pods/Manifest.lock SHA-256 均为 6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff；.flutter-enabled 不存在。实际应用设置 SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete、CODE_SIGNING_ALLOWED=NO。

完整日志保留于忽略目录 Derived/swift6-issue19；matrix.json/tests.json 保存命令、退出码、路径。独立 DerivedData 复用 Derived/swift6-issue18/build。本轮初次日志脚本 logging-targeted.log 因测试文件在 swiftc 编译期间被编辑而退出 1（input file was modified during the build），保留原日志，不算通过；后续以稳定文件重跑。

路由、UniMP、ResponseCachePlugin 诊断归其他任务；锁定 Pods、弃用、SwiftLint、重复链接库与 AppIntents 等提示单列，不声称全工程无警告。SwiftUIStudy Debug 回查不等于最终双 Target Swift 6 四项验收。

## 双轴审查

按 code-review 技能，以固定基点 afc64d5115ab1b6b7a75435ad4091c3f556b1ef7 对本轮指定工作区差异进行两个独立代理审查（提交前，因此不是空的 HEAD 提交差异）。Standards 对照 AGENTS.md、docs/代码编写规范.md 与完整气味基线：0 项；Spec 对照 #19、#9 和用户 D1 边界：0 项。两轴均要求准确说明谓词捕获的调用方义务，已补入。git diff --check 通过。

额外运行 check-shared-sources.py 未提供其要求的 CocoaPods/Tuist 双工作树参数，退出 1 并输出用法；此工具用于跨构建分支同步，不适用于本轮单工作区检查，不计通过。共享影响采用实际 SwiftUIStudy Debug 构建回查。当前日志模块仍属于 RxStudy，未迁入 SwiftUIStudy。

### 最终构建与脚本命令

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Debug -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue19/RxStudy-Debug-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Debug build
```

退出码 0；完整日志 `Derived/swift6-issue19/RxStudy-Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Release -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue19/RxStudy-Release-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration Release build
```

退出码 0；完整日志 `Derived/swift6-issue19/RxStudy-Release-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme SwiftUIStudy -configuration Debug -showBuildSettings
```

退出码 0；完整日志 `Derived/swift6-issue19/SwiftUIStudy-Debug-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme SwiftUIStudy -configuration Debug build
```

退出码 0；完整日志 `Derived/swift6-issue19/SwiftUIStudy-Debug-build.log`。

```sh
python3 scripts/tests/test-account-session.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-account-session-final.log`。

```sh
python3 scripts/tests/test-async-request-integration.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-async-request-integration-final.log`。

```sh
python3 scripts/tests/test-async-request.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-async-request-final.log`。

```sh
python3 scripts/tests/test-category-source.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-category-source-final.log`。

```sh
python3 scripts/tests/test-flutter-bridge.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-flutter-bridge-final.log`。

```sh
python3 scripts/tests/test-pagination.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-pagination-final.log`。

```sh
python3 scripts/tests/test-rxstudy-logging.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-rxstudy-logging-final.log`。

```sh
python3 scripts/tests/test-upgrade-tuist.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test-upgrade-tuist-final.log`。

```sh
python3 scripts/tests/test_switch_flutter.py
```

退出码 0；完整日志 `Derived/swift6-issue19/test_switch_flutter-final.log`。

源码基线和 targeted 的命令与上述 RxStudy Debug build 完全相同，日志分别为 source-baseline.log、targeted.log；都退出 0。定向日志脚本两次命令均为 `python3 scripts/tests/test-rxstudy-logging.py`，logging-targeted.log 退出 1（编译期间文件修改），logging-targeted2.log 退出 0。共享辅助脚本命令为 `python3 scripts/check-shared-sources.py`，退出 1（缺少双工作树参数），不作为验收项。

最终三项构建退出 0，均包含 BUILD SUCCEEDED；全部设置查询退出 0。完整运行 9 项现有脚本全部退出 0。日志覆盖 legacy Debug/Release 各 14 项，Modern 脱敏开/关 Debug 各 60 项、Release 各 58 项。未遇到未解除的构建环境阻塞；脚本仍有旧导出 zipURL 未使用警告，非 D1 并发诊断。

逐文件源码重编译与 Release 诊断对照：LogUtils 全局状态、三个日志单例、completion、DDFileLogger/self、Notification、Moya request/result 捕获，以及日志选项静态值、Parameters 返回值诊断均不再出现。最终增量日志只用于复验，不能单独用零诊断证明修复。其他告警清单保存在 *-build-warnings.txt；不更改已有观察者 stopLogging 的 SwiftLint 提示。

下一项见 [Swift6-Issue20新对话提示词.md](Swift6-Issue20新对话提示词.md)。
