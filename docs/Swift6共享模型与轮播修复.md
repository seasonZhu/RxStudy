# Swift 6 共享模型与轮播并发边界（Issue #13）

## 范围与选择

基点 cf85a1ac216e82915bb75e493b340b3e1a2fea87，分支 codex/swift6-migration。保留用户 .DS_Store 与未跟踪迁移计划文件。Podfile.lock 与 Pods/Manifest.lock SHA-256 均为 6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff，Flutter 标记不存在。

Api 仅包含静态 String 常量，AccountCookie.header 只转换输入字符串。Banner、HotKey 为值模型，BaseModel 与 Page 是泛型 Codable 容器，WebLoadInfo 仅描述接口。#11 与本轮未观察到这些共享声明的并发诊断，保持原声明。Codable 本身不保证 Sendable，泛型内容与协议的调用端跨隔离问题仍需 #15 等任务依据真实诊断处理。

## 学习与诊断对照

修改前 `class ACarouselViewModel: ObservableObject` 未限定状态所有权，asyncAfter 捕获 self 报 non-Sendable、sending self，手势 onChanged 报 MainActor 调用与非 Sendable 结果跨域。修改后 `@MainActor class ACarouselViewModel` 将 Binding、Published 状态、拖拽、计时和延迟主队列回调统一归于 UI Actor。ACarousel 显式声明 MainActor，初始化与渲染遵循相同边界。没有增加调度跳转或更改轮播算法。

集合与 KeyPath 留在同一 Actor 内，无须强制 Data/ID/Element Sendable。MainActor 类型可安全传递其引用，状态访问仍受 Actor 检查。主队列 asyncAfter 是编译器识别的隔离闭包入口，不能将这个结论推广到任意 Combine/Rx 回调。

组件库 views 原有两个 MainActor 初始化调用诊断。仅隔离 views 会产生协议遵循跨域诊断，因此采用 `ACarousel_LibraryContent: @MainActor LibraryContentProvider`，让编译器检查该遵循的使用域。它是隔离遵循，使用本机 Xcode 26 工具链，Swift 5 语言模式仍保持。未使用 @unchecked Sendable、@preconcurrency 或 nonisolated(unsafe)。

#11 与 A1 日志中轮播的延迟捕获、手势与预览初始化告警在最终四项日志中均未再出现。共享业务并发诊断为零。现有强制转换与生成文件 SwiftLint 告警保留。其他任务的网络服务、页面/HUD、账号全局状态、日志、路由、本地模块和 Pods 并发诊断仍保留，增量发射数量不能作为全部消除的依据。

## 四项构建

日志保存在忽略目录 Derived/swift6-a2，结构化结果见 results.json。Debug 首轮预览遵循告警修复后重跑，下面日志为最终结果。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0，日志 `Derived/swift6-a2/RxStudy-Debug-showBuildSettings.log`。

生效设置

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0，日志 `Derived/swift6-a2/RxStudy-Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0，日志 `Derived/swift6-a2/RxStudy-Release-showBuildSettings.log`。

生效设置

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0，日志 `Derived/swift6-a2/RxStudy-Release-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0，日志 `Derived/swift6-a2/SwiftUIStudy-Debug-showBuildSettings.log`。

生效设置

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0，日志 `Derived/swift6-a2/SwiftUIStudy-Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0，日志 `Derived/swift6-a2/SwiftUIStudy-Release-showBuildSettings.log`。

生效设置

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0，日志 `Derived/swift6-a2/SwiftUIStudy-Release-build.log`。

## 自动化与设备验证

- `python3 scripts/tests/test-account-session.py` 退出码 0，日志 `Derived/swift6-a2/test-account-session.log`。
- `python3 scripts/tests/test-async-request-integration.py` 退出码 0，日志 `Derived/swift6-a2/test-async-request-integration.log`。
- `python3 scripts/tests/test-async-request.py` 退出码 0，日志 `Derived/swift6-a2/test-async-request.log`。
- `python3 scripts/tests/test-category-source.py` 退出码 0，日志 `Derived/swift6-a2/test-category-source.log`。
- `python3 scripts/tests/test-flutter-bridge.py` 退出码 0，日志 `Derived/swift6-a2/test-flutter-bridge.log`。
- `python3 scripts/tests/test-pagination.py` 退出码 0，日志 `Derived/swift6-a2/test-pagination.log`。
- `python3 scripts/tests/test-rxstudy-logging.py` 退出码 1，日志 `Derived/swift6-a2/test-rxstudy-logging.log`。
- `python3 scripts/tests/test-upgrade-tuist.py` 退出码 0，日志 `Derived/swift6-a2/test-upgrade-tuist.log`。
- `python3 scripts/tests/test_switch_flutter.py` 退出码 0，日志 `Derived/swift6-a2/test_switch_flutter.log`。

日志测试仍因默认 legacy 断言与 HEAD modern 配置不匹配退出 1，与 #12 记录一致。其余八项脚本通过。相关账号、异步请求、分页脚本覆盖既有接缝，轮播没有对应行为测试入口，本轮通过编译器隔离检查验证，未新增镜像测试。

设备验证待开发者执行，覆盖两个 App 的轮播拖拽、自动滚动、循环边界、前后台切换、重复进入与外部索引绑定。编译和脚本结果不代表设备交互已验证。

## 下一项新对话提示词

执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #14（Swift 6 迁移：修复账号与全局状态的并发访问）。先读取 #14、父规格 #9、#11、#12、#13 与 docs/Swift6严格并发诊断.md、docs/Swift6后续任务草案.md、docs/Swift6共享资源修复.md、docs/Swift6共享模型与轮播修复.md。保持 codex/swift6-migration 分支、用户未提交文件、锁定依赖、Flutter 关闭与 Swift 5 模式。仅实施已发布 D2，依据真实诊断明确账号与全局状态所有权并同步必要调用端，不提前实施其他任务或切换语言模式，不用无安全依据的兼容标记。共享变更执行两个 Target Debug/Release 的 workspace 严格并发构建，使用 generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete，记录设置、完整命令、退出码和日志。运行相关与完整现有脚本测试，区分日志 legacy/modern 既有失败。附中文学习说明、诊断对照、前后示例与安全边界，按 implement 审查并独立提交，设备验证由开发者执行，完成后提供下一项就绪任务提示词。

## 技能审查

以 cf85a1ac216e82915bb75e493b340b3e1a2fea87 为固定基点，按 code-review 技能由两个独立审查代理分别检查 Standards 与 Spec。Standards 0 项发现，Spec 源码 0 项发现。提交前已核实文档包含四项构建、日志测试既有失败、模型及 AccountCookie 检查结论与设备交接。git diff --check 通过。
