# Swift 6 页面状态与本地 HUD 隔离（Issue #16 / B2）

基点 b5f73640d3e42b857fb610e298013387eea4a25f，分支 codex/swift6-migration。复用 #11、#14、#15 基线；仅实施 B2。保持 Swift 5.9、完整严格并发、Flutter 关闭及依赖锁定。用户 .DS_Store、project.pbxproj 与未跟踪迁移计划保留且不提交。构建针对当前工作区，不代表干净检出。

## 诊断与选择

原 Project、PublicNumber、Tree、HotKey ViewModel 在非隔离方法写状态、启动 Task，再通过 MainActor.run 局部写入，存在发送 self/viewModel、捕获非 Sendable 与隔离默认值告警。现在整个状态所有者归 MainActor，初始化和 Task 继承隔离；await 网络期间允许其他主 Actor 工作。原有分页和任务生命周期保持，未扩展为分页竞态重构。

前：`@Observable final class ProjectViewModel`，`Task { await loadTags() }`。
后：`@MainActor @Observable final class ProjectViewModel`，任务仍用原入口，但状态、初始化和异步方法拥有同一隔离域。保留原 MainActor.run，避免无关重排。

AccountAPIService.shared 原为非 Sendable 共享状态。整体 MainActor 后，真实编译要求 LoginViewModel、MineViewModel 的初始化与状态同样隔离。同步 TargetType.headers 无法 await，采用系统 OSAllocatedUnfairLock 保护 String Cookie 快照。

前：`AccountAPIService.shared.cookieHeaderValue`。
后：`AccountAPIService.requestHeaders`。主 Actor 内从 session 生成字符串，锁内仅复制字符串。认证开始清空快照，成功且 revision 有效后更新，退出立即清空；失败和旧请求不恢复 Cookie。先更新快照再发布 Observation 状态，无 await 间隙。锁内不访问会话、不执行业务回调，不让 provider 或 Observation 对象跨域。没有新增不安全兼容标记。快照服务当前用于应用单例；多个独立服务实例并存不属于应用会话模型。

ShareSheet 的同步 UIActivity.perform 覆写不提供主 Actor 保证，先取 URL 值，再通过 Task @MainActor 访问 UIApplication，避免把整个 activity 传入任务。

本地 ProgressHUD 原 shared 与可变 UI 属性无隔离；类标记 MainActor，扩展入口和内部延时任务继承同一隔离。前：`@Observable public class ProgressHUD`；后：`@MainActor @Observable public class ProgressHUD`。未将 UI 对象声明 Sendable。

## Pod 边界

Podfile 使用 :path => Packages/ThirdParty/ProgressHUD；podspec source_files 为 SwiftUI/Sources/**/*.swift。Pods 工程 group 路径为 ../Packages/ThirdParty/ProgressHUD，直接编译本地源码，非复制快照。故本次无须 pod install，不改 Pods 生成文件或 podspec，不升级。未来安装仍从相同本地路径获取此注解；安装后应复查源路径与锁文件，不能依赖手改 Pods 工程。

Podfile.lock、Pods/Manifest.lock SHA-256 均为 6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff。

## 验证与设备交接

针对性编译日志位于 Derived/swift6-issue16/targeted*.log。初始编辑误命中文件头注释导致语法错误，随后纠正；隔离传播和锁闭包诊断据实修复。最终记录见下。本轮不运行模拟器或设备。

开发者设备检查：

1. 打开项目、公众号、体系和热词页，刷新、加载更多、快速切分类并反复进出，核对加载态和错误提示。
2. 登录、失败重试、退出与切号，检查收藏和积分请求在认证中/退出后不携带旧 Cookie，旧登录响应不能恢复状态。
3. HUD 连续显示和关闭、成功/错误提示、进度、banner、自动消失与手动取消，核对不会闪回旧提示或残留遮罩。
4. HUD 显示时切后台/前台、键盘弹出收起、导航返回，检查布局、交互恢复与主线程运行警告。
5. 分享到 Safari，检查链接打开。

编译成功不等于上述设备验证通过。沿用既有账号、分页和请求测试接缝，未新增镜像测试。

