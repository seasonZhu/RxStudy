# Swift 6 Rx 网络与 HUD 隔离（Issue #17 / C1）

基点 `5201fb191`，分支 `codex/swift6-migration`。先读取 #17、#9、#11、#14 及既有诊断和修复文档；开发者明确授权忽略 #14 的开放状态，复用现有修复基线。只实施 C1，不切换 Swift 6 语言模式，不运行模拟器。用户 `.DS_Store`、`RxStudy.xcodeproj/project.pbxproj`、未跟踪迁移计划均不纳入提交。构建针对当前工作区，不代表干净检出。

## 实际诊断与修改

#11 记录 Provider.swift 的 Provider/插件全局 let 非 Sendable 共享状态；NetworkActivityManager 的活动数、筛选闭包和开始/结束闭包为非隔离静态可变状态；CustomNetworkActivityPlugin 将非 Sendable 函数转换为主 Actor 队列任务；SVProgressHUD 遵循非隔离 HUD 协议跨越主 Actor 边界。

修改前：`let homeProvider = MoyaProvider<HomeService>(plugins: plugins)`。
修改后：`@MainActor let homeProvider = LoadingProvider<HomeService>(plugins: plugins)`。
全局入口的初始化和取得由主 Actor 管理。实际诊断要求 Home/HotKey/SearchResult、CoinRank/MyCoin/Tool、Tabs/SingleTabList、通用 List 和示例请求 ViewModel 的必要调用端隔离，沿用 #14 的具体类型隔离协议遵循方式，不隔离整个 BaseViewModel。Repository 请求协议也显式隔离；空父协议的隔离不会自动覆盖子协议扩展方法，HotKeyRequest 因此单独标注。Combine 示例的销毁使用 isolated deinit，保留取消订阅行为。

修改前：`protocol HUD`；修改后：`@MainActor protocol HUD`。HUD 是 UI 能力，调用必须位于主 Actor；不是给 UI 对象添加 Sendable。保留旧加载插件示例，Custom 插件的 UI 闭包明确 `@MainActor @Sendable`，计数防止下溢；RequestLoadingPlugin 的结束筛选与开始一致。这两个示例未安装到实际 plugins 集合，不可与 LoadingProvider 同时启用；它们依赖成对的 Moya 回调，不承担实际请求的生命周期保证。

## 成功、失败和取消的收尾

锁定的 Moya 15.0.0 在 requestNormal 中先检查取消，可能经 cancelCompletion 直接调用 didReceive，而未调用 willSend。请求构造失败也可能不进入 willSend。原来只对 began/ended 加减，无法区别同一路径并行请求；两端重新读取网络可达状态也会让开始与结束的判断失配。

实际 Provider 现在在 request 入口创建 UUID 加载令牌，完成和取消都调用 `NetworkActivityManager.end(token)`。OSAllocatedUnfairLock 保护活动 Set<UUID> 与待展示错误文本，只有成功移除令牌才产生收尾；因此同步完成后取消、重复取消、取消后的迟到完成均不误减其他请求。首次令牌加入显示，最后一个移除关闭。开始/结束的主队列任务在同一把锁内提交，保持提交顺序；锁内只更新令牌和提交任务，不执行 UI 或业务回调。取消仍传递给原 Moya Cancellable，调用方的结果和 callbackQueue 保留。

前：`activityCount -= 1` / 两端读取 `networkIsReachable`。
后：`guard active.remove(token) != nil else { return }`。

原有 banner、置顶、未读计数及 showLoading=false 筛选保留，筛选在请求入口只执行一次；mockProvider 保持原有无加载行为。加载生命周期不再读取瞬时网络可达性：离线请求也按其真实开始和结束收尾，缓存响应策略不变，可能出现短暂加载。这避免请求期间断网造成 HUD 残留。

业务响应仍由 ResponseInterceptorPlugin 将非空 errorMsg 转换为原有 statusCode 失败；LoadingProvider 完成入口只提取 String，与令牌一同交给管理器。并行请求的错误暂存，最后一个令牌结束时在同一主队列任务中先关闭加载、再展示文本；多个错误保留最后收到的一个，不增加提示队列。无加载令牌的业务失败也遵守当前活动结束后展示的顺序。没有更改网络错误类型、请求超时或账号快照。

## Actor / Sendable 安全边界

活动管理器锁内不保存业务模型，只保存值类型令牌与 String。

