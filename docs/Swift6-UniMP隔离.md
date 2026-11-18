# Swift 6 UniMP 隔离（Issue #21）

基点 `712a94cbb0e`，分支 `codex/swift6-migration`。SDK 为锁定的 UniMP Core/File 4.36。Flutter 标记 `.flutter-enabled` 缺失，两份锁文件 SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`。用户原有的项目文件和 .DS_Store 差异逐字节比对一致，未跟踪的迁移计划哈希一致。

## 入口、顺序和所有权

- 原来 `static let shared = UniMPManager()` 暴露非 Sendable 单例。现在管理器、实例状态和 UIKit 入口由 `@MainActor` 隔离。AppDelegate 启动路径和 MyController 菜单路径已经在主 Actor，无须修改。设置代理、配置菜单、初始化引擎、注册模块和组件的顺序保持原样。
- 安装仍同步执行，先读取版本，再将 present 打开提交给主队列。安装失败仍先执行失败回调再记录错误。打开成功先写入实例再通知调用者。传入打开方法的 Swift 回调同时声明 `@MainActor @Sendable`，供 SDK 的可发送完成闭包安全捕获，SDK 实例仍由主 Actor 保存和使用。
- 原来事件处理直接读取普通闭包属性。现在只把 `@Sendable` 观察者放在 `OSAllocatedUnfairLock` 中，取出快照后在锁外调用。事件仍在 SDK 回调线程打印，先执行一次 `callback("native callback message", false)` 再通知观察者。锁只保护注册和取值。同一观察者可能被多个 SDK 回调并发调用，调用方需自管捕获状态。SDK 的 NSString/NSDictionary 可包含可变对象，Swift 的 `Any` 和回复块都在原回调中借用。观察者应同步处理，避免保留或将它们放进 Task。如需异步消费，应在回调内提取所需值并转成自有的 Sendable 类型。关闭 keepAlive 后，观察者不得依赖再次回传。
- 胶囊关闭仍先调用实例 close，再通知宿主。关闭完成在主线程时同步处理，在后台时把清理投递到主队列。仅当关闭前记录的打开代次仍匹配时清空实例，避免迟到的回调清掉新打开的会话。菜单仍先向小程序发送 NativeEvent，再通知宿主。闪屏视图仍同步返回自定义 UIView 或 LoadingView。菜单、胶囊和小程序关闭通知在主线程同步执行，在后台把字符串及宿主动作投递到主队列。SDK 在同一个关闭块中先调用关闭通知再调用完成，后台入口共用主队列，保留此提交顺序。闪屏通过显式主 Actor 检查同步返回。

## 二进制线程证据与兼容边界

核对了安装的 `DCUniMPSDKEngine.h`、`DCUniMPInstance.h` 和 [DCloud iOS API](https://nativesupport.dcloud.net.cn/UniMPDocs/API/ios)。ARM64 `liblibPDRCore.a` 的定位结果保留在 `binary-symbols.log`、`binary-disassembly.log`。可见菜单和胶囊代理分别由 `PGNativeNavigationbar` 的点击和关闭方法触发，闪屏由 `DCUniMPViewController.loadSplashView` 同步请求。打开经 `DCUniMPManager` 转发，能看到创建、显示的完成块和保存完成块的路径。`showUniMP:completion:` 同步调用 `loadSplashView` 后才发起 present，部分显示分支明确提交到主队列。Weex 二进制中的 `-[PlusWeexModule sendNativeEvent:::]` 直接调用事件代理后释放原参数，调用点没有切到主队列，见 `binary-weex.log`。调用点证据的范围限于锁定二进制及所检查路径。

以下线程保证缺少完整证据：

- 打开成功及已有实例复用是否始终在主队列。失败使用 Sendable Error 进入主 Actor，主线程失败仍同步。打开成功时使用同步 `MainActor.assumeIsolated` 自带的运行时检查，局部 `nonisolated(unsafe)` 仅用于在检查后的闭包内访问 SDK 实例。此标记只用于已经在同一队列的值，无队列跳转、逃逸或 SDK 类型的 Sendable 扩展。若 SDK 明确主 Actor 注解并被 Swift 导入，移除此局部标记及手动隔离块。
- 胶囊、菜单、闪屏和关闭通知的全路径主 Actor 保证。闪屏要求立即返回 UIKit 视图，显式检查保留同步时序。闪屏及打开成功若违反主线程前提会触发运行时隔离失败，Release 同样适用。待 SDK 提供可导入的主 Actor 契约时可移除检查和相应回跳。若设备发现闪屏或打开成功在后台回调，须依据厂商支持的调度和生命周期重新设计对应入口。
- 实例 close 完成和 JS 事件的回调队列。close 完成忽略 SDK 参数，只调度清理动作。JS 事件不切换队列或假定线程。若 SDK 明确 close 完成由主 Actor 调用，可移除分支。若将来调整事件观察 API，需先明确 SDK 数据的借用、复制和回复块调用约束。

## 设备步骤

1. 安装 Debug 真机包，冷启动后检查设置代理和菜单、引擎初始化、模块与组件注册的先后。打开「我的」里的 UniMP 入口，确认 wgt 安装、版本日志、闪屏和 present 顺序。
2. 在打开完成、关闭完成、闪屏、菜单、胶囊关闭和小程序关闭通知处设置断点，记录调用栈及 `Thread.isMainThread`。覆盖首次打开、关闭后重开、已有实例复用，以及 Debug 测试入口模拟的安装失败和 SDK 打开失败。再用 Release 包复验。
3. 点击两个菜单项，观察小程序先收到 NativeEvent，再执行宿主观察。由 JS 分别发送字符串和含嵌套对象的数据，确认先收到一次 native 回复，再观察到原始事件数据。临时观察者应在原回调中打印线程与字段，避免保留 SDK 对象。
4. 测试胶囊关闭、应用内关闭及快速关闭后重开，检查关闭完成清空实例与通知先后，并观察退出手势、导航、重复打开和主线程检查。设备结果由开发者回填。

## 构建与脚本证据

使用 Xcode 26.3（17C529）。完整命令、退出码及未截断输出位于 `Derived/swift6-issue21/<名称>.command`、`.exit`、`.log`。先改动 UniMPManager 并用 Debug 工作区增量触发源码编译，日志 `targeted`、`targeted-final` 均退出 0。首轮出现三条闭包 Sendable 类型诊断，补齐显式类型后复编消失。审查修订后通过 `targeted-accepted` 再次编译 UniMPManager.swift，随后重新执行两个配置的设置查询及构建（`RxStudy-*-accepted-settings`、`RxStudy-*-accepted-build`）。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration <Debug或Release> -showBuildSettings
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -scheme RxStudy -configuration <Debug或Release> -verbose build
```