## 下一项就绪任务提示词

执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #17（Swift 6 迁移：修复 Rx 网络与 HUD 插件的隔离边界）。先读 #17、#9、#11、#14 与现有 Swift6 修复文档。保持 codex/swift6-migration、用户未提交文件、锁定依赖、Flutter 关闭与 Swift 5 模式。只实施 C1，依据真实诊断处理 Provider、加载插件、活动计数与 HUD 成功/失败/取消收尾，复用基线；先源码针对性编译，稳定后按 Issue 执行 RxStudy 两配置严格构建及相关和完整脚本。沿用 workspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete。记录命令、设置、退出码、日志及既有 legacy 断言失败，附中文示例、安全边界和设备步骤，双轴审查后独立提交。设备验证由开发者执行。

## 最终命令与结果

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0；日志 `Derived/swift6-issue16/Debug-settings.log`。

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-issue16/Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码 0；日志 `Derived/swift6-issue16/Release-settings.log`。

```text
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-issue16/Release-build.log`。

```sh
python3 scripts/tests/test-account-session.py
```

退出码 0；日志 `Derived/swift6-issue16/test-account-session-final.log`。

```sh
python3 scripts/tests/test-async-request-integration.py
```

退出码 0；日志 `Derived/swift6-issue16/test-async-request-integration-final.log`。

```sh
python3 scripts/tests/test-async-request.py
```

退出码 0；日志 `Derived/swift6-issue16/test-async-request-final.log`。

```sh
python3 scripts/tests/test-category-source.py
```

退出码 0；日志 `Derived/swift6-issue16/test-category-source-final.log`。

```sh
python3 scripts/tests/test-flutter-bridge.py
```

退出码 0；日志 `Derived/swift6-issue16/test-flutter-bridge-final.log`。

```sh
python3 scripts/tests/test-pagination.py
```

退出码 0；日志 `Derived/swift6-issue16/test-pagination-final.log`。

```sh
python3 scripts/tests/test-rxstudy-logging.py
```

退出码 1；日志 `Derived/swift6-issue16/test-rxstudy-logging-final.log`。

```sh
python3 scripts/tests/test-upgrade-tuist.py
```

退出码 0；日志 `Derived/swift6-issue16/test-upgrade-tuist-final.log`。

```sh
python3 scripts/tests/test_switch_flutter.py
```

退出码 0；日志 `Derived/swift6-issue16/test_switch_flutter-final.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-issue16/Debug-reverified.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码 0；日志 `Derived/swift6-issue16/Release-reverified.log`。

```sh
python3 scripts/tests/test-account-session.py
```

退出码 0；日志 `Derived/swift6-issue16/account-reverified.log`。

两配置最终日志均含 BUILD SUCCEEDED。完整 9 项脚本 8 项通过；test-rxstudy-logging.py 退出 1，仍为 `static let mode: LoggingMode = .legacy` 的“默认必须保持旧体系”既有断言，与 B1/D2 基线一致，不记为通过。最终 Cookie 清空调整后再执行两配置及账号测试，均退出 0。未调整共享源码，本轮未重跑 RxStudy 构建。

对照 #11/B1：本轮页面发送 self/viewModel、默认值隔离、AccountAPIService.shared 与本地 ProgressHUD 共享状态诊断在最终相关编译中未再出现。并发安全不能由增量告警总数证明。其他任务原有 Moya/Alamofire 等依赖可发送性告警继续保留；WebUIController 四条可选协议方法近似匹配与 HotKeyView 的导航弃用告警是既有 API 告警，不在 B2 修改范围。

## 双轴审查

固定基点 b5f73640d3e42b857fb610e298013387eea4a25f，审查本任务工作区差异，排除用户文件。按 code-review 技能由两个独立代理并行执行。

### Standards

0 项发现。符合精准修改、简洁与中文规范，未发现需处理的代码气味。

### Spec

0 项阻塞源码发现。页面、账号、Cookie 快照及本地 HUD 符合 B2；要求的 Pod 边界和验证记录已补齐。生产使用 shared；注入的测试实例也会写静态 Cookie 快照，测试需隔离会话操作，不能假定每个实例拥有独立请求头。