本轮未新增 @unchecked Sendable、@preconcurrency、nonisolated(unsafe)。锁内共享的是 UUID 值，不把 TargetType、Response、Relay 或 Provider 发送进 UI 任务；UI 任务只调用静态 HUD 或捕获 String。主 Actor 全局入口不意味着第三方 Moya/Rx 对象自动成为 Sendable，也不意味着 Rx 订阅执行线程自动受 Actor 约束。LoadingProvider 覆写的 request 继续遵守非隔离 Moya 协议，网络调度仍由 Moya/Alamofire 管理；不要把这些实例从后台全局状态取出、在 detached Task 之间传递，或据此认为所有 Rx 回调已具备隔离保证。Rx/Combine 回调与 UIKit 的整体整改属于 #18。

NetworkDebuggingPlugin.Options/LogOptions、日志单例等既有日志诊断归 #19；ResponseCachePlugin 的 UserDefaults 存储以及路由、主题、刷新 PreferenceKey、UIKit 协议与其他可发送性告警继续单列，不用增量告警总数证明工程安全。Combine 示例 Future.value 跨主 Actor 的诊断属于 #18 回调边界，C1 只隔离取得 Provider 的入口并保留其证据，不提前迁移 Future 桥接。

## 验证范围与开发者设备步骤

使用 tdd skill 的行为接缝原则，复用已授权的真实请求集成测试入口，没有新增镜像实现。审查发现并行错误提示问题后，先新增回归断言，确认 red（退出 1，断言“并行请求中先失败的提示必须在最后一个请求收尾后展示”失败），再修复并确认 green（退出 0）；日志 parallel-red.log / parallel-green.log 均保留。新增断言直接调用生产 LoadingProvider/NetworkActivityManager；仅将 SVProgressHUD 模块替换为主 Actor 事件记录器，验证并行、同步成功、发送前失败、发送前取消、重复取消、禁用加载、业务错误提示顺序。保留真实 URLSession/URLProtocol 取消检查，实际路径也使用 LoadingProvider。不能由 macOS 事件记录器推断 iOS HUD 的视觉表现。首次测试编译使用了错误的 Moya 闭包类型别名，已按锁定源码修正，失败日志保留。

开发者设备验证：

1. 同时发出两个显示加载的请求，先完成或取消其中一个，确认另一个仍在请求，最终 HUD 关闭。
2. 检查普通成功、HTTP/业务失败、断网和恢复；请求期间切换网络，确认无残留遮罩。
3. 快速进入/退出请求页面并重复进入，覆盖发送前取消、请求中取消及完成后释放订阅；确认交互恢复。
4. 检查 banner、置顶、未读计数及 showLoading=false 不显示加载；mock 行为保持。
5. 触发业务 errorMsg，确认错误文本在加载关闭后可见；再测试并行成功/失败、前后台切换及其他页面 HUD 交互。
6. 检查账号、积分、收藏、项目、公众号、体系和示例页的请求及取消，关注主线程警告和订阅销毁。

编译、脚本测试与设备验证分别记录，设备验证尚未执行。

## 执行记录

完整命令、退出码和日志见下方最终记录。初步增量源码编译记录在 Derived/swift6-issue17/targeted*.log；其中 targeted、targeted2、targeted3 均退出 0，后续根据真实调用端告警补齐协议隔离并复验。初始集成脚本退出 1（类型别名错误），integration-targeted2 退出 0。最终以最终矩阵与脚本记录为准。

Podfile.lock 与 Pods/Manifest.lock SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`。Flutter 开关文件 `.flutter-enabled` 不存在；不安装或升级依赖。保持 workspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete。

### 审查前完整构建与脚本

工具链：Xcode 26.3（17C529）。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Debug -showBuildSettings
```

退出码 0；日志 `Derived/swift6-issue17/Debug-settings.log`。

生效设置：

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Debug build
```

退出码 0；日志 `Derived/swift6-issue17/Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Release -showBuildSettings
```

退出码 0；日志 `Derived/swift6-issue17/Release-settings.log`。

生效设置：

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Release build
```

退出码 0；日志 `Derived/swift6-issue17/Release-build.log`。

```sh
python3 scripts/tests/test-account-session.py
```

退出码 0；日志 `Derived/swift6-issue17/test-account-session-final.log`。

```sh
python3 scripts/tests/test-async-request-integration.py
```

退出码 0；日志 `Derived/swift6-issue17/test-async-request-integration-final.log`。

```sh
python3 scripts/tests/test-async-request.py
```

退出码 0；日志 `Derived/swift6-issue17/test-async-request-final.log`。

```sh
python3 scripts/tests/test-category-source.py
```

退出码 0；日志 `Derived/swift6-issue17/test-category-source-final.log`。

```sh
python3 scripts/tests/test-flutter-bridge.py
```

退出码 0；日志 `Derived/swift6-issue17/test-flutter-bridge-final.log`。

```sh
python3 scripts/tests/test-pagination.py
```

退出码 0；日志 `Derived/swift6-issue17/test-pagination-final.log`。

```sh
python3 scripts/tests/test-rxstudy-logging.py
```