两配置四次命令均退出 0，两次构建均输出 BUILD SUCCEEDED。设置实际为 `CODE_SIGNING_ALLOWED = NO`、`SWIFT_VERSION = 5.9`、`SWIFT_STRICT_CONCURRENCY = complete`。RxStudy 编译命令为 `-swift-version 5`，并启用 StrictConcurrency。UniMPManager 仅编入 RxStudy，本轮没有共享源码变更。

#11 的五条 UniMP 诊断覆盖单例、打开完成中的 self 和回调捕获、关闭完成的 self 捕获、LoadingView 初始化。这五条均未在源码复编和 Release 编译重现。该文件仍有原有 SwiftLint 强制转换和悬空文档注释告警。范围外并发告警包括 ResponseCachePlugin、MBProgressHUD、MJRefresh、HotKeyController 及 DownloadWebController，各次完整原文见构建日志。

Python 脚本逐文件以 `python3 scripts/tests/<文件名>.py` 执行，全部 9 个脚本退出 0，证据见 `test*.final.command`、`test*.final.exit` 和 `test*.final.log`。此套件没有 UniMP 设备行为接缝。编译验证隔离，设备步骤验证真实 SDK 调度和交互。


## 双轴独立审查

- Standards 发现无证据的主队列假设可能终止宿主，且延迟关闭完成可能清掉新会话。已对值可发送的入口增加后台回跳，清理前核对打开代次。剩余的成功实例和同步闪屏入口适用上文列出的运行时前提。
- Spec 通过独立反汇编追踪事件直接调用、常规 UIKit 展示和关闭通知先于完成的路径。根据审查移除了与 `MainActor.assumeIsolated` 重复的主队列预检。事件归属和两处待设备确认的主 Actor 前提见上文。
