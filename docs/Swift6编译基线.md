# Swift 6 迁移编译基线（Issue #10）

日期：2026-11-17。父规格：#9。分支：`codex/swift6-migration`。
基点提交：`648f01214f663a0345cdbd71c6a24f1fa9d625b3`。

## 环境与范围

Xcode 26.3（17C529），Apple Swift 6.2.4（swiftlang-6.2.4.1.4）。四项应用构建设置均为 `SWIFT_VERSION = 5.9`、最低 iOS 17.6。编译器版本描述工具链能力，语言模式决定源码检查规则；当前仍属于 Swift 5 语言模式，尚未完成 Swift 6 迁移。未覆盖或开启完整严格并发检查。

Flutter 的 `.flutter-enabled` 不存在，当前关闭；未重新安装或升级 Pods。两个锁文件 SHA-256 相同，安装状态与锁定状态一致：

```json
{
  "Podfile.lock": "6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff",
  "Pods/Manifest.lock": "6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff",
  "flutter_enabled": false
}
```

## 构建结果

使用既有 CocoaPods workspace，通用 iOS 目的地，关闭代码签名。属于当前缓存环境下的 build 基线，并非 clean 性能测试。完整日志位于仓库本机 `Derived/swift6-baseline/`（被忽略，不提交）。

### RxStudy-Debug

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build
```

退出码：0；成功证据：`** BUILD SUCCEEDED **`（日志第 36396 行）。首个失败原因：无。
完整日志：`Derived/swift6-baseline/RxStudy-Debug.log`；实际设置：`Derived/swift6-baseline/RxStudy-Debug-settings.log`。

### RxStudy-Release

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build
```

退出码：0；成功证据：`** BUILD SUCCEEDED **`（日志第 30417 行）。首个失败原因：无。
完整日志：`Derived/swift6-baseline/RxStudy-Release.log`；实际设置：`Derived/swift6-baseline/RxStudy-Release-settings.log`。

### SwiftUIStudy-Debug

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build
```

退出码：0；成功证据：`** BUILD SUCCEEDED **`（日志第 1871 行）。首个失败原因：无。
完整日志：`Derived/swift6-baseline/SwiftUIStudy-Debug.log`；实际设置：`Derived/swift6-baseline/SwiftUIStudy-Debug-settings.log`。

### SwiftUIStudy-Release

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build
```

退出码：0；成功证据：`** BUILD SUCCEEDED **`（日志第 1444 行）。首个失败原因：无。
完整日志：`Derived/swift6-baseline/SwiftUIStudy-Release.log`；实际设置：`Derived/swift6-baseline/SwiftUIStudy-Release-settings.log`。

## 验证边界

四项均成功，无待开发者补齐的编译阻塞。现有弃用 API、脚本输出等告警保留于日志，#11 应与此基线比较。未修改业务源码、依赖或构建配置；本任务无新增行为测试接缝，不适用 TDD。未发现项目测试文件，未运行单元测试或模拟器；设备回归由开发者执行。后续 #11 保持相同依赖与 Flutter 开关，执行完整严格并发诊断。