退出码 1；日志 `Derived/swift6-issue17/test-rxstudy-logging-final.log`。

```sh
python3 scripts/tests/test-upgrade-tuist.py
```

退出码 0；日志 `Derived/swift6-issue17/test-upgrade-tuist-final.log`。

```sh
python3 scripts/tests/test_switch_flutter.py
```

退出码 0；日志 `Derived/swift6-issue17/test_switch_flutter-final.log`。

RxStudy Debug/Release 均退出 0 且含 BUILD SUCCEEDED。完整 9 项脚本：8 项退出 0；test-rxstudy-logging.py 退出 1，仍在 `static let mode: LoggingMode = .legacy` 的“默认必须保持旧体系”断言失败，与 #14/#15/#16 记录一致，不计为通过。请求集成最终日志无 warning/error。无环境阻塞，未执行设备验证。

### 诊断对照

最终 Release 日志实际编译了本次源码；Provider 全局实例、活动管理器静态可变状态、Custom 插件函数转换、HUD 协议隔离及本次请求调用端的 Provider 访问诊断均未再出现。Debug 同样成功，不以增量构建零告警推断全工程安全。保留的完整非 lint 告警清单在 `Derived/swift6-issue17/remaining-warnings.txt`。

| 保留项 | 任务或边界 |
| --- | --- |
| UIKit 协议、监听/Relay、示例 Future.value、刷新 PreferenceKey、主题和 UI 回调 | #18；Future.value 是取得 Provider 的隔离传播后暴露的相邻 Combine 桥接问题，需在 C2 处理 |
| 日志单例、导出捕获、NetworkDebuggingPlugin.Options/LogOptions | #19 |
| TheRouter 与调用端路由协议、全局状态 | #20 |
| UniMP 入口/事件回调 | #21 |
| ResponseCachePlugin.userDefaultsCache | 既有 Foundation UserDefaults 非 Sendable 全局句柄，缓存存取继续使用系统实现，本轮未改变缓存策略；后续切换前单独审计 |
| Moya/Alamofire/RxCocoa 等依赖兼容、Moya 多 target 隐式依赖提示 | 锁定依赖现状；未升级或编辑依赖 |
| 弃用 API、SwiftLint、AppIntents 元数据、脚本无输出及重复链接库提示 | 既有非 C1 并发诊断 |


## 双轴审查

按 code-review skill，以已验证基点 `5201fb191` 审查本任务工作区差异（用户要求审查后独立提交），排除用户文件。两个独立代理分别执行 Standards 与 Spec 轴。

### Standards

首次 1 项非阻塞规范问题：新增类型缺少仓库要求的 MARK 分区。已补中文分区与方法说明；复查 0 项未解决发现、0 项新增代码气味建议。git diff --check 通过。

### Spec

首次 1 项 P2：并行请求中先失败的错误文本可能被另一请求随后收尾关闭。先新增真实 Provider 接缝断言并确认失败，再将提示与令牌统一锁定协调，回归通过。独立复查确认原问题解决、未发现确定新问题；剩余 0 项。

两轴各 0 项未解决发现。设备验证待开发者执行，既有日志脚本失败不计通过。

下一项提示词见 [Swift6-Issue18新对话提示词.md](Swift6-Issue18新对话提示词.md)。

## 审查修复后的最终复验

以下记录对应并行提示修复后的最终源码；两配置均含 BUILD SUCCEEDED，完整脚本仍为 8/9 通过，唯一失败为既有 legacy 断言。生效设置两配置均为 CODE_SIGNING_ALLOWED=NO、SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete。请求集成日志无 warning/error。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Debug -showBuildSettings
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/Debug-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Debug build
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Release -showBuildSettings
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/Release-settings.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -configuration Release build
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/Release-build.log`。

```sh
python3 scripts/tests/test-account-session.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test-account-session-final.log`。

```sh
python3 scripts/tests/test-async-request-integration.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test-async-request-integration-final.log`。

```sh
python3 scripts/tests/test-async-request.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test-async-request-final.log`。

```sh
python3 scripts/tests/test-category-source.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test-category-source-final.log`。

```sh
python3 scripts/tests/test-flutter-bridge.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test-flutter-bridge-final.log`。

```sh
python3 scripts/tests/test-pagination.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test-pagination-final.log`。

```sh
python3 scripts/tests/test-rxstudy-logging.py
```

退出码 1；日志 `Derived/swift6-issue17/reviewed/test-rxstudy-logging-final.log`。

```sh
python3 scripts/tests/test-upgrade-tuist.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test-upgrade-tuist-final.log`。

```sh
python3 scripts/tests/test_switch_flutter.py
```

退出码 0；日志 `Derived/swift6-issue17/reviewed/test_switch_flutter-final.log`。

