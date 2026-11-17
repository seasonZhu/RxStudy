# Swift 6 共享资源生成修复（Issue #12）

## 范围与学习说明

基点 8263e534a9d6eae12c8382303ac958ef61e3ba0f；分支 codex/swift6-migration。仅实施 A1，未切换 Target。依赖锁 SHA-256 为 6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff；Flutter 关闭。

#11 的 Shared/Generated/Assets+SwiftGen.swift 诊断为 static property 不安全：ColorAsset、ImageAsset 不符合 Sendable。修复前 ColorAsset 是 class，name 可变，并有 lazy color/swiftUIColor；首次并发访问可能同时写入缓存。ImageAsset 虽是值类型，但未声明 Sendable。

修改前示例：`final class ColorAsset { var name: String; lazy var color: Color = ... }`。
修改后示例：`struct ColorAsset: Sendable { let name: String; var color: Color { ... } }`；ImageAsset 同样只保存 let String 并声明 Sendable。

Sendable 由编译器检查存储属性，不使用 @unchecked Sendable、@preconcurrency 或 nonisolated(unsafe)。描述值不拥有 UI 状态，无须强加 MainActor。返回的 UIKit/SwiftUI 对象仍须遵守调用端的隔离与框架约束，不能从描述值可发送推导 UI 操作可跨线程。颜色不再由包装层缓存，每次访问通过系统资源 API 解析；不保证对象身份一致。当前调用方使用资源名称或颜色值，不依赖包装引用身份。设备上的主题、动态颜色与图片显示仍待开发者验证。

模板来源为本机 `swiftgen template cat xcassets swift5`，保留上游生成结构，仅调整颜色和图片包装。swiftgen.yml 使用仓库模板路径；生成文件被既有规则忽略，故提交模板和配置，不只修改生成产物。`bash scripts/swiftgen.sh` 连续运行两次内容相同。字符串资源只含 String 与 Bundle 访问，本轮无对应并发诊断，不加隔离。

## 验证记录

日志位于被忽略的 Derived/swift6-a1/，完整结构化记录见 results.json。以下为完整命令与退出码。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志：`Derived/swift6-a1/RxStudy-Debug-showBuildSettings.log`。

生效设置：CODE_SIGNING_ALLOWED = NO；SWIFT_STRICT_CONCURRENCY = complete；SWIFT_VERSION = 5.9。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志：`Derived/swift6-a1/RxStudy-Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志：`Derived/swift6-a1/RxStudy-Release-showBuildSettings.log`。

生效设置：CODE_SIGNING_ALLOWED = NO；SWIFT_STRICT_CONCURRENCY = complete；SWIFT_VERSION = 5.9。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志：`Derived/swift6-a1/RxStudy-Release-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志：`Derived/swift6-a1/SwiftUIStudy-Debug-showBuildSettings.log`。

生效设置：CODE_SIGNING_ALLOWED = NO；SWIFT_STRICT_CONCURRENCY = complete；SWIFT_VERSION = 5.9。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志：`Derived/swift6-a1/SwiftUIStudy-Debug-build.log`。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

退出码：0；日志：`Derived/swift6-a1/SwiftUIStudy-Release-showBuildSettings.log`。

生效设置：CODE_SIGNING_ALLOWED = NO；SWIFT_STRICT_CONCURRENCY = complete；SWIFT_VERSION = 5.9。

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

退出码：0；日志：`Derived/swift6-a1/SwiftUIStudy-Release-build.log`。


## 诊断对照

#11 资源诊断去重 33 条（按文件行列消息）；本轮四项资源并发诊断均为 0。其他批次的模型、UI、网络、全局状态与依赖告警保留，不属于本任务完成承诺。增量构建发射受缓存影响，不以其他告警总数比较推断全部消除。

- RxStudy-Debug-build.log：BUILD SUCCEEDED=True；资源并发诊断 0；其余并发诊断按目录去重计数 {'Packages': 6, 'RxStudy': 83}。
- RxStudy-Release-build.log：BUILD SUCCEEDED=True；资源并发诊断 0；其余并发诊断按目录去重计数 {'Packages': 10, 'Pods': 272, 'RxStudy': 93, 'Shared': 4}。
- SwiftUIStudy-Debug-build.log：BUILD SUCCEEDED=True；资源并发诊断 0；其余并发诊断按目录去重计数 {'SwiftUIStudy': 12}。
- SwiftUIStudy-Release-build.log：BUILD SUCCEEDED=True；资源并发诊断 0；其余并发诊断按目录去重计数 {'Packages': 1, 'Pods': 15, 'Shared': 4, 'SwiftUIStudy': 64}。

## 完整现有脚本测试

- `python3 scripts/tests/test-account-session.py`：退出码 0；日志 `Derived/swift6-a1/test-account-session.log`。
- `python3 scripts/tests/test-async-request-integration.py`：退出码 0；日志 `Derived/swift6-a1/test-async-request-integration.log`。
- `python3 scripts/tests/test-async-request.py`：退出码 0；日志 `Derived/swift6-a1/test-async-request.log`。
- `python3 scripts/tests/test-category-source.py`：退出码 0；日志 `Derived/swift6-a1/test-category-source.log`。
- `python3 scripts/tests/test-flutter-bridge.py`：退出码 0；日志 `Derived/swift6-a1/test-flutter-bridge.log`。
- `python3 scripts/tests/test-pagination.py`：退出码 0；日志 `Derived/swift6-a1/test-pagination.log`。
- `python3 scripts/tests/test-rxstudy-logging.py`：退出码 1；日志 `Derived/swift6-a1/test-rxstudy-logging.log`。
- `python3 scripts/tests/test-upgrade-tuist.py`：退出码 0；日志 `Derived/swift6-a1/test-upgrade-tuist.log`。
- `python3 scripts/tests/test_switch_flutter.py`：退出码 0；日志 `Derived/swift6-a1/test_switch_flutter.log`。

日志测试在运行行为测试前因“默认必须保持旧体系”断言失败；HEAD 已为 `.modern`，本轮未修改日志配置或测试。这是既有测试前提不匹配，未为通过测试更改无关业务，完整测试并非全通过。其他 9 项脚本通过。无资源行为自动化接缝，本轮通过重新生成和四项编译验证，未新增镜像测试。

## 审查与设备交接

按 code-review 技能独立执行 Standards 与 Spec 两轴审查，源码各 0 项发现。四项构建通过不等于设备行为通过；两个 App 的资源加载、主题和动态颜色由开发者设备验证。
