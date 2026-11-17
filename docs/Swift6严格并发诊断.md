# Swift 6 完整严格并发诊断（Issue #11）

基点：648f01214f663a0345cdbd71c6a24f1fa9d625b3；分支 codex/swift6-migration；日期 2026-11-17。#10 已关闭且四项成功。本任务仅诊断，不修改业务或语言模式。锁文件 SHA-256 均为 6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff，Flutter 关闭。

## 结果摘要

四项均退出 0 且 BUILD SUCCEEDED。按文件、行列与消息去重的并发诊断数：RxStudy Debug 1206、Release 1198；SwiftUIStudy Debug 81、Release 115。数量含 Pods；不同优化和缓存影响发射，不直接视为独立修复点数。执行时 HEAD 为 87805fdd2b454519e3acbdab2a934bd652a41c79，保留用户未提交文件。

## 检查方法

完整严格并发检查在 Swift 5 下提前报告 Swift 6 约束；构建成功不表示并发安全。Actor 限定状态访问的隔离域；主队列运行不自动赋予闭包 MainActor 类型。Sendable 表示跨隔离域传值的安全约束，let 引用并不保证引用对象不可变。未添加兼容标记。

日志位于被忽略的 Derived/swift6-strict/；基线位于 Derived/swift6-baseline/。下表诊断以文件、行列、消息去重；基线没有同条告警仅表示本轮新观察到，缓存构建可能影响基线发射，不能断言源码问题本轮才产生。

### RxStudy-Debug settings：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

### RxStudy-Debug build：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

成功标记：True；日志 `Derived/swift6-strict/RxStudy-Debug-build.log`。

严格并发诊断分布（去重）：{'MarqueeLabel': 5, 'LifetimeTracker': 41, 'PinLayout': 48, 'SwiftDate': 16, 'SnapKit': 68, 'KeychainAccess': 15, 'RxSwift': 41, 'JXSegmentedView': 88, 'Differentiator': 3, 'CombineCocoa': 18, 'CocoaDebug': 113, 'Alamofire': 6, 'IQKeyboardNotification': 3, 'FunnyButton': 8, 'FSPagerView': 47, 'AcknowList': 8, 'Moya': 28, 'RxBlocking': 3, 'NSObject+Rx': 2, 'RxCocoa': 145, 'IQTextView': 1, 'RxTheme': 77, 'RxDataSources': 10, 'RxGesture': 39, 'RxSwiftExt': 11, 'RxStudy': 246, 'Packages': 72, 'Shared': 44}。

| 诊断依据（文件:行:列与原文） | 基线关系 |
| --- | --- |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:13:35: warning: conformance of 'MarqueeLabel' to protocol 'CAAnimationDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:1990:23: warning: static property 'leading' is not concurrency-safe because non-'Sendable' type 'EdgeFade' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:1991:23: warning: static property 'trailing' is not concurrency-safe because non-'Sendable' type 'EdgeFade' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/BarDashboard/BarDashboardViewController.swift:32:59: warning: conformance of 'BarDashboardViewController' to protocol 'LifetimeTrackerViewable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:23:58: warning: conformance of 'CircularDashboardViewController' to protocol 'LifetimeTrackerViewable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:230:44: warning: conformance of 'CircularDashboardViewController' to protocol 'PopoverViewControllerDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/LifetimeTracker.swift:119:37: warning: static property 'instance' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:67:22: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:26:14: warning: var 'displayScale' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:27:14: warning: var 'onePixelLength' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:23:29: warning: static property 'layoutDirection' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:27:29: warning: static property 'safeAreaInsetsDidChangeMode' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:34:24: warning: static property 'isInitialized' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:48:25: warning: static property 'autoSizingInProgress' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:54:33: warning: static property 'logWarnings' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:59:29: warning: static property 'activeWarnings' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:66:29: warning: static property 'logMissingLayoutCalls' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:69:29: warning: static property 'lastWarningText' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinLayout+Warning.swift:26:13: warning: var 'numberFormatter' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:30:28: warning: static property 'currentSafeAreaInsetsDidChangeMode' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:33:25: warning: static property 'safeAreaInsetsDidChangeMode' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:126:16: warning: static property 'originalImplementation' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:192:20: warning: static property 'pinlayoutSafeAreaInsets' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:25:19: warning: conformance of 'UIView' to protocol 'Layoutable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:25:31: warning: conformance of 'UIView' to protocol 'SizeCalculable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:98:20: warning: static property 'pinlayoutAutoSizingRect' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:99:20: warning: static property 'pinlayoutAutoSizingRectWithMargins' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:96:19: warning: conformance of 'UIView' to protocol 'AutoSizeCalculable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Supports/Commons.swift:145:20: warning: static property 'autoFormats' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Supports/Commons.swift:319:16: warning: static property 'appModule' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:27:21: warning: static property 'withYear' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:30:21: warning: static property 'withMonth' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:34:21: warning: static property 'withWeekOfYear' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:40:21: warning: static property 'withDay' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:43:21: warning: static property 'withTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:46:21: warning: static property 'withTimeZone' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:49:21: warning: static property 'withSpaceBetweenDateAndTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:52:21: warning: static property 'withDashSeparatorInDate' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:55:21: warning: static property 'withFullDate' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:58:21: warning: static property 'withFullTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:63:21: warning: static property 'withInternetDateTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:67:21: warning: static property 'withInternetDateTimeExtended' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:71:21: warning: static property 'withoutTZSeparators' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/SwiftDate.swift:22:20: warning: static property 'defaultRegion' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintConfig.swift:35:23: warning: static property 'interfaceLayoutDirection' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintDSL.swift:49:13: warning: var 'labelKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:93:13: warning: var 'constraintsKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:216:23: warning: static property 'userPresence' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:224:23: warning: static property 'biometryAny' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:233:23: warning: static property 'touchIDAny' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:240:23: warning: static property 'biometryCurrentSet' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:249:23: warning: static property 'touchIDCurrentSet' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:255:23: warning: static property 'devicePasscode' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:264:23: warning: static property 'watch' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:271:23: warning: static property 'or' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:278:23: warning: static property 'and' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:284:23: warning: static property 'privateKeyUsage' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:291:23: warning: static property 'applicationPassword' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:1259:13: warning: let 'SynchronizableAny' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:1263:13: warning: let 'MatchLimitOne' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:1264:13: warning: let 'MatchLimitAll' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Disposables/BooleanDisposable.swift:12:25: warning: static property 'BooleanDisposableTrue' is not concurrency-safe because non-'Sendable' type 'BooleanDisposable' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:36:23: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'ConcurrentMainScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:18:20: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'CurrentThreadSchedulerQueueKey' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:42:23: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'CurrentThreadScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:44:24: warning: static property 'isScheduleRequiredKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:55:24: warning: static property 'scheduleInProgressSentinel' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/Platform/DispatchQueue+Extensions.swift:12:24: warning: static property 'token' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Errors.swift:19:10: warning: associated value 'disposed(object:)' of 'Sendable'-conforming enum 'RxError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:37:23: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'MainScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:41:23: warning: static property 'asyncInstance' is not concurrency-safe because non-'Sendable' type 'SerialDispatchQueueScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Disposables/NopDisposable.swift:14:28: warning: static property 'noOp' is not concurrency-safe because non-'Sendable' type 'any Disposable' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/ObservableType+Extensions.swift:137:24: warning: static property '_defaultErrorHandler' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/ObservableType+Extensions.swift:146:24: warning: static property '_customCaptureSubscriptionCallstack' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/Platform/RecursiveLock.swift:12:11: warning: class 'RecursiveLock' must restate inherited '@unchecked Sendable' conformance | 基线已有 |
| Pods/RxSwift/RxSwift/Rx.swift:140:23: warning: static property 'recordCallStackOnError' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Disposables/ScheduledDisposable.swift:9:13: warning: let 'disposeScheduledDisposable' is not concurrency-safe because non-'Sendable' type '(ScheduledDisposable) -> any Disposable' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observers/TailRecursiveSink.swift:15:16: warning: var 'maxTailRecursiveSinkStackSize' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Indicator/JXSegmentedIndicatorBaseView.swift:17:50: warning: conformance of 'JXSegmentedIndicatorBaseView' to protocol 'JXSegmentedIndicatorProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedListContainerView.swift:60:50: warning: conformance of 'JXSegmentedListContainerView' to protocol 'JXSegmentedViewListContainer' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Differentiator/Sources/Differentiator/Diff.swift:25:14: warning: associated value 'duplicateItem(item:)' of 'Sendable'-conforming enum 'Error' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/Differentiator/Sources/Differentiator/Diff.swift:26:14: warning: associated value 'duplicateSection(section:)' of 'Sendable'-conforming enum 'Error' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/Differentiator/Sources/Differentiator/Diff.swift:27:14: warning: associated value 'invalidInitializerImplementation(section:expectedItems:expectedIdentifier:)' of 'Sendable'-conforming enum 'Error' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/DelegateProxy/DelegateProxyType.swift:12:13: warning: var 'associatedKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UICollectionView+Combine.swift:87:85: warning: conformance of 'CollectionViewDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UIScrollView+Combine.swift:141:77: warning: conformance of 'ScrollViewDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UISearchBar+Combine.swift:49:77: warning: conformance of 'UISearchBarDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UITableView+Combine.swift:127:75: warning: conformance of 'TableViewDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Logs/_SwiftLogHelper.swift:15:29: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type '_SwiftLogHelper' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:17:13: warning: var '_successStatusCodes' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:18:13: warning: var '_informationalStatusCodes' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:19:13: warning: var '_redirectionStatusCodes' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:21:13: warning: var '_width' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:22:13: warning: var '_height' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:15:29: warning: static property 'serverURL' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:17:29: warning: static property 'ignoredURLs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:19:29: warning: static property 'onlyURLs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:21:29: warning: static property 'ignoredPrefixLogs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:23:29: warning: static property 'onlyPrefixLogs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:25:29: warning: static property 'additionalViewController' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:27:29: warning: static property 'emailToRecipients' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:29:29: warning: static property 'emailCcRecipients' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:31:29: warning: static property 'mainColor' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:33:29: warning: static property 'protobufTransferMap' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:13:29: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CocoaDebugSettings' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:18:53: warning: main actor-isolated property 'layer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:18:38: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:18:31: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:20:53: warning: main actor-isolated property 'layer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:20:38: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:20:31: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:110:51: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:110:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:111:55: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:111:48: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:115:38: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:115:33: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:82: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:77: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:118:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:118:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:124:38: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:124:33: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:82: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:77: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:127:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:127:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/CocoaDebugViewController.swift:60:37: warning: conformance of 'CocoaDebugViewController' to protocol 'BubbleDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashLogger.swift:48:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CrashLogger' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashStoreManager.swift:15:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CrashStoreManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailViewController.swift:13:59: warning: conformance of 'NetworkDetailViewController' to protocol 'MFMailComposeViewControllerDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:12:23: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'WindowHelper' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:16:14: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Features/ResponseSerialization.swift:360:20: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Features/ResponseSerialization.swift:360:20: warning: type 'JSONResponseSerializer.SerializedObject' (aka 'Any') does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:56:30: warning: call to main actor-isolated instance method 'contentHuggingPriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:59:23: warning: call to main actor-isolated instance method 'setContentHuggingPriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:65:30: warning: call to main actor-isolated instance method 'contentHuggingPriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:68:23: warning: call to main actor-isolated instance method 'setContentHuggingPriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:74:30: warning: call to main actor-isolated instance method 'contentCompressionResistancePriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:77:23: warning: call to main actor-isolated instance method 'setContentCompressionResistancePriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:83:30: warning: call to main actor-isolated instance method 'contentCompressionResistancePriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:86:23: warning: call to main actor-isolated instance method 'setContentCompressionResistancePriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:37:59: warning: main actor-isolated property 'firstItem' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:41:17: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:42:61: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:45:56: warning: main actor-isolated property 'relation' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:47:34: warning: main actor-isolated property 'secondItem' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:51:17: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:52:61: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:55:17: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:56:39: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:59:17: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:60:37: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:62:21: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:63:43: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:64:28: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:65:47: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:69:17: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:70:38: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:156:28: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:158:28: warning: main actor-isolated property 'label' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:163:68: warning: main actor-isolated property 'constraint' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:163:116: warning: main actor-isolated property 'constraint' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:51:15: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:51:37: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:52:15: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:52:38: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:53:15: warning: main actor-isolated property 'relation' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:53:31: warning: main actor-isolated property 'relation' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:54:15: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:54:31: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:55:15: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:55:33: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:56:15: warning: main actor-isolated property 'secondItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:56:34: warning: main actor-isolated property 'secondItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:57:15: warning: main actor-isolated property 'firstItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:57:33: warning: main actor-isolated property 'firstItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:46:18: warning: main actor-isolated property 'translatesAutoresizingMaskIntoConstraints' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:52:25: warning: main actor-isolated property 'superview' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:56:26: warning: main actor-isolated property 'owningView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:63:37: warning: main actor-isolated property 'isActive' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:192:36: warning: call to main actor-isolated initializer 'init(item:attribute:relatedBy:toItem:attribute:multiplier:constant:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:203:30: warning: main actor-isolated property 'label' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:206:30: warning: main actor-isolated property 'priority' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:209:30: warning: main actor-isolated property 'constraint' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:294:47: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:294:102: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:294:136: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:295:30: warning: main actor-isolated property 'constant' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:298:34: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:299:34: warning: main actor-isolated property 'priority' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:323:69: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:323:130: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:323:170: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:324:40: warning: main actor-isolated property 'constant' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:327:32: warning: call to main actor-isolated class method 'activate' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:338:28: warning: call to main actor-isolated class method 'deactivate' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:192:36: warning: sending value of non-Sendable type 'any LayoutConstraintItem' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:192:36: warning: sending value of non-Sendable type 'Any?' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:53:16: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:57:34: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:57:41: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/Internal/DispatchQueueConfiguration.swift:22:16: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/Internal/DispatchQueueConfiguration.swift:27:34: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/Internal/DispatchQueueConfiguration.swift:27:41: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/Infallible/Infallible+Concurrency.swift:31:21: warning: capture of 'disposable' with non-Sendable type 'any Disposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:71:17: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:72:38: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:72:45: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:75:23: warning: capture of 'self' with non-Sendable type 'MainScheduler' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:48:21: warning: capture of 'disposable' with non-Sendable type 'any Disposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:65:44: warning: capture of non-Sendable type 'Self.AsyncIterator.Type' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:65:44: warning: capture of non-Sendable type 'Self.Type' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:63:24: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/OperationQueueScheduler.swift:39:16: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/OperationQueueScheduler.swift:44:34: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/OperationQueueScheduler.swift:44:41: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:84:21: warning: capture of 'disposable' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:141:21: warning: capture of 'disposable' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:190:21: warning: capture of 'disposable' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:37:22: warning: sending value of non-Sendable type '() async throws -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:39:17: warning: sending value of non-Sendable type '() async throws -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:121:50: warning: sending value of non-Sendable type 'Self.Element' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:114:30: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:114:25: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Filters.swift:25:31: warning: main actor-isolated property 'isHidden' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Filters.swift:25:46: warning: main actor-isolated property 'alpha' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:67:14: warning: main actor-isolated property 'pinlayoutSafeAreaInsets' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:70:29: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:83:63: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:84:45: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:84:65: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:158:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:162:72: warning: main actor-isolated property 'safeAreaInsets' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:162:67: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:163:79: warning: main actor-isolated property 'safeAreaInsets' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:163:74: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:165:67: warning: main actor-isolated property 'topLayoutGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:165:82: warning: main actor-isolated property 'length' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:166:70: warning: main actor-isolated property 'bottomLayoutGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:166:88: warning: main actor-isolated property 'length' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:91:29: warning: main actor-isolated property 'safeAreaInsets' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:93:29: warning: call to main actor-isolated instance method 'pinlayoutComputeSafeAreaInsets()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:104:53: warning: main actor-isolated property 'layoutFrame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:104:32: warning: main actor-isolated property 'readableContentGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:108:42: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:109:41: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:114:21: warning: main actor-isolated property 'layoutMargins' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:123:41: warning: main actor-isolated property 'layoutFrame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:123:21: warning: main actor-isolated property 'keyboardLayoutGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout+Size.swift:151:41: warning: main actor-isolated property 'image' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:598:9: warning: call to main actor-isolated instance method 'forwardPropertiesToSublabel()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:604:9: warning: call to main actor-isolated instance method 'forwardPropertiesToSublabel()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:225:32: warning: main actor-isolated property 'isHidden' can not be mutated from a Sendable closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:225:18: warning: main actor-isolated property 'popoverWindow' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:43:58: warning: call to main actor-isolated class method 'makeFromNib()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:44:68: warning: call to main actor-isolated class method 'makeFromNib()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:105:13: warning: capture of 'self' with non-Sendable type 'LifetimeTrackerDashboardIntegration' in a '@Sendable' closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:105:117: warning: capture of 'trackedGroups' with non-Sendable type '[String : LifetimeTracker.EntriesGroup]' in a '@Sendable' closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:17:42: warning: main actor-isolated property 'popoverPresentationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:18:31: warning: main actor-isolated property 'sourceView' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:19:31: warning: main actor-isolated property 'sourceRect' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:19:59: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:19:80: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:20:31: warning: main actor-isolated property 'permittedArrowDirections' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:25:21: warning: call to main actor-isolated initializer 'init(title:message:preferredStyle:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:26:15: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:26:25: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:27:25: warning: call to main actor-isolated initializer 'init(title:message:preferredStyle:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:28:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:28:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:31:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:31:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:34:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:34:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:37:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:37:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:40:62: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:41:28: warning: call to main actor-isolated instance method 'present(_:animated:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:43:15: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:43:25: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:47:58: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:49:24: warning: call to main actor-isolated instance method 'present(_:animated:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:26:25: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:43:25: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:28:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:31:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:34:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:37:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:715:63: warning: reference to var 'NSFoundationVersionNumber' is not concurrency-safe because it involves shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleOrImage/JXSegmentedTitleOrImageDataSource.swift:43:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleOrImage/JXSegmentedTitleOrImageDataSource.swift:43:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleOrImage/JXSegmentedTitleOrImageDataSource.swift:47:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:35: warning: main actor-isolated property 'isTracking' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:16: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:76: warning: main actor-isolated property 'isDecelerating' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:57: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:424:39: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:424:20: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:428:67: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:428:48: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:429:36: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:433:44: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:433:66: warning: main actor-isolated property 'lastContentOffset' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:60: warning: main actor-isolated property 'contentSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:41: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:99: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:80: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:438:60: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:438:77: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:438:105: warning: main actor-isolated property 'lastContentOffset' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:443:47: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:447:37: warning: call to main actor-isolated instance method 'getItemFrameAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:448:38: warning: call to main actor-isolated instance method 'getItemFrameAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:450:36: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:451:45: warning: main actor-isolated property 'dataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:453:98: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:456:98: warning: main actor-isolated property 'dataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:465:26: warning: main actor-isolated property 'lastContentOffset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:465:68: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:466:25: warning: call to main actor-isolated instance method 'scrollSelectItemAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:470:47: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:472:47: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:475:25: warning: call to main actor-isolated instance method 'scrollSelectItemAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:477:24: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:478:25: warning: main actor-isolated property 'scrollingTargetIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:480:25: warning: main actor-isolated property 'scrollingTargetIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:483:21: warning: main actor-isolated property 'dataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:483:71: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:483:114: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:485:38: warning: main actor-isolated property 'indicators' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:488:77: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:490:29: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:492:78: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:494:29: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:498:51: warning: call to main actor-isolated instance method 'cellForItem(at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:498:36: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:499:31: warning: call to main actor-isolated instance method 'reloadData(itemModel:selectedType:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:499:53: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:501:52: warning: call to main actor-isolated instance method 'cellForItem(at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:501:37: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:502:32: warning: call to main actor-isolated instance method 'reloadData(itemModel:selectedType:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:502:54: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:504:21: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:507:13: warning: main actor-isolated property 'lastContentOffset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:20:23: warning: call to main actor-isolated class method 'userInterfaceLayoutDirection(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:20:77: warning: main actor-isolated property 'semanticContentAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:20:64: warning: call to main actor-isolated class method 'appearance()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:26:15: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/AttributeTitle/JXSegmentedTitleAttributeDataSource.swift:69:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/AttributeTitle/JXSegmentedTitleAttributeDataSource.swift:69:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/AttributeTitle/JXSegmentedTitleAttributeDataSource.swift:73:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleImage/JXSegmentedTitleImageDataSource.swift:105:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleImage/JXSegmentedTitleImageDataSource.swift:105:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleImage/JXSegmentedTitleImageDataSource.swift:109:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseCell.swift:19:17: warning: cannot access property 'animator' with a non-Sendable type 'JXSegmentedAnimator?' from nonisolated deinit; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:118:16: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:137:71: warning: call to main actor-isolated instance method 'invalidateLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:137:50: warning: main actor-isolated property 'collectionViewLayout' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:137:35: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:161:63: warning: call to main actor-isolated instance method 'invalidateLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:161:42: warning: main actor-isolated property 'collectionViewLayout' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:161:27: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:171:40: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Title/JXSegmentedTitleDataSource.swift:108:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Title/JXSegmentedTitleDataSource.swift:108:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Title/JXSegmentedTitleDataSource.swift:112:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleGradient/JXSegmentedTitleGradientDataSource.swift:45:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleGradient/JXSegmentedTitleGradientDataSource.swift:45:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleGradient/JXSegmentedTitleGradientDataSource.swift:49:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Number/JXSegmentedNumberDataSource.swift:57:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Number/JXSegmentedNumberDataSource.swift:57:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Number/JXSegmentedNumberDataSource.swift:61:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Dot/JXSegmentedDotDataSource.swift:47:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Dot/JXSegmentedDotDataSource.swift:47:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Dot/JXSegmentedDotDataSource.swift:51:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/IQKeyboardNotification/IQKeyboardNotification/Classes/IQKeyboardInfo.swift:90:35: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/IQKeyboardNotification/IQKeyboardNotification/Classes/IQKeyboardInfo.swift:92:42: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/IQKeyboardNotification/IQKeyboardNotification/Classes/IQKeyboardInfo.swift:92:37: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:61:21: warning: call to main actor-isolated static method 'replaceAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:66:21: warning: call to main actor-isolated static method 'replaceActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:71:21: warning: call to main actor-isolated static method 'addActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:76:21: warning: call to main actor-isolated static method 'addActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:81:21: warning: call to main actor-isolated static method 'removeActions(where:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:86:21: warning: call to main actor-isolated static method 'replaceActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:91:21: warning: call to main actor-isolated static method 'updateLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:71:21: warning: sending value of non-Sendable type '[FunnyAction]' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerView.swift:310:29: warning: main actor-isolated property 'dataSource' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerView.swift:311:29: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewLayoutAttributes.swift:20:36: warning: main actor-isolated property 'position' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewLayoutAttributes.swift:20:55: warning: main actor-isolated property 'position' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:50:35: warning: main actor-isolated property 'position' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:51:41: warning: main actor-isolated property 'scrollDirection' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:52:72: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:52:98: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:73:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:74:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:75:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:90:49: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:94:49: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:106:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:107:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:147:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:148:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:149:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:157:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:159:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:161:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:174:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:175:24: warning: main actor-isolated property 'transform3D' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:186:46: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:200:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:201:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:202:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:206:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:208:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:209:28: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:212:74: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:212:100: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:218:32: warning: main actor-isolated property 'center' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:223:32: warning: main actor-isolated property 'center' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:227:28: warning: main actor-isolated property 'transform3D' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:229:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:231:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:232:28: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:242:41: warning: main actor-isolated property 'scrollDirection' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:248:30: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:253:30: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:258:31: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:263:31: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:269:26: warning: main actor-isolated property 'interitemSpacing' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewCell.swift:143:23: warning: main actor-isolated property 'kvoContext' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewCell.swift:145:22: warning: call to main actor-isolated instance method 'setNeedsLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewCell.swift:112:73: warning: cannot access property 'kvoContext' with a non-Sendable type 'UnsafeMutableRawPointer?' from nonisolated deinit; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:75:28: warning: call to main actor-isolated class method 'animate(withDuration:delay:options:animations:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:91:24: warning: call to main actor-isolated class method 'transition(with:duration:options:animations:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:75:28: warning: sending value of non-Sendable type '() -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:75:28: warning: sending value of non-Sendable type '((Bool) -> Void)?' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:91:24: warning: sending value of non-Sendable type '() -> ()' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlEvent.swift:57:21: warning: call to main actor-isolated instance method 'addTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlEvent.swift:57:21: warning: sending value of non-Sendable type 'Publishers.ControlEvent<Control>.Subscription<S, Control>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:68:21: warning: call to main actor-isolated instance method 'addTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:86:22: warning: call to main actor-isolated instance method 'removeTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:68:21: warning: sending value of non-Sendable type 'Publishers.ControlProperty<Control, Value>.Subscription<S, Control, Value>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:86:22: warning: sending value of non-Sendable type 'Publishers.ControlProperty<Control, Value>.Subscription<S, Control, Value>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UIGestureRecognizer+Combine.swift:78:41: warning: call to main actor-isolated instance method 'addTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UIGestureRecognizer+Combine.swift:81:42: warning: call to main actor-isolated instance method 'removeTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/CocoaDebugWindow.swift:37:24: warning: call to main actor-isolated instance method 'shouldReceive(point:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:69:18: warning: call to main actor-isolated instance method 'addGestureRecognizer' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:69:9: warning: main actor-isolated property 'editView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:69:62: warning: call to main actor-isolated initializer 'init(target:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:71:25: warning: main actor-isolated property 'textContainer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:71:9: warning: main actor-isolated property 'contentTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:72:25: warning: main actor-isolated property 'textContainerInset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:72:9: warning: main actor-isolated property 'contentTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkViewController.swift:102:19: warning: call to main actor-isolated instance method 'reloadHttp(needScrollToEnd:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkViewController.swift:102:53: warning: main actor-isolated property 'reachEnd' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:47:36: warning: main actor-isolated property 'text' can not be mutated from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:47:19: warning: main actor-isolated property 'uiBlockingLabel' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:48:36: warning: main actor-isolated property 'textColor' can not be mutated from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:48:19: warning: main actor-isolated property 'uiBlockingLabel' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:24:18: warning: call to main actor-isolated initializer 'init(frame:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:24:56: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:24:51: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:26:16: warning: main actor-isolated property 'bounds' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:26:51: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:26:46: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:34:19: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:38:16: warning: main actor-isolated property 'rootViewController' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:39:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:40:16: warning: main actor-isolated property 'isHidden' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:56:29: warning: capture of 'self' with non-Sendable type 'WindowHelper?' in a '@Sendable' closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:52:24: warning: reference to captured var 'success' in concurrently-executing code | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:57:29: warning: mutation of captured var 'success' in concurrently-executing code | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:67:19: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:70:16: warning: main actor-isolated property 'rootViewController' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:71:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:72:16: warning: main actor-isolated property 'isHidden' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Logs/LogViewController.swift:287:19: warning: call to main actor-isolated instance method 'refreshLogs_notification()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:130:20: warning: main actor-isolated property 'backgroundColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:130:9: warning: main actor-isolated property 'imageLabel' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:131:29: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:131:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:133:29: warning: main actor-isolated property 'textContainer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:133:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:134:29: warning: main actor-isolated property 'textContainerInset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:134:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:135:29: warning: main actor-isolated property 'isSelectable' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:135:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:137:28: warning: main actor-isolated property 'textContainer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:137:9: warning: main actor-isolated property 'requestUrlTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:138:28: warning: main actor-isolated property 'textContainerInset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:138:9: warning: main actor-isolated property 'requestUrlTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:139:28: warning: main actor-isolated property 'isSelectable' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:139:9: warning: main actor-isolated property 'requestUrlTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:141:23: warning: main actor-isolated property 'textAlignment' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:141:9: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:142:23: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:142:9: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:143:23: warning: main actor-isolated property 'adjustsFontSizeToFitWidth' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:143:9: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:145:27: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:145:13: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:147:27: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:147:13: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:169:19: warning: call to main actor-isolated instance method 'reloadHttp_notification' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:173:19: warning: call to main actor-isolated instance method 'deleteAllLogs_notification()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:177:19: warning: call to main actor-isolated instance method 'show_cocoadebug_force()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug+Extensions.swift:104:34: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashCell.swift:17:18: warning: main actor-isolated property 'isUserInteractionEnabled' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashCell.swift:17:9: warning: main actor-isolated property 'textview' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/Alamofire/Source/Core/DataStreamRequest.swift:165:21: warning: capture of 'stream' with non-Sendable type 'OutputStream' in a '@Sendable' closure | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:339:39: warning: capture of 'event' with non-Sendable type '(any EventMonitor) -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:339:39: warning: reference to captured parameter 'event' in concurrently-executing code | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:558:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/GitHubAPI.swift:49:21: warning: capture of 'completionHandler' with non-Sendable type '(Result<String, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListViewController.swift:143:28: warning: main actor-isolated property 'acknowledgementsPlistName' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListViewController.swift:147:13: warning: call to main actor-isolated instance method 'configure(with:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListViewController.swift:150:13: warning: call to main actor-isolated instance method 'configure(with:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:38:34: warning: call to main actor-isolated instance method 'open(_:options:completionHandler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:38:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:41:34: warning: call to main actor-isolated instance method 'openURL' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:41:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:110:9: warning: stored property 'prepare' of 'Sendable'-conforming class 'MoyaRequestInterceptor' is mutable; this is an error in the Swift 6 language mode | 基线已有 |
| Pods/Moya/Sources/Moya/MoyaError.swift:7:10: warning: associated value 'imageMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:10:10: warning: associated value 'jsonMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:13:10: warning: associated value 'stringMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:16:10: warning: associated value 'objectMapping' of 'Sendable'-conforming enum 'MoyaError' contains non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:22:10: warning: associated value 'statusCode' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:25:10: warning: associated value 'underlying' of 'Sendable'-conforming enum 'MoyaError' contains non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:162:27: warning: static property 'requestMethod' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:164:27: warning: static property 'requestBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:166:27: warning: static property 'requestHeaders' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:173:27: warning: static property 'formatRequestAscURL' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:175:27: warning: static property 'successResponseBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:177:27: warning: static property 'errorResponseBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:181:27: warning: static property 'default' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:183:27: warning: static property 'verbose' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:230:20: warning: static property 'defaultEntryDateFormatter' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxBlocking/Platform/DispatchQueue+Extensions.swift:12:24: warning: static property 'token' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxBlocking/RxBlocking/RunLoopLock.swift:19:9: warning: let 'runLoopModeRaw' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxBlocking/RxBlocking/RunLoopLock.swift:9:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'CoreFoundation' | 本轮新观察 |
| Pods/NSObject+Rx/HasDisposeBag.swift:5:17: warning: var 'disposeBagContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/NSObject+Rx/NSObject+Rx.swift:5:17: warning: var 'disposeBagContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:245:46: warning: converting non-Sendable function value to '@Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:255:84: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:259:78: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:263:76: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:85:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:89:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:99:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:103:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider.swift:145:46: warning: converting non-Sendable function value to '@Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider.swift:151:17: warning: capture of 'stub' with non-Sendable type '() -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/RequestTypeWrapper.swift:29:43: warning: passing non-Sendable parameter 'handler' to function expecting a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/URLRequest+Encoding.swift:23:61: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxy.swift:260:17: warning: let 'mainScheduler' is not concurrency-safe because non-'Sendable' type 'MainScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxy.swift:11:5: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:389:28: warning: static property '_sharedFactories' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/Platform/DispatchQueue+Extensions.swift:12:24: warning: static property 'token' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:18:13: warning: var 'deallocatingSubjectTriggerContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:19:13: warning: var 'deallocatingSubjectContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:21:13: warning: var 'deallocatedSubjectTriggerContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:22:13: warning: var 'deallocatedSubjectContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx+KVORepresentable.swift:24:23: warning: static property 'initial' is not concurrency-safe because non-'Sendable' type 'KeyValueObservingOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx+KVORepresentable.swift:26:23: warning: static property 'new' is not concurrency-safe because non-'Sendable' type 'KeyValueObservingOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:26:10: warning: associated value 'invalidOperation(object:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:28:10: warning: associated value 'itemsNotYetBound(object:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:30:10: warning: associated value 'invalidPropertyName(object:propertyName:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:32:10: warning: associated value 'invalidObjectOnKeyPath(object:sourceObject:propertyName:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:32:10: warning: associated value 'invalidObjectOnKeyPath(object:sourceObject:propertyName:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:36:10: warning: associated value 'castingError(object:targetType:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:27:14: warning: associated value 'unknown(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:54:14: warning: associated value 'objectMessagesAlreadyBeingIntercepted(target:interceptionMechanism:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:54:14: warning: associated value 'objectMessagesAlreadyBeingIntercepted(target:interceptionMechanism:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'RxCocoaInterceptionMechanism' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:57:14: warning: associated value 'selectorNotImplemented(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:64:14: warning: associated value 'cantInterceptCoreFoundationTollFreeBridgedObjects(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:71:14: warning: associated value 'threadingCollisionWithOtherInterceptionMechanism(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:74:14: warning: associated value 'savingOriginalForwardingMethodFailed(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:77:14: warning: associated value 'replacingMethodWithForwardingImplementation(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:84:14: warning: associated value 'observingPerformanceSensitiveMessages(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:91:14: warning: associated value 'observingMessagesWithUnsupportedReturnType(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourcePrefetchingProxy.swift:15:29: warning: conformance of 'UICollectionView' to protocol 'HasPrefetchDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourcePrefetchingProxy.swift:20:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourceProxy.swift:14:29: warning: conformance of 'UICollectionView' to protocol 'HasDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourceProxy.swift:18:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxCollectionViewReactiveArrayDataSource.swift:43:7: warning: conformance of 'RxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence>' to protocol 'RxCollectionViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxCollectionViewReactiveArrayDataSource.swift:62:7: warning: conformance of 'RxCollectionViewReactiveArrayDataSource<Element>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxNavigationControllerDelegateProxy.swift:14:39: warning: conformance of 'UINavigationController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxPickerViewAdapter.swift:14:73: warning: conformance of 'RxPickerViewArrayDataSource<T>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxPickerViewAdapter.swift:35:7: warning: conformance of 'RxPickerViewSequenceDataSource<Sequence>' to protocol 'RxPickerViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxPickerViewDataSourceProxy.swift:14:25: warning: conformance of 'UIPickerView' to protocol 'HasDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxPickerViewDataSourceProxy.swift:18:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxPickerViewDelegateProxy.swift:14:29: warning: conformance of 'UIPickerView' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:14:25: warning: conformance of 'UIScrollView' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxSearchBarDelegateProxy.swift:14:24: warning: conformance of 'UISearchBar' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxSearchControllerDelegateProxy.swift:14:31: warning: conformance of 'UISearchController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarControllerDelegateProxy.swift:14:31: warning: conformance of 'UITabBarController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarDelegateProxy.swift:14:21: warning: conformance of 'UITabBar' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourcePrefetchingProxy.swift:15:24: warning: conformance of 'UITableView' to protocol 'HasPrefetchDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourcePrefetchingProxy.swift:20:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourceProxy.swift:14:24: warning: conformance of 'UITableView' to protocol 'HasDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourceProxy.swift:18:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxTableViewReactiveArrayDataSource.swift:43:7: warning: conformance of 'RxTableViewReactiveArrayDataSourceSequenceWrapper<Sequence>' to protocol 'RxTableViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxTableViewReactiveArrayDataSource.swift:61:7: warning: conformance of 'RxTableViewReactiveArrayDataSource<Element>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Traits/SharedSequence/SchedulerType+SharedSequence.swift:13:36: warning: static property 'make' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:14:13: warning: var 'rx_tap_key' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/URLSession+Rx.swift:233:23: warning: static property 'shouldLogRequest' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:35:25: warning: call to main actor-isolated initializer 'init(tableView:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:36:25: warning: call to main actor-isolated initializer 'init(collectionView:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:37:25: warning: call to main actor-isolated initializer 'init(textView:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:49:72: warning: main actor-isolated property 'contentOffset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarDelegateProxy.swift:39:16: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarDelegateProxy.swift:44:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NotificationCenter+Rx.swift:23:17: warning: capture of 'observer' with non-Sendable type 'AnyObserver<Notification>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NotificationCenter+Rx.swift:10:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:87:17: warning: capture of 'observer' with non-Sendable type 'AnyObserver<Element>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:12:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:87:48: warning: capture of 'keyPath' with non-Sendable type 'KeyPath<Base, Element>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxWKNavigationDelegateProxy.swift:34:16: warning: main actor-isolated property 'navigationDelegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxWKNavigationDelegateProxy.swift:38:16: warning: main actor-isolated property 'navigationDelegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Traits/SharedSequence/SharedSequence+Concurrency.swift:36:21: warning: capture of 'disposable' with non-Sendable type 'any Disposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIActivityIndicatorView+Rx.swift:19:35: warning: call to main actor-isolated instance method 'startAnimating()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIActivityIndicatorView+Rx.swift:21:35: warning: call to main actor-isolated instance method 'stopAnimating()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:44:17: warning: call to main actor-isolated instance method 'addTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:79:23: warning: call to main actor-isolated instance method 'removeTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:44:17: warning: sending value of non-Sendable type 'ControlTarget' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:79:23: warning: sending value of non-Sendable type 'ControlTarget' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:328:27: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:330:28: warning: call to main actor-isolated instance method 'layoutIfNeeded()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:364:32: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:365:33: warning: call to main actor-isolated instance method 'layoutIfNeeded()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:24:34: warning: main actor-isolated property 'selectedSegmentIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:26:34: warning: main actor-isolated property 'selectedSegmentIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:34:30: warning: call to main actor-isolated instance method 'setEnabled(_:forSegmentAt:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:41:30: warning: call to main actor-isolated instance method 'setTitle(_:forSegmentAt:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:48:30: warning: call to main actor-isolated instance method 'setImage(_:forSegmentAt:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISlider+Rx.swift:20:24: warning: main actor-isolated property 'value' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISlider+Rx.swift:22:24: warning: main actor-isolated property 'value' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIStepper+Rx.swift:20:25: warning: main actor-isolated property 'value' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIStepper+Rx.swift:22:25: warning: main actor-isolated property 'value' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISwitch+Rx.swift:29:26: warning: main actor-isolated property 'isOn' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISwitch+Rx.swift:31:26: warning: main actor-isolated property 'isOn' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:48:92: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:84:92: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:86:35: warning: call to main actor-isolated instance method 'dequeueReusableCell(withIdentifier:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:48:92: warning: sending 'cellFactory' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:84:92: warning: sending value of non-Sendable type '(UITableView, Int, Sequence.Element) -> UITableViewCell' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:24:27: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:30:30: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:31:31: warning: main actor-isolated property 'text' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:41:27: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:47:30: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:48:31: warning: main actor-isolated property 'attributedText' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:23:34: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:25:41: warning: main actor-isolated property 'textStorage' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:35:38: warning: main actor-isolated property 'textStorage' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:47:25: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:48:26: warning: main actor-isolated property 'text' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:59:44: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:61:74: warning: main actor-isolated property 'textStorage' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:71:38: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:83:25: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:84:26: warning: main actor-isolated property 'attributedText' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/URLSession+Rx.swift:137:21: warning: capture of 'observer' with non-Sendable type 'AnyObserver<(response: HTTPURLResponse, data: Data)>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/URLSession+Rx.swift:10:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIApplication+Rx.swift:20:19: warning: main actor-isolated property 'isNetworkActivityIndicatorVisible' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:50:23: warning: main actor-isolated property 'target' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:51:23: warning: main actor-isolated property 'action' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:60:24: warning: main actor-isolated property 'target' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:61:24: warning: main actor-isolated property 'action' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:49:20: warning: call to main actor-isolated instance method 'setTitle(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:56:20: warning: call to main actor-isolated instance method 'setImage(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:63:20: warning: call to main actor-isolated instance method 'setBackgroundImage(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:78:24: warning: call to main actor-isolated instance method 'setAttributedTitle(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:47:93: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:83:97: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:85:35: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:47:93: warning: sending 'cellFactory' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:83:97: warning: sending value of non-Sendable type '(UICollectionView, Int, Sequence.Element) -> UICollectionViewCell' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:24:28: warning: main actor-isolated property 'date' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:26:28: warning: main actor-isolated property 'date' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:35:28: warning: main actor-isolated property 'countDownDuration' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:37:28: warning: main actor-isolated property 'countDownDuration' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:29:27: warning: call to main actor-isolated instance method 'addTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:46:33: warning: call to main actor-isolated instance method 'removeTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:29:27: warning: sending value of non-Sendable type 'GestureTarget<Recognizer>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:46:33: warning: sending value of non-Sendable type 'GestureTarget<Recognizer>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:73:50: warning: main actor-isolated property 'numberOfComponents' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:74:36: warning: call to main actor-isolated instance method 'selectedRow(inComponent:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:112:69: warning: call to main actor-isolated initializer 'init(titleForRow:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:145:79: warning: call to main actor-isolated initializer 'init(attributedTitleForRow:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:184:63: warning: call to main actor-isolated initializer 'init(viewForRow:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIRefreshControl+Rx.swift:19:32: warning: call to main actor-isolated instance method 'beginRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIRefreshControl+Rx.swift:21:32: warning: call to main actor-isolated instance method 'endRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIScrollView+Rx.swift:30:28: warning: main actor-isolated property 'contentOffset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:31:35: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:37:44: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:42:23: warning: main actor-isolated property 'text' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:51:33: warning: main actor-isolated property 'selectedScopeButtonIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:61:23: warning: main actor-isolated property 'selectedScopeButtonIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/IQTextView/IQTextView/Classes/IQTextView.swift:43:9: warning: call to main actor-isolated instance method 'setup()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/ThemeProxy.swift:24:13: warning: var 'ThemeProxyDisposablesHandle' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/CollectionViewSectionedDataSource.swift:20:7: warning: conformance of 'CollectionViewSectionedDataSource<Section>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxCollectionViewSectionedAnimatedDataSource.swift:20:7: warning: conformance of 'RxCollectionViewSectionedAnimatedDataSource<Section>' to protocol 'RxCollectionViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxCollectionViewSectionedReloadDataSource.swift:20:7: warning: conformance of 'RxCollectionViewSectionedReloadDataSource<Section>' to protocol 'RxCollectionViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxPickerViewAdapter.swift:224:35: warning: conformance of 'RxPickerViewDataSource<Components>' to protocol 'RxPickerViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxTableViewSectionedAnimatedDataSource.swift:20:7: warning: conformance of 'RxTableViewSectionedAnimatedDataSource<Section>' to protocol 'RxTableViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxTableViewSectionedReloadDataSource.swift:20:7: warning: conformance of 'RxTableViewSectionedReloadDataSource<Section>' to protocol 'RxTableViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/TableViewSectionedDataSource.swift:20:7: warning: conformance of 'TableViewSectionedDataSource<Section>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/UI+SectionedViewType.swift:22:25: warning: conformance of 'UITableView' to protocol 'SectionedViewType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/UI+SectionedViewType.swift:57:30: warning: conformance of 'UICollectionView' to protocol 'SectionedViewType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:20:22: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:25:35: warning: cannot form key path to main actor-isolated property 'font'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:35:22: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:40:35: warning: cannot form key path to main actor-isolated property 'textColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:49:18: warning: main actor-isolated property 'keyboardAppearance' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:53:35: warning: cannot form key path to main actor-isolated property 'keyboardAppearance'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:32:18: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:19:18: warning: main actor-isolated property 'backgroundColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'backgroundColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:32:18: warning: main actor-isolated property 'tintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'tintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:19:18: warning: main actor-isolated property 'progressTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'progressTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:32:18: warning: main actor-isolated property 'trackTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'trackTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:32:18: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:45:18: warning: main actor-isolated property 'keyboardAppearance' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:49:35: warning: cannot form key path to main actor-isolated property 'keyboardAppearance'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISegmentedControl+Theme.swift:20:18: warning: main actor-isolated property 'selectedSegmentTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISegmentedControl+Theme.swift:24:35: warning: cannot form key path to main actor-isolated property 'selectedSegmentTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:59:13: warning: var 'gestureRecognizerStrongDelegateKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITableView+Theme.swift:19:18: warning: main actor-isolated property 'separatorColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITableView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'separatorColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITAbleViewCell+Theme.swift:19:18: warning: main actor-isolated property 'selectionStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITAbleViewCell+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'selectionStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:20:22: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:25:35: warning: cannot form key path to main actor-isolated property 'font'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:35:22: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:40:35: warning: cannot form key path to main actor-isolated property 'textColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:49:18: warning: main actor-isolated property 'keyboardAppearance' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:53:35: warning: cannot form key path to main actor-isolated property 'keyboardAppearance'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIActivityIndicatorView+Theme.swift:19:18: warning: main actor-isolated property 'style' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIActivityIndicatorView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'style'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIBarButtonItem+Theme.swift:19:18: warning: main actor-isolated property 'tintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIBarButtonItem+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'tintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIButton+Theme.swift:19:18: warning: call to main actor-isolated instance method 'setTitleColor(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIButton+Theme.swift:28:14: warning: call to main actor-isolated instance method 'setTitleColor(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:19:18: warning: main actor-isolated property 'thumbTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'thumbTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:32:18: warning: main actor-isolated property 'minimumTrackTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'minimumTrackTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:45:18: warning: main actor-isolated property 'maximumTrackTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:49:35: warning: cannot form key path to main actor-isolated property 'maximumTrackTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:19:18: warning: main actor-isolated property 'onTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'onTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:32:18: warning: main actor-isolated property 'thumbTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'thumbTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:32:18: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:19:18: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'font'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:32:18: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'textColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:45:18: warning: main actor-isolated property 'highlightedTextColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:49:35: warning: cannot form key path to main actor-isolated property 'highlightedTextColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:58:18: warning: main actor-isolated property 'shadowColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:62:35: warning: cannot form key path to main actor-isolated property 'shadowColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:33:22: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:38:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:47:18: warning: main actor-isolated property 'titleTextAttributes' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:51:35: warning: cannot form key path to main actor-isolated property 'titleTextAttributes'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:61:18: warning: main actor-isolated property 'largeTitleTextAttributes' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:65:35: warning: cannot form key path to main actor-isolated property 'largeTitleTextAttributes'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:19:18: warning: main actor-isolated property 'pageIndicatorTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'pageIndicatorTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:32:18: warning: main actor-isolated property 'currentPageIndicatorTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'currentPageIndicatorTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:22:43: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:22:68: warning: main actor-isolated property 'contentInset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:22:97: warning: main actor-isolated property 'contentInset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:23:49: warning: main actor-isolated property 'contentInset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:24:51: warning: main actor-isolated property 'contentSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:22:30: warning: main actor-isolated property 'fractionComplete' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:34:18: warning: call to main actor-isolated instance method 'addCompletion' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:40:22: warning: call to main actor-isolated instance method 'startAnimation(afterDelay:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:42:22: warning: call to main actor-isolated instance method 'startAnimation()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:46:22: warning: call to main actor-isolated instance method 'stopAnimation' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:34:18: warning: sending value of non-Sendable type '(UIViewAnimatingPosition) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPanGestureRecognizer+RxGesture.swift:64:25: warning: call to main actor-isolated instance method 'translation(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPanGestureRecognizer+RxGesture.swift:65:25: warning: call to main actor-isolated instance method 'velocity(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPinchGestureRecognizer+RxGesture.swift:60:22: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPinchGestureRecognizer+RxGesture.swift:60:37: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIRotationGestureRecognizer+RxGesture.swift:60:22: warning: main actor-isolated property 'rotation' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIRotationGestureRecognizer+RxGesture.swift:60:40: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:57:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:59:44: warning: main actor-isolated property 'superview' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:59:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:62:48: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:62:42: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TouchDownGestureRecognizer.swift:132:23: warning: main actor-isolated property 'touches' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/View+RxGesture.swift:93:25: warning: main actor-isolated property 'isUserInteractionEnabled' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/View+RxGesture.swift:96:21: warning: call to main actor-isolated instance method 'addGestureRecognizer' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/View+RxGesture.swift:104:25: warning: reference to captured var 'control' in concurrently-executing code | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:30:23: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:31:66: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:38:17: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:37:37: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:49:37: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:60:21: warning: call to main actor-isolated instance method 'location(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:66:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:67:36: warning: call to main actor-isolated instance method 'location(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:69:28: warning: call to main actor-isolated instance method 'convert(_:to:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:59:49: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:60:61: warning: main actor-isolated property 'state' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:61:58: warning: main actor-isolated property 'state' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:68:51: warning: call to main actor-isolated instance method 'translation(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:71:55: warning: main actor-isolated property 'rotation' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:72:52: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:72:84: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:76:50: warning: call to main actor-isolated instance method 'velocity(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:77:52: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:78:46: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/ForceTouchGestureRecognizer.swift:99:23: warning: main actor-isolated property 'force' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/ForceTouchGestureRecognizer.swift:111:39: warning: main actor-isolated property 'fractionCompleted' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/ForceTouchGestureRecognizer.swift:113:39: warning: main actor-isolated property 'fractionCompleted' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UISwipeGestureRecognizer+RxGesture.swift:44:12: warning: main actor-isolated property 'direction' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/CollectionViewSectionedDataSource.swift:162:20: warning: main actor-isolated property 'configureSupplementaryView' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:29:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ModernLogging' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:103:40: warning: capture of 'completion' with non-Sendable type '(Result<URL, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:110:40: warning: capture of 'completion' with non-Sendable type '(Result<URL, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:116:13: warning: capture of 'logger' with non-Sendable type 'DDFileLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:2:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'CocoaLumberjack' | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:117:17: warning: capture of 'self' with non-Sendable type 'ModernLogging' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:119:48: warning: capture of 'completion' with non-Sendable type '(Result<URL, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:72: warning: capture of 'logger' with non-Sendable type 'DDFileLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:47: warning: capture of 'self' with non-Sendable type 'ModernLogging' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:47: warning: capture of 'self' with non-Sendable type 'ModernLogging' in an isolated closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:72: warning: capture of 'logger' with non-Sendable type 'DDFileLogger' in an isolated closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:46:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ModernNetworkLogger' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:74:13: warning: capture of 'self' with non-Sendable type 'ModernNetworkLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:82:19: warning: capture of 'self' with non-Sendable type 'ModernNetworkLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:90:43: warning: implicit capture of 'self' requires that 'ModernNetworkLogger' conforms to 'Sendable' | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:92:43: warning: implicit capture of 'self' requires that 'ModernNetworkLogger' conforms to 'Sendable' | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:97:77: warning: implicit capture of 'self' requires that 'ModernNetworkLogger' conforms to 'Sendable' | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:107:25: warning: capture of 'self' with non-Sendable type 'ModernNetworkLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:127:28: warning: implicit capture of 'self' requires that 'ModernNetworkLogger' conforms to 'Sendable' | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:127:52: warning: implicit capture of 'self' requires that 'ModernNetworkLogger' conforms to 'Sendable' | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:99:24: warning: capture of 'jumpType' with non-Sendable type 'LAJumpType' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:113:41: warning: capture of 'queries' with non-Sendable type '[String : Any]' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:61: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:42: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:35: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:52: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:123:80: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:125:38: warning: call to main actor-isolated instance method 'popToRootViewController(animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:236:16: warning: main actor-isolated property 'hidesBottomBarWhenPushed' can not be mutated from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:237:65: warning: call to main actor-isolated instance method 'pushViewController(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:237:43: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:276:76: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:278:37: warning: main actor-isolated property 'viewControllers' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:279:20: warning: call to main actor-isolated instance method 'popViewController(animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:290:61: warning: call to main actor-isolated instance method 'popToRootViewController(animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:290:39: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:296:28: warning: main actor-isolated property 'rootViewController' can not be mutated from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:305:80: warning: main actor-isolated property 'presentingViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:306:24: warning: call to main actor-isolated instance method 'dismiss(animated:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:315:43: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:315:36: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:315:70: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:316:37: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:318:25: warning: call to main actor-isolated instance method 'pushViewController(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:320:73: warning: call to main actor-isolated instance method 'pushViewController(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:320:51: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:328:34: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:338:56: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:338:49: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:342:23: warning: main actor-isolated property 'windowLevel' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:348:49: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:349:51: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:350:57: warning: main actor-isolated property 'next' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:357:52: warning: main actor-isolated property 'next' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:364:48: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:367:36: warning: main actor-isolated property 'presentedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:368:51: warning: main actor-isolated property 'presentedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:380:24: warning: main actor-isolated property 'visibleViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:390:56: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:390:49: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:394:23: warning: main actor-isolated property 'windowLevel' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:400:26: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:401:32: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:412:61: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:416:48: warning: main actor-isolated property 'next' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:424:33: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:425:16: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:425:26: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:426:26: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:426:36: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:428:24: warning: main actor-isolated property 'keyWindow' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:433:43: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:440:57: warning: main actor-isolated property 'selectedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:447:61: warning: main actor-isolated property 'topViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:456:26: warning: main actor-isolated property 'presentedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:125:38: warning: non-Sendable '[UIViewController]?'-typed result can not be returned from main actor-isolated instance method 'popToRootViewController(animated:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:290:61: warning: non-Sendable '[UIViewController]?'-typed result can not be returned from main actor-isolated instance method 'popToRootViewController(animated:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter.swift:42:23: warning: static property 'shareInstance' is not concurrency-safe because non-'Sendable' type 'TheRouter' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:25:23: warning: static property 'shareInstance' is not concurrency-safe because non-'Sendable' type 'TheRouterManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:60:16: warning: static property 'apiArray' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:61:16: warning: static property 'classMapArray' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:62:16: warning: static property 'registerRouterList' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:13:23: warning: static property 'default' is not concurrency-safe because non-'Sendable' type 'TheRouterServiceManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:38:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:38:39: warning: capture of 'creator' with non-Sendable type 'LAServiceCreator' (aka '() -> Any') in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:48:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:48:41: warning: capture of 'instance' with non-Sendable type 'Any' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:111:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:111:36: warning: capture of 'services' with non-Sendable type 'TheRouterServiceManager.BatchServiceMap' (aka 'Dictionary<String, () -> Any>') in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:139:17: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:139:45: warning: capture of 'service' with non-Sendable type 'Any' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:173:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Account/Manager/AccountManager.swift:49:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'AccountManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Account/Manager/AccountServiceContainer.swift:31:24: warning: static property '_current' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/BaseTableViewController.swift:139:36: warning: conformance of 'BaseTableViewController' to protocol 'DZNEmptyDataSetSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/BaseTableViewController.swift:159:36: warning: conformance of 'BaseTableViewController' to protocol 'DZNEmptyDataSetDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/BaseViewController.swift:145:31: warning: conformance of 'BaseViewController' to protocol 'LifetimeTrackable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/Setter.swift:76:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/Theme.swift:67:5: warning: let 'themeService' is not concurrency-safe because non-'Sendable' type 'ThemeService<ThemeType>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/Theme.swift:9:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxTheme' | 本轮新观察 |
| RxStudy/Constant/Constant.swift:20:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Constant/Constant.swift:26:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Constant/Constant.swift:29:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Constant/Constant.swift:32:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:56:23: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'NetworkActivityLogger' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/FSPagerView+RxSwift/RxFSPagerViewDelegateProxy.swift:13:24: warning: conformance of 'FSPagerView' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/MBProgressHUD+Extension.swift:11:26: warning: conformance of 'MBProgressHUD' to protocol 'HUD' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/RevealingSplashView/RevealingSplashView.swift:13:41: warning: conformance of 'RevealingSplashView' to protocol 'SplashAnimatable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/SVProgressHUD+Extension.swift:11:26: warning: conformance of 'SVProgressHUD' to protocol 'HUD' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:42:37: warning: static property 'storage' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:46:20: warning: static property 'myServiceYKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:50:23: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'NetworkMonitor' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/WebView+Extension.swift:14:14: warning: associated value 'genericConversionsFailed' of 'Sendable'-conforming enum 'RunJavaScriptError' contains non-Sendable type 'Any' | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:193:27: warning: conformance of 'HomeController' to protocol 'FSPagerViewDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:211:27: warning: conformance of 'HomeController' to protocol 'FSPagerViewDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:256:27: warning: conformance of 'HomeController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:259:29: warning: conformance of 'HotKeyController' to protocol 'TheRouterable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:277:23: warning: static property 'patternString' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:279:23: warning: static property 'routerClass' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:22:24: warning: static property 'activityCount' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:26:24: warning: static property 'targetTypeInterceptor' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:28:24: warning: static property 'beginLoadingCallback' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:30:24: warning: static property 'stopLoadingCallback' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:84:5: warning: let 'activityManagerPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkActivityPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:10:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:84:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:34:27: warning: static property 'all' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:36:27: warning: static property 'concise' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:38:27: warning: static property 'nothing' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:80:27: warning: static property 'haveNothing' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:83:27: warning: static property 'requestMethod' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:85:27: warning: static property 'requestBodyStream' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:87:27: warning: static property 'requestHeaders' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:89:27: warning: static property 'requestParameters' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:92:27: warning: static property 'responseBody' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:95:27: warning: static property 'request' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:97:27: warning: static property 'response' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:99:27: warning: static property 'all' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:101:27: warning: static property 'concise' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:103:27: warning: static property 'diversity' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:110:5: warning: let 'userDefaultsCache' is not concurrency-safe because non-'Sendable' type 'UserDefaults' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:21:5: warning: let 'networkRequestLoggerPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkRequestLoggerPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:24:5: warning: let 'loggerPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:11:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:27:5: warning: let 'debuggingPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:33:5: warning: let 'activityPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkActivityPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:33:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:66:5: warning: let 'responseInterceptorPlugin' is not concurrency-safe because non-'Sendable' type 'ResponseInterceptorPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:69:5: warning: let 'responseCachePlugin' is not concurrency-safe because non-'Sendable' type 'ResponseCachePlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:72:5: warning: let 'plugins' is not concurrency-safe because non-'Sendable' type '[any PluginType]' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:78:5: warning: let 'homeProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<HomeService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:81:5: warning: let 'myEndpointClosure' is not concurrency-safe because non-'Sendable' type '(MyService) -> Endpoint' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:86:5: warning: let 'myProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<MyService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:89:5: warning: let 'projectProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<ProjectService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:92:5: warning: let 'publicNumberProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<PublicNumberService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:95:5: warning: let 'treeProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<TreeService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:98:5: warning: let 'accountProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<AccountService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:101:5: warning: let 'otherProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<OtherService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:107:5: warning: let 'mockProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<MockService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:112:5: warning: let 'provider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<MultiTarget>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/InnerViewEvent/InnerEventResponsible.swift:23:19: warning: conformance of 'UIView' to protocol 'BubbleEventProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/InnerViewEvent/InnerEventResponsible.swift:38:29: warning: conformance of 'UIViewController' to protocol 'BubbleEventProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/LogUtils.swift:24:16: warning: static property 'logcat' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/My/Controller/MyController.swift:221:25: warning: conformance of 'MyController' to protocol 'InnerEventResponsible' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/My/Controller/MyController.swift:231:25: warning: conformance of 'MyController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/FooterKey.swift:23:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/FooterKey.swift:27:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/HeaderKey.swift:23:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/HeaderKey.swift:27:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Tabs/Controller/TabsController.swift:232:27: warning: conformance of 'TabsController' to protocol 'JXSegmentedViewDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Tabs/Controller/TabsController.swift:244:27: warning: conformance of 'TabsController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Tabs/Controller/TreeController.swift:207:27: warning: conformance of 'TreeController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:13:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'UniMPManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/WebView/Controller/DownloadWebController.swift:279:34: warning: conformance of 'DownloadWebController' to protocol 'UIDocumentInteractionControllerDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:594:30: warning: conformance of 'WebViewController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:27:21: warning: static property 'launchImagePlayAndroid' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:28:21: warning: static property 'android' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:29:21: warning: static property 'back' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:30:21: warning: static property 'collect' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:31:21: warning: static property 'collectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:32:21: warning: static property 'home' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:33:21: warning: static property 'homeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:34:21: warning: static property 'loading01' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:35:21: warning: static property 'loading02' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:36:21: warning: static property 'loading03' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:37:21: warning: static property 'loading04' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:38:21: warning: static property 'loading05' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:39:21: warning: static property 'loading06' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:40:21: warning: static property 'loading07' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:41:21: warning: static property 'loading08' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:42:21: warning: static property 'loading09' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:43:21: warning: static property 'loading10' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:44:21: warning: static property 'loading11' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:45:21: warning: static property 'loading12' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:46:21: warning: static property 'mainTheme' is not concurrency-safe because non-'Sendable' type 'ColorAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:47:21: warning: static property 'my' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:48:21: warning: static property 'mySelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:49:21: warning: static property 'notFound' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:50:21: warning: static property 'project' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:51:21: warning: static property 'projectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:52:21: warning: static property 'publicNumber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:53:21: warning: static property 'publicNumberSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:54:21: warning: static property 'saber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:55:21: warning: static property 'safari' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:56:21: warning: static property 'tree' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:57:21: warning: static property 'treeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:58:21: warning: static property 'user' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:59:21: warning: static property 'wanAndroidPlaceholder' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/CustomTabBarExample/CustomTabItem.swift:34:9: warning: call to main actor-isolated initializer 'init(item:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/CustomTabBarExample/CustomTabItem.swift:38:9: warning: call to main actor-isolated initializer 'init(with:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:108:37: warning: capture of 'notification' with non-Sendable type 'Notification' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:117:38: warning: capture of 'self' with non-Sendable type 'NetworkActivityLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:142:37: warning: capture of 'notification' with non-Sendable type 'Notification' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:152:38: warning: capture of 'self' with non-Sendable type 'NetworkActivityLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AppDelegate+Extension/AppDelegate+ScreenCapture.swift:31:30: warning: main actor-isolated property 'isCaptured' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/Extension/AppDelegate+Extension/AppDelegate+ScreenCapture.swift:31:25: warning: main actor-isolated class property 'main' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/Extension/MBProgressHUD+Extension.swift:128:36: warning: reference to captured var 'progress' in concurrently-executing code | 本轮新观察 |
| RxStudy/Extension/MBProgressHUD+Extension.swift:129:24: warning: reference to captured var 'progress' in concurrently-executing code | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/MJRefresh+RxSwift.swift:77:41: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/MJRefresh+RxSwift.swift:85:23: warning: main actor-isolated property 'state' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/RxDelegateTest/RxWebViewControllerDelegateProxy.swift:52:16: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/RxDelegateTest/RxWebViewControllerDelegateProxy.swift:56:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/View/SafariActivity.swift:44:46: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/View/SafariActivity.swift:45:34: warning: call to main actor-isolated instance method 'open(_:options:completionHandler:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/WebView/View/SafariActivity.swift:45:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:114:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:115:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: call to main actor-isolated instance method 'onChanged' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: sending value of non-Sendable type '(DragGesture.Value) -> ()' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: non-Sendable '_ChangedGesture<DragGesture>'-typed result can not be returned from main actor-isolated instance method 'onChanged' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/TabType.swift:25:20: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:27:20: warning: call to main actor-isolated initializer 'init(type:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:29:20: warning: call to main actor-isolated initializer 'init(type:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:31:20: warning: call to main actor-isolated initializer 'init(type:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:33:20: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Tabs/Controller/TreeController.swift:217:18: warning: call to main actor-isolated instance method 'tableViewSectionAndCellConfig(tabs:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Tabs/Controller/TreeController.swift:223:18: warning: call to main actor-isolated instance method 'tableViewSectionAndFlexLayoutCell(tabs:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:63:25: warning: capture of 'self' with non-Sendable type 'UniMPManager' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:64:25: warning: capture of 'callback' with non-Sendable type '((Result<DCUniMPInstance, any Error>) -> Void)?' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:93:13: warning: capture of 'self' with non-Sendable type 'UniMPManager?' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:109:20: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/ViewController.swift:206:22: warning: call to main actor-isolated instance method 'refreshChildren()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/ViewController.swift:267:16: warning: call to main actor-isolated instance method 'changeSelectedViewController(direction:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/DownloadWebController.swift:147:34: warning: reference to captured var 'self' in concurrently-executing code | 本轮新观察 |
| RxStudy/WebView/Controller/DownloadWebController.swift:230:27: warning: reference to captured var 'self' in concurrently-executing code | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:57: warning: call to main actor-isolated instance method 'removeScriptMessageHandler(forName:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:35: warning: main actor-isolated property 'userContentController' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:21: warning: main actor-isolated property 'configuration' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:13: warning: main actor-isolated property 'webView' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:601:18: warning: call to main actor-isolated instance method 'reload()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/CustomNetworkActivityPlugin.swift:34:47: warning: converting non-Sendable function value to '@MainActor @Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/CustomNetworkActivityPlugin.swift:46:47: warning: converting non-Sendable function value to '@MainActor @Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:137:20: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:54:13: warning: capture of 'self' with non-Sendable type 'NetworkRequestLoggerPlugin' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:57:37: warning: capture of 'request' with non-Sendable type 'any RequestType' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:12:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:89:20: warning: capture of 'result' with non-Sendable type 'Result<Response, MoyaError>' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:106:32: warning: capture of 'self' with non-Sendable type 'NetworkRequestLoggerPlugin' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:181:19: warning: capture of 'self' with non-Sendable type 'ResponseCachePlugin?' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:181:37: warning: capture of 'target' with non-Sendable type 'any TargetType' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:13:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:184:23: warning: capture of 'response' with non-Sendable type 'Response' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseInterceptorPlugin.swift:28:31: warning: call to main actor-isolated static method 'showText' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/AppIconSelectController.swift:138:18: warning: main actor-isolated property 'appProxy' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/My/Controller/AppIconSelectController.swift:138:53: warning: call to main actor-isolated instance method 'getLogoName()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/AppIconSelectController.swift:138:53: warning: non-Sendable 'String'-typed result can not be returned from main actor-isolated instance method 'getLogoName()' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/My/Controller/MyCollectionController.swift:197:18: warning: call to main actor-isolated instance method 'setEditing(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyCollectionController.swift:205:18: warning: main actor-isolated property 'rightBarButtonItem' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:53: warning: call to main actor-isolated instance method 'removeScriptMessageHandler(forName:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:31: warning: main actor-isolated property 'userContentController' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:17: warning: main actor-isolated property 'configuration' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:9: warning: main actor-isolated property 'webView' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/My/View/MessageCell.swift:67:18: warning: main actor-isolated property 'count' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/My/View/MyView.swift:87:20: warning: main actor-isolated property 'myCoin' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:41:41: warning: main actor-isolated property 'mj_header' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:42:28: warning: call to main actor-isolated instance method 'beginRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:45:41: warning: main actor-isolated property 'mj_header' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:46:28: warning: call to main actor-isolated instance method 'endRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:49:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:50:28: warning: call to main actor-isolated instance method 'beginRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:53:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:54:28: warning: call to main actor-isolated instance method 'endRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:57:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:58:28: warning: call to main actor-isolated instance method 'endRefreshingWithNoMoreData()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:61:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:62:28: warning: call to main actor-isolated instance method 'resetNoMoreData()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:23:27: warning: main actor-isolated property 'beginningOfDocument' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:24:25: warning: main actor-isolated property 'endOfDocument' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:26:36: warning: call to main actor-isolated instance method 'textRange(from:to:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:27:30: warning: call to main actor-isolated instance method 'text(in:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:31:43: warning: main actor-isolated property 'markedTextRange' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:35:38: warning: call to main actor-isolated instance method 'textRange(from:to:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:35:81: warning: main actor-isolated property 'start' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:36:34: warning: call to main actor-isolated instance method 'textRange(from:to:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:36:66: warning: main actor-isolated property 'end' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:23: warning: call to main actor-isolated instance method 'text(in:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:64: warning: call to main actor-isolated instance method 'text(in:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:27:30: warning: non-Sendable 'String?'-typed result can not be returned from main actor-isolated instance method 'text(in:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:23: warning: non-Sendable 'String?'-typed result can not be returned from main actor-isolated instance method 'text(in:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:64: warning: non-Sendable 'String?'-typed result can not be returned from main actor-isolated instance method 'text(in:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:8:49: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:15:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:21:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:27:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:33:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:70:15: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:76:81: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:76:108: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:84:48: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:89:49: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:119:31: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:124:77: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:124:104: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:133:25: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:137:46: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:144:31: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:149:77: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:149:104: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:157:25: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:163:47: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:201:15: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:206:81: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:206:108: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:214:68: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:225:64: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:233:49: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:239:45: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:264:40: warning: call to main actor-isolated instance method 'closestCommonSuperview' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:23:17: warning: capture of 'callback' with non-Sendable type '(Result<Void, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:24:17: warning: capture of 'request' with non-Sendable type 'NSBundleResourceRequest' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:95:13: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:95:34: warning: capture of 'listener' with non-Sendable type '(NetworkStatus) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:99:13: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:99:29: warning: capture of 'listener' with non-Sendable type '(NetworkStatus) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:108:13: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:144:30: warning: capture of 'self' with non-Sendable type 'NetworkMonitor?' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:151:17: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:151:41: warning: capture of 'newStatus' with non-Sendable type 'NetworkStatus' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:158:74: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in an isolated closure | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:84:23: warning: call to main actor-isolated class method 'dismiss()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:89:23: warning: call to main actor-isolated class method 'setDefaultMaskType' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:90:23: warning: call to main actor-isolated class method 'show()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:145:31: warning: call to main actor-isolated class method 'dismiss()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:172:48: warning: main actor-isolated property 'contentOffset' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:175:40: warning: call to main actor-isolated instance method 'setContentOffset(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:268:18: warning: call to main actor-isolated instance method 'tagLayout(hotKeys:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Home/Enum/OtherApp.swift:43:37: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Account/View/GrayView.swift:84:18: warning: call to main actor-isolated instance method 'grayMode(isGrayMode:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Account/View/GrayView.swift:90:18: warning: call to main actor-isolated instance method 'windowGrayMode(isGrayMode:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/BaseViewController.swift:260:20: warning: call to main actor-isolated instance method 'showErrorImage()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/BaseViewController.swift:262:20: warning: call to main actor-isolated instance method 'hiddenErrorImage()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Theme.swift:100:25: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Theme.swift:103:23: warning: call to main actor-isolated instance method 'notificationOccurred' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Theme.swift:105:23: warning: call to main actor-isolated instance method 'notificationOccurred' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Theme.swift:107:23: warning: call to main actor-isolated instance method 'notificationOccurred' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogRedactor.swift:112:22: warning: Optional Data -> String Conversion Violation: Prefer failable `String(bytes:encoding:)` initializer when converting `Data` to `String` (optional_data_string_conversion) | 基线已有 |

### RxStudy-Release settings：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

### RxStudy-Release build：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

成功标记：True；日志 `Derived/swift6-strict/RxStudy-Release-build.log`。

严格并发诊断分布（去重）：{'SwiftDate': 16, 'SnapKit': 68, 'MarqueeLabel': 5, 'PinLayout': 48, 'LifetimeTracker': 41, 'KeychainAccess': 15, 'RxSwift': 39, 'JXSegmentedView': 88, 'IQKeyboardNotification': 3, 'FunnyButton': 8, 'FSPagerView': 47, 'Differentiator': 3, 'CombineCocoa': 18, 'Alamofire': 6, 'CocoaDebug': 113, 'AcknowList': 8, 'RxBlocking': 3, 'NSObject+Rx': 2, 'RxCocoa': 145, 'IQTextView': 1, 'RxTheme': 77, 'RxSwiftExt': 11, 'RxGesture': 39, 'RxDataSources': 10, 'Moya': 28, 'RxStudy': 240, 'Packages': 72, 'Shared': 44}。

| 诊断依据（文件:行:列与原文） | 基线关系 |
| --- | --- |
| Pods/SwiftDate/Sources/SwiftDate/Supports/Commons.swift:145:20: warning: static property 'autoFormats' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Supports/Commons.swift:319:16: warning: static property 'appModule' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:27:21: warning: static property 'withYear' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:30:21: warning: static property 'withMonth' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:34:21: warning: static property 'withWeekOfYear' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:40:21: warning: static property 'withDay' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:43:21: warning: static property 'withTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:46:21: warning: static property 'withTimeZone' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:49:21: warning: static property 'withSpaceBetweenDateAndTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:52:21: warning: static property 'withDashSeparatorInDate' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:55:21: warning: static property 'withFullDate' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:58:21: warning: static property 'withFullTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:63:21: warning: static property 'withInternetDateTime' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:67:21: warning: static property 'withInternetDateTimeExtended' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/Formatters/ISOFormatter.swift:71:21: warning: static property 'withoutTZSeparators' is not concurrency-safe because non-'Sendable' type 'ISOFormatter.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SwiftDate/Sources/SwiftDate/SwiftDate.swift:22:20: warning: static property 'defaultRegion' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:63:37: warning: main actor-isolated property 'isActive' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:192:36: warning: call to main actor-isolated initializer 'init(item:attribute:relatedBy:toItem:attribute:multiplier:constant:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:203:30: warning: main actor-isolated property 'label' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:206:30: warning: main actor-isolated property 'priority' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:209:30: warning: main actor-isolated property 'constraint' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:294:47: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:294:102: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:294:136: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:295:30: warning: main actor-isolated property 'constant' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:298:34: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:299:34: warning: main actor-isolated property 'priority' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:323:69: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:323:130: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:323:170: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:324:40: warning: main actor-isolated property 'constant' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:327:32: warning: call to main actor-isolated class method 'activate' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:338:28: warning: call to main actor-isolated class method 'deactivate' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintConfig.swift:35:23: warning: static property 'interfaceLayoutDirection' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintDSL.swift:49:13: warning: var 'labelKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:56:30: warning: call to main actor-isolated instance method 'contentHuggingPriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:59:23: warning: call to main actor-isolated instance method 'setContentHuggingPriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:65:30: warning: call to main actor-isolated instance method 'contentHuggingPriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:68:23: warning: call to main actor-isolated instance method 'setContentHuggingPriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:74:30: warning: call to main actor-isolated instance method 'contentCompressionResistancePriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:77:23: warning: call to main actor-isolated instance method 'setContentCompressionResistancePriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:83:30: warning: call to main actor-isolated instance method 'contentCompressionResistancePriority(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/ConstraintViewDSL.swift:86:23: warning: call to main actor-isolated instance method 'setContentCompressionResistancePriority(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:37:59: warning: main actor-isolated property 'firstItem' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:41:17: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:42:61: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:45:56: warning: main actor-isolated property 'relation' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:47:34: warning: main actor-isolated property 'secondItem' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:51:17: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:52:61: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:55:17: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:56:39: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:59:17: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:60:37: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:62:21: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:63:43: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:64:28: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:65:47: warning: main actor-isolated property 'constant' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:69:17: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:70:38: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:156:28: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:158:28: warning: main actor-isolated property 'label' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:163:68: warning: main actor-isolated property 'constraint' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Debugging.swift:163:116: warning: main actor-isolated property 'constraint' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:51:15: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:51:37: warning: main actor-isolated property 'firstAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:52:15: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:52:38: warning: main actor-isolated property 'secondAttribute' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:53:15: warning: main actor-isolated property 'relation' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:53:31: warning: main actor-isolated property 'relation' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:54:15: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:54:31: warning: main actor-isolated property 'priority' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:55:15: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:55:33: warning: main actor-isolated property 'multiplier' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:56:15: warning: main actor-isolated property 'secondItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:56:34: warning: main actor-isolated property 'secondItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:57:15: warning: main actor-isolated property 'firstItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraint.swift:57:33: warning: main actor-isolated property 'firstItem' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:93:13: warning: var 'constraintsKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:46:18: warning: main actor-isolated property 'translatesAutoresizingMaskIntoConstraints' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:52:25: warning: main actor-isolated property 'superview' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/LayoutConstraintItem.swift:56:26: warning: main actor-isolated property 'owningView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:192:36: warning: sending value of non-Sendable type 'any LayoutConstraintItem' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/SnapKit/Sources/Constraint.swift:192:36: warning: sending value of non-Sendable type 'Any?' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:13:35: warning: conformance of 'MarqueeLabel' to protocol 'CAAnimationDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:1990:23: warning: static property 'leading' is not concurrency-safe because non-'Sendable' type 'EdgeFade' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:1991:23: warning: static property 'trailing' is not concurrency-safe because non-'Sendable' type 'EdgeFade' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:598:9: warning: call to main actor-isolated instance method 'forwardPropertiesToSublabel()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/MarqueeLabel/Sources/MarqueeLabel.swift:604:9: warning: call to main actor-isolated instance method 'forwardPropertiesToSublabel()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:26:14: warning: var 'displayScale' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:27:14: warning: var 'onePixelLength' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:114:30: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/Coordinates.swift:114:25: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Filters.swift:25:31: warning: main actor-isolated property 'isHidden' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Filters.swift:25:46: warning: main actor-isolated property 'alpha' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:23:29: warning: static property 'layoutDirection' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:27:29: warning: static property 'safeAreaInsetsDidChangeMode' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:34:24: warning: static property 'isInitialized' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:48:25: warning: static property 'autoSizingInProgress' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:56:33: warning: static property 'logWarnings' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:59:29: warning: static property 'activeWarnings' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:66:29: warning: static property 'logMissingLayoutCalls' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Pin.swift:69:29: warning: static property 'lastWarningText' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:91:29: warning: main actor-isolated property 'safeAreaInsets' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:93:29: warning: call to main actor-isolated instance method 'pinlayoutComputeSafeAreaInsets()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:104:53: warning: main actor-isolated property 'layoutFrame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:104:32: warning: main actor-isolated property 'readableContentGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:108:42: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:109:41: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:114:21: warning: main actor-isolated property 'layoutMargins' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:123:41: warning: main actor-isolated property 'layoutFrame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout.swift:123:21: warning: main actor-isolated property 'keyboardLayoutGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/PinLayout+Size.swift:151:41: warning: main actor-isolated property 'image' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinLayout+Warning.swift:26:13: warning: var 'numberFormatter' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:30:28: warning: static property 'currentSafeAreaInsetsDidChangeMode' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:33:25: warning: static property 'safeAreaInsetsDidChangeMode' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:126:16: warning: static property 'originalImplementation' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:192:20: warning: static property 'pinlayoutSafeAreaInsets' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:67:14: warning: main actor-isolated property 'pinlayoutSafeAreaInsets' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:70:29: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:83:63: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:84:45: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:84:65: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:158:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:162:72: warning: main actor-isolated property 'safeAreaInsets' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:162:67: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:163:79: warning: main actor-isolated property 'safeAreaInsets' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:163:74: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:165:67: warning: main actor-isolated property 'topLayoutGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:165:82: warning: main actor-isolated property 'length' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:166:70: warning: main actor-isolated property 'bottomLayoutGuide' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Impl/PinSafeArea.swift:166:88: warning: main actor-isolated property 'length' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:25:19: warning: conformance of 'UIView' to protocol 'Layoutable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:25:31: warning: conformance of 'UIView' to protocol 'SizeCalculable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:98:20: warning: static property 'pinlayoutAutoSizingRect' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:99:20: warning: static property 'pinlayoutAutoSizingRectWithMargins' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/PinLayout/Sources/Extensions/UIView+PinLayout.swift:96:19: warning: conformance of 'UIView' to protocol 'AutoSizeCalculable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/BarDashboard/BarDashboardViewController.swift:32:59: warning: conformance of 'BarDashboardViewController' to protocol 'LifetimeTrackerViewable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:23:58: warning: conformance of 'CircularDashboardViewController' to protocol 'LifetimeTrackerViewable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:230:44: warning: conformance of 'CircularDashboardViewController' to protocol 'PopoverViewControllerDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:225:32: warning: main actor-isolated property 'isHidden' can not be mutated from a Sendable closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/CircularDashboard/CircularDashboardViewController.swift:225:18: warning: main actor-isolated property 'popoverWindow' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/LifetimeTracker.swift:119:37: warning: static property 'instance' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:67:22: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:43:58: warning: call to main actor-isolated class method 'makeFromNib()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:44:68: warning: call to main actor-isolated class method 'makeFromNib()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:105:13: warning: capture of 'self' with non-Sendable type 'LifetimeTrackerDashboardIntegration' in a '@Sendable' closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/UI/LifetimeTracker+DashboardView.swift:105:117: warning: capture of 'trackedGroups' with non-Sendable type '[String : LifetimeTracker.EntriesGroup]' in a '@Sendable' closure | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:17:42: warning: main actor-isolated property 'popoverPresentationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:18:31: warning: main actor-isolated property 'sourceView' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:19:31: warning: main actor-isolated property 'sourceRect' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:19:59: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:19:80: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:20:31: warning: main actor-isolated property 'permittedArrowDirections' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:25:21: warning: call to main actor-isolated initializer 'init(title:message:preferredStyle:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:26:15: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:26:25: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:27:25: warning: call to main actor-isolated initializer 'init(title:message:preferredStyle:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:28:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:28:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:31:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:31:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:34:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:34:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:37:19: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:37:29: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:40:62: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:41:28: warning: call to main actor-isolated instance method 'present(_:animated:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:43:15: warning: call to main actor-isolated instance method 'addAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:43:25: warning: call to main actor-isolated initializer 'init(title:style:handler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:47:58: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:49:24: warning: call to main actor-isolated instance method 'present(_:animated:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:26:25: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:43:25: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:28:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:31:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:34:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/LifetimeTracker/Sources/iOS/SettingsManager.swift:37:29: warning: sending value of non-Sendable type '(UIAlertAction) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:216:23: warning: static property 'userPresence' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:224:23: warning: static property 'biometryAny' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:233:23: warning: static property 'touchIDAny' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:240:23: warning: static property 'biometryCurrentSet' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:249:23: warning: static property 'touchIDCurrentSet' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:255:23: warning: static property 'devicePasscode' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:264:23: warning: static property 'watch' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:271:23: warning: static property 'or' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:278:23: warning: static property 'and' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:284:23: warning: static property 'privateKeyUsage' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:291:23: warning: static property 'applicationPassword' is not concurrency-safe because non-'Sendable' type 'AuthenticationPolicy' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:1259:13: warning: let 'SynchronizableAny' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:1263:13: warning: let 'MatchLimitOne' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:1264:13: warning: let 'MatchLimitAll' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/KeychainAccess/Lib/KeychainAccess/Keychain.swift:715:63: warning: reference to var 'NSFoundationVersionNumber' is not concurrency-safe because it involves shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Disposables/BooleanDisposable.swift:12:25: warning: static property 'BooleanDisposableTrue' is not concurrency-safe because non-'Sendable' type 'BooleanDisposable' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:36:23: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'ConcurrentMainScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:53:16: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:57:34: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/ConcurrentMainScheduler.swift:57:41: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:18:20: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'CurrentThreadSchedulerQueueKey' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:42:23: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'CurrentThreadScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:44:24: warning: static property 'isScheduleRequiredKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/CurrentThreadScheduler.swift:55:24: warning: static property 'scheduleInProgressSentinel' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/Platform/DispatchQueue+Extensions.swift:12:24: warning: static property 'token' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/Internal/DispatchQueueConfiguration.swift:22:16: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/Internal/DispatchQueueConfiguration.swift:27:34: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/Internal/DispatchQueueConfiguration.swift:27:41: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Errors.swift:19:10: warning: associated value 'disposed(object:)' of 'Sendable'-conforming enum 'RxError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/Infallible/Infallible+Concurrency.swift:31:21: warning: capture of 'disposable' with non-Sendable type 'any Disposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:37:23: warning: static property 'instance' is not concurrency-safe because non-'Sendable' type 'MainScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:41:23: warning: static property 'asyncInstance' is not concurrency-safe because non-'Sendable' type 'SerialDispatchQueueScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:71:17: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:72:38: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:72:45: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/MainScheduler.swift:75:23: warning: capture of 'self' with non-Sendable type 'MainScheduler' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Disposables/NopDisposable.swift:14:28: warning: static property 'noOp' is not concurrency-safe because non-'Sendable' type 'any Disposable' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:48:21: warning: capture of 'disposable' with non-Sendable type 'any Disposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:65:44: warning: capture of non-Sendable type 'Self.AsyncIterator.Type' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:65:44: warning: capture of non-Sendable type 'Self.Type' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/ObservableType+Extensions.swift:137:24: warning: static property '_defaultErrorHandler' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/ObservableType+Extensions.swift:146:24: warning: static property '_customCaptureSubscriptionCallstack' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/OperationQueueScheduler.swift:39:16: warning: capture of 'cancel' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/OperationQueueScheduler.swift:44:34: warning: capture of 'action' with non-Sendable type '(StateType) -> any Disposable' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Schedulers/OperationQueueScheduler.swift:44:41: warning: capture of 'state' with non-Sendable type 'StateType' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:84:21: warning: capture of 'disposable' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:141:21: warning: capture of 'disposable' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:190:21: warning: capture of 'disposable' with non-Sendable type 'SingleAssignmentDisposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Rx.swift:140:23: warning: static property 'recordCallStackOnError' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Disposables/ScheduledDisposable.swift:9:13: warning: let 'disposeScheduledDisposable' is not concurrency-safe because non-'Sendable' type '(ScheduledDisposable) -> any Disposable' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Observable+Concurrency.swift:63:24: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:37:22: warning: sending value of non-Sendable type '() async throws -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:39:17: warning: sending value of non-Sendable type '() async throws -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwift/RxSwift/Traits/PrimitiveSequence/PrimitiveSequence+Concurrency.swift:121:50: warning: sending value of non-Sendable type 'Self.Element' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:118:16: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:137:71: warning: call to main actor-isolated instance method 'invalidateLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:137:50: warning: main actor-isolated property 'collectionViewLayout' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:137:35: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:161:63: warning: call to main actor-isolated instance method 'invalidateLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:161:42: warning: main actor-isolated property 'collectionViewLayout' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:161:27: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseDataSource.swift:171:40: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Dot/JXSegmentedDotDataSource.swift:47:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Dot/JXSegmentedDotDataSource.swift:47:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Dot/JXSegmentedDotDataSource.swift:51:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Indicator/JXSegmentedIndicatorBaseView.swift:17:50: warning: conformance of 'JXSegmentedIndicatorBaseView' to protocol 'JXSegmentedIndicatorProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedListContainerView.swift:60:50: warning: conformance of 'JXSegmentedListContainerView' to protocol 'JXSegmentedViewListContainer' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Number/JXSegmentedNumberDataSource.swift:57:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Number/JXSegmentedNumberDataSource.swift:57:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Number/JXSegmentedNumberDataSource.swift:61:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:20:23: warning: call to main actor-isolated class method 'userInterfaceLayoutDirection(for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:20:77: warning: main actor-isolated property 'semanticContentAttribute' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:20:64: warning: call to main actor-isolated class method 'appearance()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Common/JXSegmentedRTLLayout.swift:26:15: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/AttributeTitle/JXSegmentedTitleAttributeDataSource.swift:69:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/AttributeTitle/JXSegmentedTitleAttributeDataSource.swift:69:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/AttributeTitle/JXSegmentedTitleAttributeDataSource.swift:73:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Title/JXSegmentedTitleDataSource.swift:108:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Title/JXSegmentedTitleDataSource.swift:108:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Title/JXSegmentedTitleDataSource.swift:112:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleGradient/JXSegmentedTitleGradientDataSource.swift:45:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleGradient/JXSegmentedTitleGradientDataSource.swift:45:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleGradient/JXSegmentedTitleGradientDataSource.swift:49:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleImage/JXSegmentedTitleImageDataSource.swift:105:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleImage/JXSegmentedTitleImageDataSource.swift:105:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleImage/JXSegmentedTitleImageDataSource.swift:109:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleOrImage/JXSegmentedTitleOrImageDataSource.swift:43:38: warning: call to main actor-isolated instance method 'register(_:forCellWithReuseIdentifier:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleOrImage/JXSegmentedTitleOrImageDataSource.swift:43:23: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/TitleOrImage/JXSegmentedTitleOrImageDataSource.swift:47:34: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:35: warning: main actor-isolated property 'isTracking' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:16: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:76: warning: main actor-isolated property 'isDecelerating' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:422:57: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:424:39: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:424:20: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:428:67: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:428:48: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:429:36: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:433:44: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:433:66: warning: main actor-isolated property 'lastContentOffset' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:60: warning: main actor-isolated property 'contentSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:41: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:99: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:437:80: warning: main actor-isolated property 'contentScrollView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:438:60: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:438:77: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:438:105: warning: main actor-isolated property 'lastContentOffset' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:443:47: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:447:37: warning: call to main actor-isolated instance method 'getItemFrameAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:448:38: warning: call to main actor-isolated instance method 'getItemFrameAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:450:36: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:451:45: warning: main actor-isolated property 'dataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:453:98: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:456:98: warning: main actor-isolated property 'dataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:465:26: warning: main actor-isolated property 'lastContentOffset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:465:68: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:466:25: warning: call to main actor-isolated instance method 'scrollSelectItemAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:470:47: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:472:47: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:475:25: warning: call to main actor-isolated instance method 'scrollSelectItemAt(index:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:477:24: warning: main actor-isolated property 'selectedIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:478:25: warning: main actor-isolated property 'scrollingTargetIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:480:25: warning: main actor-isolated property 'scrollingTargetIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:483:21: warning: main actor-isolated property 'dataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:483:71: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:483:114: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:485:38: warning: main actor-isolated property 'indicators' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:488:77: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:490:29: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:492:78: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:494:29: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:498:51: warning: call to main actor-isolated instance method 'cellForItem(at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:498:36: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:499:31: warning: call to main actor-isolated instance method 'reloadData(itemModel:selectedType:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:499:53: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:501:52: warning: call to main actor-isolated instance method 'cellForItem(at:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:501:37: warning: main actor-isolated property 'collectionView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:502:32: warning: call to main actor-isolated instance method 'reloadData(itemModel:selectedType:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:502:54: warning: main actor-isolated property 'itemDataSource' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:504:21: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedView.swift:507:13: warning: main actor-isolated property 'lastContentOffset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/JXSegmentedView/Sources/Core/JXSegmentedBaseCell.swift:19:17: warning: cannot access property 'animator' with a non-Sendable type 'JXSegmentedAnimator?' from nonisolated deinit; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/IQKeyboardNotification/IQKeyboardNotification/Classes/IQKeyboardInfo.swift:90:35: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/IQKeyboardNotification/IQKeyboardNotification/Classes/IQKeyboardInfo.swift:92:42: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/IQKeyboardNotification/IQKeyboardNotification/Classes/IQKeyboardInfo.swift:92:37: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:61:21: warning: call to main actor-isolated static method 'replaceAction' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:66:21: warning: call to main actor-isolated static method 'replaceActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:71:21: warning: call to main actor-isolated static method 'addActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:76:21: warning: call to main actor-isolated static method 'addActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:81:21: warning: call to main actor-isolated static method 'removeActions(where:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:86:21: warning: call to main actor-isolated static method 'replaceActions' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:91:21: warning: call to main actor-isolated static method 'updateLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FunnyButton/FunnyButton/Classes/FunnyButton+API.swift:71:21: warning: sending value of non-Sendable type '[FunnyAction]' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerView.swift:310:29: warning: main actor-isolated property 'dataSource' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerView.swift:311:29: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewCell.swift:143:23: warning: main actor-isolated property 'kvoContext' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewCell.swift:145:22: warning: call to main actor-isolated instance method 'setNeedsLayout()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewLayoutAttributes.swift:20:36: warning: main actor-isolated property 'position' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewLayoutAttributes.swift:20:55: warning: main actor-isolated property 'position' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:50:35: warning: main actor-isolated property 'position' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:51:41: warning: main actor-isolated property 'scrollDirection' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:52:72: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:52:98: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:73:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:74:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:75:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:90:49: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:94:49: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:106:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:107:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:147:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:148:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:149:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:157:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:159:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:161:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:174:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:175:24: warning: main actor-isolated property 'transform3D' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:186:46: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:200:24: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:201:24: warning: main actor-isolated property 'transform' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:202:24: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:206:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:208:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:209:28: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:212:74: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:212:100: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:218:32: warning: main actor-isolated property 'center' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:223:32: warning: main actor-isolated property 'center' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:227:28: warning: main actor-isolated property 'transform3D' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:229:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:231:28: warning: main actor-isolated property 'alpha' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:232:28: warning: main actor-isolated property 'zIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:242:41: warning: main actor-isolated property 'scrollDirection' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:248:30: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:253:30: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:258:31: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:263:31: warning: main actor-isolated property 'itemSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPageViewTransformer.swift:269:26: warning: main actor-isolated property 'interitemSpacing' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/FSPagerView/Sources/FSPagerViewCell.swift:112:73: warning: cannot access property 'kvoContext' with a non-Sendable type 'UnsafeMutableRawPointer?' from nonisolated deinit; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Differentiator/Sources/Differentiator/Diff.swift:25:14: warning: associated value 'duplicateItem(item:)' of 'Sendable'-conforming enum 'Error' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/Differentiator/Sources/Differentiator/Diff.swift:26:14: warning: associated value 'duplicateSection(section:)' of 'Sendable'-conforming enum 'Error' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/Differentiator/Sources/Differentiator/Diff.swift:27:14: warning: associated value 'invalidInitializerImplementation(section:expectedItems:expectedIdentifier:)' of 'Sendable'-conforming enum 'Error' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:75:28: warning: call to main actor-isolated class method 'animate(withDuration:delay:options:animations:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:91:24: warning: call to main actor-isolated class method 'transition(with:duration:options:animations:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlEvent.swift:57:21: warning: call to main actor-isolated instance method 'addTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:68:21: warning: call to main actor-isolated instance method 'addTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:86:22: warning: call to main actor-isolated instance method 'removeTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/DelegateProxy/DelegateProxyType.swift:12:13: warning: var 'associatedKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UICollectionView+Combine.swift:87:85: warning: conformance of 'CollectionViewDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UIGestureRecognizer+Combine.swift:78:41: warning: call to main actor-isolated instance method 'addTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UIGestureRecognizer+Combine.swift:81:42: warning: call to main actor-isolated instance method 'removeTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UIScrollView+Combine.swift:141:77: warning: conformance of 'ScrollViewDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UISearchBar+Combine.swift:49:77: warning: conformance of 'UISearchBarDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/Controls/UITableView+Combine.swift:127:75: warning: conformance of 'TableViewDelegateProxy' to protocol 'DelegateProxyType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:75:28: warning: sending value of non-Sendable type '() -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:75:28: warning: sending value of non-Sendable type '((Bool) -> Void)?' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/AnimatedAssignSubscriber.swift:91:24: warning: sending value of non-Sendable type '() -> ()' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlEvent.swift:57:21: warning: sending value of non-Sendable type 'Publishers.ControlEvent<Control>.Subscription<S, Control>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:68:21: warning: sending value of non-Sendable type 'Publishers.ControlProperty<Control, Value>.Subscription<S, Control, Value>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CombineCocoa/Sources/CombineCocoa/CombineControlProperty.swift:86:22: warning: sending value of non-Sendable type 'Publishers.ControlProperty<Control, Value>.Subscription<S, Control, Value>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Core/DataStreamRequest.swift:165:21: warning: capture of 'stream' with non-Sendable type 'OutputStream' in a '@Sendable' closure | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:339:39: warning: capture of 'event' with non-Sendable type '(any EventMonitor) -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:339:39: warning: reference to captured parameter 'event' in concurrently-executing code | 本轮新观察 |
| Pods/Alamofire/Source/Features/ResponseSerialization.swift:360:20: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Features/ResponseSerialization.swift:360:20: warning: type 'JSONResponseSerializer.SerializedObject' (aka 'Any') does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:558:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Logs/_SwiftLogHelper.swift:15:29: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type '_SwiftLogHelper' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:17:13: warning: var '_successStatusCodes' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:18:13: warning: var '_informationalStatusCodes' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:19:13: warning: var '_redirectionStatusCodes' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:21:13: warning: var '_width' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:22:13: warning: var '_height' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:169:19: warning: call to main actor-isolated instance method 'reloadHttp_notification' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:173:19: warning: call to main actor-isolated instance method 'deleteAllLogs_notification()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/Bubble.swift:177:19: warning: call to main actor-isolated instance method 'show_cocoadebug_force()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:15:29: warning: static property 'serverURL' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:17:29: warning: static property 'ignoredURLs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:19:29: warning: static property 'onlyURLs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:21:29: warning: static property 'ignoredPrefixLogs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:23:29: warning: static property 'onlyPrefixLogs' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:25:29: warning: static property 'additionalViewController' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:27:29: warning: static property 'emailToRecipients' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:29:29: warning: static property 'emailCcRecipients' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:31:29: warning: static property 'mainColor' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug.swift:33:29: warning: static property 'protobufTransferMap' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebug+Extensions.swift:104:34: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:13:29: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CocoaDebugSettings' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:18:53: warning: main actor-isolated property 'layer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:18:38: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:18:31: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:20:53: warning: main actor-isolated property 'layer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:20:38: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:20:31: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:110:51: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:110:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:111:55: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:111:48: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:115:38: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:115:33: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:82: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:116:77: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:118:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:118:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:124:38: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:124:33: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:82: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:125:77: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:127:51: warning: main actor-isolated property 'frame' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Core/CocoaDebugSettings.swift:127:44: warning: main actor-isolated property 'bubble' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/CocoaDebugViewController.swift:60:37: warning: conformance of 'CocoaDebugViewController' to protocol 'BubbleDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/CocoaDebugWindow.swift:37:24: warning: call to main actor-isolated instance method 'shouldReceive(point:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashCell.swift:17:18: warning: main actor-isolated property 'isUserInteractionEnabled' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashCell.swift:17:9: warning: main actor-isolated property 'textview' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashLogger.swift:48:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CrashLogger' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/App/CrashStoreManager.swift:15:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CrashStoreManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Logs/LogViewController.swift:287:19: warning: call to main actor-isolated instance method 'refreshLogs_notification()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:130:20: warning: main actor-isolated property 'backgroundColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:130:9: warning: main actor-isolated property 'imageLabel' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:131:29: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:131:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:133:29: warning: main actor-isolated property 'textContainer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:133:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:134:29: warning: main actor-isolated property 'textContainerInset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:134:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:135:29: warning: main actor-isolated property 'isSelectable' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:135:9: warning: main actor-isolated property 'requestTimeTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:137:28: warning: main actor-isolated property 'textContainer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:137:9: warning: main actor-isolated property 'requestUrlTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:138:28: warning: main actor-isolated property 'textContainerInset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:138:9: warning: main actor-isolated property 'requestUrlTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:139:28: warning: main actor-isolated property 'isSelectable' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:139:9: warning: main actor-isolated property 'requestUrlTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:141:23: warning: main actor-isolated property 'textAlignment' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:141:9: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:142:23: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:142:9: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:143:23: warning: main actor-isolated property 'adjustsFontSizeToFitWidth' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:143:9: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:145:27: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:145:13: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:147:27: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkCell.swift:147:13: warning: main actor-isolated property 'leftAlignLine' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:69:18: warning: call to main actor-isolated instance method 'addGestureRecognizer' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:69:9: warning: main actor-isolated property 'editView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:69:62: warning: call to main actor-isolated initializer 'init(target:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:71:25: warning: main actor-isolated property 'textContainer' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:71:9: warning: main actor-isolated property 'contentTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:72:25: warning: main actor-isolated property 'textContainerInset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailCell.swift:72:9: warning: main actor-isolated property 'contentTextView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkDetailViewController.swift:13:59: warning: conformance of 'NetworkDetailViewController' to protocol 'MFMailComposeViewControllerDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkViewController.swift:102:19: warning: call to main actor-isolated instance method 'reloadHttp(needScrollToEnd:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Network/NetworkViewController.swift:102:53: warning: main actor-isolated property 'reachEnd' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:47:36: warning: main actor-isolated property 'text' can not be mutated from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:47:19: warning: main actor-isolated property 'uiBlockingLabel' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:48:36: warning: main actor-isolated property 'textColor' can not be mutated from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/UIBlockingBubble.swift:48:19: warning: main actor-isolated property 'uiBlockingLabel' can not be referenced from a Sendable closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:12:23: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'WindowHelper' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:16:14: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:24:18: warning: call to main actor-isolated initializer 'init(frame:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:24:56: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:24:51: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:26:16: warning: main actor-isolated property 'bounds' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:26:51: warning: main actor-isolated property 'bounds' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:26:46: warning: main actor-isolated class property 'main' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:34:19: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:38:16: warning: main actor-isolated property 'rootViewController' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:39:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:40:16: warning: main actor-isolated property 'isHidden' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:56:29: warning: capture of 'self' with non-Sendable type 'WindowHelper?' in a '@Sendable' closure | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:52:24: warning: reference to captured var 'success' in concurrently-executing code | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:57:29: warning: mutation of captured var 'success' in concurrently-executing code | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:67:19: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:70:16: warning: main actor-isolated property 'rootViewController' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:71:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/CocoaDebug/Sources/Window/WindowHelper.swift:72:16: warning: main actor-isolated property 'isHidden' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:38:34: warning: call to main actor-isolated instance method 'open(_:options:completionHandler:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:38:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:41:34: warning: call to main actor-isolated instance method 'openURL' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListURL.swift:41:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListViewController.swift:143:28: warning: main actor-isolated property 'acknowledgementsPlistName' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListViewController.swift:147:13: warning: call to main actor-isolated instance method 'configure(with:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/AcknowListViewController.swift:150:13: warning: call to main actor-isolated instance method 'configure(with:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/AcknowList/Sources/AcknowList/GitHubAPI.swift:49:21: warning: capture of 'completionHandler' with non-Sendable type '(Result<String, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxBlocking/Platform/DispatchQueue+Extensions.swift:12:24: warning: static property 'token' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxBlocking/RxBlocking/RunLoopLock.swift:19:9: warning: let 'runLoopModeRaw' is not concurrency-safe because non-'Sendable' type 'CFString' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxBlocking/RxBlocking/RunLoopLock.swift:9:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'CoreFoundation' | 本轮新观察 |
| Pods/NSObject+Rx/HasDisposeBag.swift:5:17: warning: var 'disposeBagContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/NSObject+Rx/NSObject+Rx.swift:5:17: warning: var 'disposeBagContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:44:17: warning: call to main actor-isolated instance method 'addTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:79:23: warning: call to main actor-isolated instance method 'removeTarget(_:action:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxy.swift:260:17: warning: let 'mainScheduler' is not concurrency-safe because non-'Sendable' type 'MainScheduler' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxy.swift:11:5: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:389:28: warning: static property '_sharedFactories' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:328:27: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:330:28: warning: call to main actor-isolated instance method 'layoutIfNeeded()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:364:32: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/DelegateProxyType.swift:365:33: warning: call to main actor-isolated instance method 'layoutIfNeeded()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/Platform/DispatchQueue+Extensions.swift:12:24: warning: static property 'token' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NotificationCenter+Rx.swift:23:17: warning: capture of 'observer' with non-Sendable type 'AnyObserver<Notification>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NotificationCenter+Rx.swift:10:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:18:13: warning: var 'deallocatingSubjectTriggerContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:19:13: warning: var 'deallocatingSubjectContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:21:13: warning: var 'deallocatedSubjectTriggerContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:22:13: warning: var 'deallocatedSubjectContext' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:87:17: warning: capture of 'observer' with non-Sendable type 'AnyObserver<Element>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:12:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx.swift:87:48: warning: capture of 'keyPath' with non-Sendable type 'KeyPath<Base, Element>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx+KVORepresentable.swift:24:23: warning: static property 'initial' is not concurrency-safe because non-'Sendable' type 'KeyValueObservingOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/NSObject+Rx+KVORepresentable.swift:26:23: warning: static property 'new' is not concurrency-safe because non-'Sendable' type 'KeyValueObservingOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:26:10: warning: associated value 'invalidOperation(object:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:28:10: warning: associated value 'itemsNotYetBound(object:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:30:10: warning: associated value 'invalidPropertyName(object:propertyName:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:32:10: warning: associated value 'invalidObjectOnKeyPath(object:sourceObject:propertyName:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:32:10: warning: associated value 'invalidObjectOnKeyPath(object:sourceObject:propertyName:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/RxCocoa.swift:36:10: warning: associated value 'castingError(object:targetType:)' of 'Sendable'-conforming enum 'RxCocoaError' contains non-Sendable type 'Any' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:27:14: warning: associated value 'unknown(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:54:14: warning: associated value 'objectMessagesAlreadyBeingIntercepted(target:interceptionMechanism:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:54:14: warning: associated value 'objectMessagesAlreadyBeingIntercepted(target:interceptionMechanism:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'RxCocoaInterceptionMechanism' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:57:14: warning: associated value 'selectorNotImplemented(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:64:14: warning: associated value 'cantInterceptCoreFoundationTollFreeBridgedObjects(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:71:14: warning: associated value 'threadingCollisionWithOtherInterceptionMechanism(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:74:14: warning: associated value 'savingOriginalForwardingMethodFailed(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:77:14: warning: associated value 'replacingMethodWithForwardingImplementation(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:84:14: warning: associated value 'observingPerformanceSensitiveMessages(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/RxCocoaObjCRuntimeError+Extensions.swift:91:14: warning: associated value 'observingMessagesWithUnsupportedReturnType(target:)' of 'Sendable'-conforming enum 'RxCocoaObjCRuntimeError' contains non-Sendable type 'AnyObject' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourcePrefetchingProxy.swift:15:29: warning: conformance of 'UICollectionView' to protocol 'HasPrefetchDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourcePrefetchingProxy.swift:20:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourceProxy.swift:14:29: warning: conformance of 'UICollectionView' to protocol 'HasDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxCollectionViewDataSourceProxy.swift:18:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxCollectionViewReactiveArrayDataSource.swift:43:7: warning: conformance of 'RxCollectionViewReactiveArrayDataSourceSequenceWrapper<Sequence>' to protocol 'RxCollectionViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxCollectionViewReactiveArrayDataSource.swift:62:7: warning: conformance of 'RxCollectionViewReactiveArrayDataSource<Element>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxNavigationControllerDelegateProxy.swift:14:39: warning: conformance of 'UINavigationController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxPickerViewAdapter.swift:14:73: warning: conformance of 'RxPickerViewArrayDataSource<T>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxPickerViewAdapter.swift:35:7: warning: conformance of 'RxPickerViewSequenceDataSource<Sequence>' to protocol 'RxPickerViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxPickerViewDataSourceProxy.swift:14:25: warning: conformance of 'UIPickerView' to protocol 'HasDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxPickerViewDataSourceProxy.swift:18:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxPickerViewDelegateProxy.swift:14:29: warning: conformance of 'UIPickerView' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:14:25: warning: conformance of 'UIScrollView' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:35:25: warning: call to main actor-isolated initializer 'init(tableView:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:36:25: warning: call to main actor-isolated initializer 'init(collectionView:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:37:25: warning: call to main actor-isolated initializer 'init(textView:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxScrollViewDelegateProxy.swift:49:72: warning: main actor-isolated property 'contentOffset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxSearchBarDelegateProxy.swift:14:24: warning: conformance of 'UISearchBar' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxSearchControllerDelegateProxy.swift:14:31: warning: conformance of 'UISearchController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarControllerDelegateProxy.swift:14:31: warning: conformance of 'UITabBarController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarDelegateProxy.swift:14:21: warning: conformance of 'UITabBar' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarDelegateProxy.swift:39:16: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTabBarDelegateProxy.swift:44:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourcePrefetchingProxy.swift:15:24: warning: conformance of 'UITableView' to protocol 'HasPrefetchDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourcePrefetchingProxy.swift:20:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourceProxy.swift:14:24: warning: conformance of 'UITableView' to protocol 'HasDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxTableViewDataSourceProxy.swift:18:13: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxTableViewReactiveArrayDataSource.swift:43:7: warning: conformance of 'RxTableViewReactiveArrayDataSourceSequenceWrapper<Sequence>' to protocol 'RxTableViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/DataSources/RxTableViewReactiveArrayDataSource.swift:61:7: warning: conformance of 'RxTableViewReactiveArrayDataSource<Element>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxWKNavigationDelegateProxy.swift:34:16: warning: main actor-isolated property 'navigationDelegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/Proxies/RxWKNavigationDelegateProxy.swift:38:16: warning: main actor-isolated property 'navigationDelegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Traits/SharedSequence/SchedulerType+SharedSequence.swift:13:36: warning: static property 'make' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Traits/SharedSequence/SharedSequence+Concurrency.swift:36:21: warning: capture of 'disposable' with non-Sendable type 'any Disposable' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIActivityIndicatorView+Rx.swift:19:35: warning: call to main actor-isolated instance method 'startAnimating()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIActivityIndicatorView+Rx.swift:21:35: warning: call to main actor-isolated instance method 'stopAnimating()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIApplication+Rx.swift:20:19: warning: main actor-isolated property 'isNetworkActivityIndicatorVisible' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:14:13: warning: var 'rx_tap_key' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:50:23: warning: main actor-isolated property 'target' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:51:23: warning: main actor-isolated property 'action' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:60:24: warning: main actor-isolated property 'target' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIBarButtonItem+Rx.swift:61:24: warning: main actor-isolated property 'action' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:49:20: warning: call to main actor-isolated instance method 'setTitle(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:56:20: warning: call to main actor-isolated instance method 'setImage(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:63:20: warning: call to main actor-isolated instance method 'setBackgroundImage(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIButton+Rx.swift:78:24: warning: call to main actor-isolated instance method 'setAttributedTitle(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:47:93: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:83:97: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:85:35: warning: call to main actor-isolated instance method 'dequeueReusableCell(withReuseIdentifier:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:24:28: warning: main actor-isolated property 'date' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:26:28: warning: main actor-isolated property 'date' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:35:28: warning: main actor-isolated property 'countDownDuration' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIDatePicker+Rx.swift:37:28: warning: main actor-isolated property 'countDownDuration' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:29:27: warning: call to main actor-isolated instance method 'addTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:46:33: warning: call to main actor-isolated instance method 'removeTarget(_:action:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:73:50: warning: main actor-isolated property 'numberOfComponents' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:74:36: warning: call to main actor-isolated instance method 'selectedRow(inComponent:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:112:69: warning: call to main actor-isolated initializer 'init(titleForRow:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:145:79: warning: call to main actor-isolated initializer 'init(attributedTitleForRow:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIPickerView+Rx.swift:184:63: warning: call to main actor-isolated initializer 'init(viewForRow:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIRefreshControl+Rx.swift:19:32: warning: call to main actor-isolated instance method 'beginRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIRefreshControl+Rx.swift:21:32: warning: call to main actor-isolated instance method 'endRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIScrollView+Rx.swift:30:28: warning: main actor-isolated property 'contentOffset' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:31:35: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:37:44: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:42:23: warning: main actor-isolated property 'text' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:51:33: warning: main actor-isolated property 'selectedScopeButtonIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISearchBar+Rx.swift:61:23: warning: main actor-isolated property 'selectedScopeButtonIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:24:34: warning: main actor-isolated property 'selectedSegmentIndex' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:26:34: warning: main actor-isolated property 'selectedSegmentIndex' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:34:30: warning: call to main actor-isolated instance method 'setEnabled(_:forSegmentAt:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:41:30: warning: call to main actor-isolated instance method 'setTitle(_:forSegmentAt:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISegmentedControl+Rx.swift:48:30: warning: call to main actor-isolated instance method 'setImage(_:forSegmentAt:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISlider+Rx.swift:20:24: warning: main actor-isolated property 'value' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISlider+Rx.swift:22:24: warning: main actor-isolated property 'value' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIStepper+Rx.swift:20:25: warning: main actor-isolated property 'value' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIStepper+Rx.swift:22:25: warning: main actor-isolated property 'value' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISwitch+Rx.swift:29:26: warning: main actor-isolated property 'isOn' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UISwitch+Rx.swift:31:26: warning: main actor-isolated property 'isOn' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:48:92: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:84:92: warning: call to main actor-isolated initializer 'init(cellFactory:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:86:35: warning: call to main actor-isolated instance method 'dequeueReusableCell(withIdentifier:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:24:27: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:30:30: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:31:31: warning: main actor-isolated property 'text' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:41:27: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:47:30: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextField+Rx.swift:48:31: warning: main actor-isolated property 'attributedText' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:23:34: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:25:41: warning: main actor-isolated property 'textStorage' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:35:38: warning: main actor-isolated property 'textStorage' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:47:25: warning: main actor-isolated property 'text' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:48:26: warning: main actor-isolated property 'text' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:59:44: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:61:74: warning: main actor-isolated property 'textStorage' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:71:38: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:83:25: warning: main actor-isolated property 'attributedText' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITextView+Rx.swift:84:26: warning: main actor-isolated property 'attributedText' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/URLSession+Rx.swift:233:23: warning: static property 'shouldLogRequest' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/URLSession+Rx.swift:137:21: warning: capture of 'observer' with non-Sendable type 'AnyObserver<(response: HTTPURLResponse, data: Data)>' in a '@Sendable' closure | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Foundation/URLSession+Rx.swift:10:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxSwift' | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:44:17: warning: sending value of non-Sendable type 'ControlTarget' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/Common/ControlTarget.swift:79:23: warning: sending value of non-Sendable type 'ControlTarget' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:46:33: warning: sending value of non-Sendable type 'GestureTarget<Recognizer>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:47:93: warning: sending 'cellFactory' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UICollectionView+Rx.swift:83:97: warning: sending value of non-Sendable type '(UICollectionView, Int, Sequence.Element) -> UICollectionViewCell' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UIGestureRecognizer+Rx.swift:29:27: warning: sending value of non-Sendable type 'GestureTarget<Recognizer>' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:48:92: warning: sending 'cellFactory' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxCocoa/RxCocoa/iOS/UITableView+Rx.swift:84:92: warning: sending value of non-Sendable type '(UITableView, Int, Sequence.Element) -> UITableViewCell' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/IQTextView/IQTextView/Classes/IQTextView.swift:43:9: warning: call to main actor-isolated instance method 'setup()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/ThemeProxy.swift:24:13: warning: var 'ThemeProxyDisposablesHandle' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIActivityIndicatorView+Theme.swift:19:18: warning: main actor-isolated property 'style' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIActivityIndicatorView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'style'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIBarButtonItem+Theme.swift:19:18: warning: main actor-isolated property 'tintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIBarButtonItem+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'tintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIButton+Theme.swift:19:18: warning: call to main actor-isolated instance method 'setTitleColor(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIButton+Theme.swift:28:14: warning: call to main actor-isolated instance method 'setTitleColor(_:for:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:19:18: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'font'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:32:18: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'textColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:45:18: warning: main actor-isolated property 'highlightedTextColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:49:35: warning: cannot form key path to main actor-isolated property 'highlightedTextColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:58:18: warning: main actor-isolated property 'shadowColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UILabel+Theme.swift:62:35: warning: cannot form key path to main actor-isolated property 'shadowColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:33:22: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:38:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:47:18: warning: main actor-isolated property 'titleTextAttributes' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:51:35: warning: cannot form key path to main actor-isolated property 'titleTextAttributes'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:61:18: warning: main actor-isolated property 'largeTitleTextAttributes' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UINavigationBar+Theme.swift:65:35: warning: cannot form key path to main actor-isolated property 'largeTitleTextAttributes'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:19:18: warning: main actor-isolated property 'pageIndicatorTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'pageIndicatorTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:32:18: warning: main actor-isolated property 'currentPageIndicatorTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIPageControl+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'currentPageIndicatorTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:19:18: warning: main actor-isolated property 'progressTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'progressTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:32:18: warning: main actor-isolated property 'trackTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIProgressView+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'trackTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:32:18: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:45:18: warning: main actor-isolated property 'keyboardAppearance' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISearchBar+Theme.swift:49:35: warning: cannot form key path to main actor-isolated property 'keyboardAppearance'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISegmentedControl+Theme.swift:20:18: warning: main actor-isolated property 'selectedSegmentTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISegmentedControl+Theme.swift:24:35: warning: cannot form key path to main actor-isolated property 'selectedSegmentTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:19:18: warning: main actor-isolated property 'thumbTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'thumbTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:32:18: warning: main actor-isolated property 'minimumTrackTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'minimumTrackTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:45:18: warning: main actor-isolated property 'maximumTrackTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISlider+Theme.swift:49:35: warning: cannot form key path to main actor-isolated property 'maximumTrackTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:19:18: warning: main actor-isolated property 'onTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'onTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:32:18: warning: main actor-isolated property 'thumbTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UISwitch+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'thumbTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:32:18: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITabBar+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITableView+Theme.swift:19:18: warning: main actor-isolated property 'separatorColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITableView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'separatorColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITAbleViewCell+Theme.swift:19:18: warning: main actor-isolated property 'selectionStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITAbleViewCell+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'selectionStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:20:22: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:25:35: warning: cannot form key path to main actor-isolated property 'font'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:35:22: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:40:35: warning: cannot form key path to main actor-isolated property 'textColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:49:18: warning: main actor-isolated property 'keyboardAppearance' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextField+Theme.swift:53:35: warning: cannot form key path to main actor-isolated property 'keyboardAppearance'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:20:22: warning: main actor-isolated property 'font' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:25:35: warning: cannot form key path to main actor-isolated property 'font'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:35:22: warning: main actor-isolated property 'textColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:40:35: warning: cannot form key path to main actor-isolated property 'textColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:49:18: warning: main actor-isolated property 'keyboardAppearance' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UITextView+Theme.swift:53:35: warning: cannot form key path to main actor-isolated property 'keyboardAppearance'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:19:18: warning: main actor-isolated property 'barStyle' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'barStyle'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:32:18: warning: main actor-isolated property 'barTintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIToolbar+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'barTintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:19:18: warning: main actor-isolated property 'backgroundColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:23:35: warning: cannot form key path to main actor-isolated property 'backgroundColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:32:18: warning: main actor-isolated property 'tintColor' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxTheme/Sources/Extensions/UIView+Theme.swift:36:35: warning: cannot form key path to main actor-isolated property 'tintColor'; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:22:43: warning: main actor-isolated property 'frame' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:22:68: warning: main actor-isolated property 'contentInset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:22:97: warning: main actor-isolated property 'contentInset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:23:49: warning: main actor-isolated property 'contentInset' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIScrollView+reachedBottom.swift:24:51: warning: main actor-isolated property 'contentSize' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:22:30: warning: main actor-isolated property 'fractionComplete' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:34:18: warning: call to main actor-isolated instance method 'addCompletion' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:40:22: warning: call to main actor-isolated instance method 'startAnimation(afterDelay:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:42:22: warning: call to main actor-isolated instance method 'startAnimation()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:46:22: warning: call to main actor-isolated instance method 'stopAnimation' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxSwiftExt/Source/RxCocoa/UIViewPropertyAnimator+Rx.swift:34:18: warning: sending value of non-Sendable type '(UIViewAnimatingPosition) -> Void' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/ForceTouchGestureRecognizer.swift:99:23: warning: main actor-isolated property 'force' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/ForceTouchGestureRecognizer.swift:111:39: warning: main actor-isolated property 'fractionCompleted' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/ForceTouchGestureRecognizer.swift:113:39: warning: main actor-isolated property 'fractionCompleted' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:59:13: warning: var 'gestureRecognizerStrongDelegateKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:30:23: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:31:66: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureFactory.swift:38:17: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:37:37: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:49:37: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:60:21: warning: call to main actor-isolated instance method 'location(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:66:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:67:36: warning: call to main actor-isolated instance method 'location(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/GestureRecognizer+RxGesture.swift:69:28: warning: call to main actor-isolated instance method 'convert(_:to:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:57:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:59:44: warning: main actor-isolated property 'superview' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:59:38: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:62:48: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/SharedTypes.swift:62:42: warning: main actor-isolated property 'view' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TouchDownGestureRecognizer.swift:132:23: warning: main actor-isolated property 'touches' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:59:49: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:60:61: warning: main actor-isolated property 'state' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:61:58: warning: main actor-isolated property 'state' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:68:51: warning: call to main actor-isolated instance method 'translation(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:71:55: warning: main actor-isolated property 'rotation' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:72:52: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:72:84: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:76:50: warning: call to main actor-isolated instance method 'velocity(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:77:52: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/TransformGestureRecognizers.swift:78:46: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPanGestureRecognizer+RxGesture.swift:64:25: warning: call to main actor-isolated instance method 'translation(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPanGestureRecognizer+RxGesture.swift:65:25: warning: call to main actor-isolated instance method 'velocity(in:)' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPinchGestureRecognizer+RxGesture.swift:60:22: warning: main actor-isolated property 'scale' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIPinchGestureRecognizer+RxGesture.swift:60:37: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIRotationGestureRecognizer+RxGesture.swift:60:22: warning: main actor-isolated property 'rotation' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UIRotationGestureRecognizer+RxGesture.swift:60:40: warning: main actor-isolated property 'velocity' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/iOS/UISwipeGestureRecognizer+RxGesture.swift:44:12: warning: main actor-isolated property 'direction' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/View+RxGesture.swift:93:25: warning: main actor-isolated property 'isUserInteractionEnabled' can not be mutated from a nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/View+RxGesture.swift:96:21: warning: call to main actor-isolated instance method 'addGestureRecognizer' in a synchronous nonisolated context | 本轮新观察 |
| Pods/RxGesture/Pod/Classes/View+RxGesture.swift:104:25: warning: reference to captured var 'control' in concurrently-executing code | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/CollectionViewSectionedDataSource.swift:20:7: warning: conformance of 'CollectionViewSectionedDataSource<Section>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/CollectionViewSectionedDataSource.swift:162:20: warning: main actor-isolated property 'configureSupplementaryView' can not be referenced from a nonisolated context | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxCollectionViewSectionedAnimatedDataSource.swift:20:7: warning: conformance of 'RxCollectionViewSectionedAnimatedDataSource<Section>' to protocol 'RxCollectionViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxCollectionViewSectionedReloadDataSource.swift:20:7: warning: conformance of 'RxCollectionViewSectionedReloadDataSource<Section>' to protocol 'RxCollectionViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxPickerViewAdapter.swift:224:35: warning: conformance of 'RxPickerViewDataSource<Components>' to protocol 'RxPickerViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxTableViewSectionedAnimatedDataSource.swift:20:7: warning: conformance of 'RxTableViewSectionedAnimatedDataSource<Section>' to protocol 'RxTableViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/RxTableViewSectionedReloadDataSource.swift:20:7: warning: conformance of 'RxTableViewSectionedReloadDataSource<Section>' to protocol 'RxTableViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/TableViewSectionedDataSource.swift:20:7: warning: conformance of 'TableViewSectionedDataSource<Section>' to protocol 'SectionedViewDataSourceType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/UI+SectionedViewType.swift:22:25: warning: conformance of 'UITableView' to protocol 'SectionedViewType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/RxDataSources/Sources/RxDataSources/UI+SectionedViewType.swift:57:30: warning: conformance of 'UICollectionView' to protocol 'SectionedViewType' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:110:9: warning: stored property 'prepare' of 'Sendable'-conforming class 'MoyaRequestInterceptor' is mutable; this is an error in the Swift 6 language mode | 基线已有 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:85:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:89:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:99:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:103:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:7:10: warning: associated value 'imageMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:10:10: warning: associated value 'jsonMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:13:10: warning: associated value 'stringMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:16:10: warning: associated value 'objectMapping' of 'Sendable'-conforming enum 'MoyaError' contains non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:22:10: warning: associated value 'statusCode' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:25:10: warning: associated value 'underlying' of 'Sendable'-conforming enum 'MoyaError' contains non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider.swift:145:46: warning: converting non-Sendable function value to '@Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider.swift:151:17: warning: capture of 'stub' with non-Sendable type '() -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:245:46: warning: converting non-Sendable function value to '@Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:255:84: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:259:78: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:263:76: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:162:27: warning: static property 'requestMethod' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:164:27: warning: static property 'requestBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:166:27: warning: static property 'requestHeaders' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:173:27: warning: static property 'formatRequestAscURL' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:175:27: warning: static property 'successResponseBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:177:27: warning: static property 'errorResponseBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:181:27: warning: static property 'default' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:183:27: warning: static property 'verbose' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:230:20: warning: static property 'defaultEntryDateFormatter' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/RequestTypeWrapper.swift:29:43: warning: passing non-Sendable parameter 'handler' to function expecting a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/URLRequest+Encoding.swift:23:61: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:29:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ModernLogging' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:103:40: warning: capture of 'completion' with non-Sendable type '(Result<URL, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:110:40: warning: capture of 'completion' with non-Sendable type '(Result<URL, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:116:13: warning: capture of 'logger' with non-Sendable type 'DDFileLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:2:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'CocoaLumberjack' | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:117:17: warning: capture of 'self' with non-Sendable type 'ModernLogging' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:119:48: warning: capture of 'completion' with non-Sendable type '(Result<URL, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:72: warning: capture of 'logger' with non-Sendable type 'DDFileLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:47: warning: capture of 'self' with non-Sendable type 'ModernLogging' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:47: warning: capture of 'self' with non-Sendable type 'ModernLogging' in an isolated closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogging.swift:118:72: warning: capture of 'logger' with non-Sendable type 'DDFileLogger' in an isolated closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:46:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ModernNetworkLogger' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:74:13: warning: capture of 'self' with non-Sendable type 'ModernNetworkLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:82:19: warning: capture of 'self' with non-Sendable type 'ModernNetworkLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Log/Modern/ModernNetworkLogger.swift:107:25: warning: capture of 'self' with non-Sendable type 'ModernNetworkLogger' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:99:24: warning: capture of 'jumpType' with non-Sendable type 'LAJumpType' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:113:41: warning: capture of 'queries' with non-Sendable type '[String : Any]' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:61: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:42: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:35: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:121:52: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:123:80: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:125:38: warning: call to main actor-isolated instance method 'popToRootViewController(animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:236:16: warning: main actor-isolated property 'hidesBottomBarWhenPushed' can not be mutated from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:237:65: warning: call to main actor-isolated instance method 'pushViewController(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:237:43: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:276:76: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:278:37: warning: main actor-isolated property 'viewControllers' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:279:20: warning: call to main actor-isolated instance method 'popViewController(animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:290:61: warning: call to main actor-isolated instance method 'popToRootViewController(animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:290:39: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:296:28: warning: main actor-isolated property 'rootViewController' can not be mutated from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:305:80: warning: main actor-isolated property 'presentingViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:306:24: warning: call to main actor-isolated instance method 'dismiss(animated:completion:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:315:43: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:315:36: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:315:70: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:316:37: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:318:25: warning: call to main actor-isolated instance method 'pushViewController(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:320:73: warning: call to main actor-isolated instance method 'pushViewController(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:320:51: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:328:34: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:338:56: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:338:49: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:342:23: warning: main actor-isolated property 'windowLevel' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:348:49: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated autoclosure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:349:51: warning: main actor-isolated property 'subviews' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:350:57: warning: main actor-isolated property 'next' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:357:52: warning: main actor-isolated property 'next' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:364:48: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:367:36: warning: main actor-isolated property 'presentedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:368:51: warning: main actor-isolated property 'presentedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:380:24: warning: main actor-isolated property 'visibleViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:390:56: warning: main actor-isolated property 'windows' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:390:49: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:394:23: warning: main actor-isolated property 'windowLevel' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:400:26: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:401:32: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:412:61: warning: main actor-isolated property 'navigationController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:416:48: warning: main actor-isolated property 'next' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:424:33: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:425:16: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:425:26: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:426:26: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:426:36: warning: main actor-isolated property 'window' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:428:24: warning: main actor-isolated property 'keyWindow' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:433:43: warning: main actor-isolated property 'rootViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:440:57: warning: main actor-isolated property 'selectedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:447:61: warning: main actor-isolated property 'topViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:456:26: warning: main actor-isolated property 'presentedViewController' can not be referenced from a nonisolated context | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter.swift:42:23: warning: static property 'shareInstance' is not concurrency-safe because non-'Sendable' type 'TheRouter' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:25:23: warning: static property 'shareInstance' is not concurrency-safe because non-'Sendable' type 'TheRouterManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:60:16: warning: static property 'apiArray' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:61:16: warning: static property 'classMapArray' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterManager.swift:62:16: warning: static property 'registerRouterList' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:13:23: warning: static property 'default' is not concurrency-safe because non-'Sendable' type 'TheRouterServiceManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:38:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:38:39: warning: capture of 'creator' with non-Sendable type 'LAServiceCreator' (aka '() -> Any') in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:48:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:48:41: warning: capture of 'instance' with non-Sendable type 'Any' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:111:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:111:36: warning: capture of 'services' with non-Sendable type 'TheRouterServiceManager.BatchServiceMap' (aka 'Dictionary<String, () -> Any>') in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:139:17: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:139:45: warning: capture of 'service' with non-Sendable type 'Any' in a '@Sendable' closure | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouterServiceManager.swift:173:13: warning: capture of 'self' with non-Sendable type 'TheRouterServiceManager' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Account/Manager/AccountManager.swift:49:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'AccountManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Account/Manager/AccountServiceContainer.swift:31:24: warning: static property '_current' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Account/View/GrayView.swift:84:18: warning: call to main actor-isolated instance method 'grayMode(isGrayMode:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Account/View/GrayView.swift:90:18: warning: call to main actor-isolated instance method 'windowGrayMode(isGrayMode:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/BaseTableViewController.swift:139:36: warning: conformance of 'BaseTableViewController' to protocol 'DZNEmptyDataSetSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/BaseTableViewController.swift:159:36: warning: conformance of 'BaseTableViewController' to protocol 'DZNEmptyDataSetDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/BaseViewController.swift:260:20: warning: call to main actor-isolated instance method 'showErrorImage()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/BaseViewController.swift:262:20: warning: call to main actor-isolated instance method 'hiddenErrorImage()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Setter.swift:76:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/Theme.swift:67:5: warning: let 'themeService' is not concurrency-safe because non-'Sendable' type 'ThemeService<ThemeType>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Base/Theme.swift:9:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'RxTheme' | 本轮新观察 |
| RxStudy/Base/Theme.swift:100:25: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Theme.swift:103:23: warning: call to main actor-isolated instance method 'notificationOccurred' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Theme.swift:105:23: warning: call to main actor-isolated instance method 'notificationOccurred' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Base/Theme.swift:107:23: warning: call to main actor-isolated instance method 'notificationOccurred' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Constant/Constant.swift:20:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Constant/Constant.swift:26:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Constant/Constant.swift:29:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Constant/Constant.swift:32:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/CustomTabBarExample/CustomTabItem.swift:34:9: warning: call to main actor-isolated initializer 'init(item:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/CustomTabBarExample/CustomTabItem.swift:38:9: warning: call to main actor-isolated initializer 'init(with:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:56:23: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'NetworkActivityLogger' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:108:37: warning: capture of 'notification' with non-Sendable type 'Notification' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:117:38: warning: capture of 'self' with non-Sendable type 'NetworkActivityLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:142:37: warning: capture of 'notification' with non-Sendable type 'Notification' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift:152:38: warning: capture of 'self' with non-Sendable type 'NetworkActivityLogger' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/AppDelegate+Extension/AppDelegate+ScreenCapture.swift:31:30: warning: main actor-isolated property 'isCaptured' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/Extension/AppDelegate+Extension/AppDelegate+ScreenCapture.swift:31:25: warning: main actor-isolated class property 'main' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/Extension/FSPagerView+RxSwift/RxFSPagerViewDelegateProxy.swift:13:24: warning: conformance of 'FSPagerView' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/MBProgressHUD+Extension.swift:11:26: warning: conformance of 'MBProgressHUD' to protocol 'HUD' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/MBProgressHUD+Extension.swift:128:36: warning: reference to captured var 'progress' in concurrently-executing code | 本轮新观察 |
| RxStudy/Extension/MBProgressHUD+Extension.swift:129:24: warning: reference to captured var 'progress' in concurrently-executing code | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/MJRefresh+RxSwift.swift:77:41: warning: main actor-isolated property 'state' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/MJRefresh+RxSwift.swift:85:23: warning: main actor-isolated property 'state' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:41:41: warning: main actor-isolated property 'mj_header' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:42:28: warning: call to main actor-isolated instance method 'beginRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:45:41: warning: main actor-isolated property 'mj_header' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:46:28: warning: call to main actor-isolated instance method 'endRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:49:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:50:28: warning: call to main actor-isolated instance method 'beginRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:53:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:54:28: warning: call to main actor-isolated instance method 'endRefreshing()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:57:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:58:28: warning: call to main actor-isolated instance method 'endRefreshingWithNoMoreData()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:61:41: warning: main actor-isolated property 'mj_footer' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/MJRefresh+RxSwift/UIScrollView+RxSwift.swift:62:28: warning: call to main actor-isolated instance method 'resetNoMoreData()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/RevealingSplashView/RevealingSplashView.swift:13:41: warning: conformance of 'RevealingSplashView' to protocol 'SplashAnimatable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:23:27: warning: main actor-isolated property 'beginningOfDocument' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:24:25: warning: main actor-isolated property 'endOfDocument' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:26:36: warning: call to main actor-isolated instance method 'textRange(from:to:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:27:30: warning: call to main actor-isolated instance method 'text(in:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:31:43: warning: main actor-isolated property 'markedTextRange' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:35:38: warning: call to main actor-isolated instance method 'textRange(from:to:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:35:81: warning: main actor-isolated property 'start' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:36:34: warning: call to main actor-isolated instance method 'textRange(from:to:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:36:66: warning: main actor-isolated property 'end' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:23: warning: call to main actor-isolated instance method 'text(in:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:64: warning: call to main actor-isolated instance method 'text(in:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/SVProgressHUD+Extension.swift:11:26: warning: conformance of 'SVProgressHUD' to protocol 'HUD' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:8:49: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:15:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:21:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:27:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:33:18: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:70:15: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:76:81: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:76:108: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:84:48: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:89:49: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:119:31: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:124:77: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:124:104: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:133:25: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:137:46: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:144:31: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:149:77: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:149:104: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:157:25: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:163:47: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:201:15: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:206:81: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:206:108: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:214:68: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:225:64: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:233:49: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:239:45: warning: main actor-isolated property 'snp' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/Extension/SnapKitExtension/ConstraintArrayDSL.swift:264:40: warning: call to main actor-isolated instance method 'closestCommonSuperview' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:42:37: warning: static property 'storage' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:46:20: warning: static property 'myServiceYKey' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:23:17: warning: capture of 'callback' with non-Sendable type '(Result<Void, any Error>) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/KeyConstants.swift:24:17: warning: capture of 'request' with non-Sendable type 'NSBundleResourceRequest' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:50:23: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'NetworkMonitor' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:95:13: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:95:34: warning: capture of 'listener' with non-Sendable type '(NetworkStatus) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:99:13: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:99:29: warning: capture of 'listener' with non-Sendable type '(NetworkStatus) -> Void' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:108:13: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:144:30: warning: capture of 'self' with non-Sendable type 'NetworkMonitor?' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:151:17: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:151:41: warning: capture of 'newStatus' with non-Sendable type 'NetworkStatus' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/Extension/Utils/NetworkMonitor.swift:158:74: warning: capture of 'self' with non-Sendable type 'NetworkMonitor' in an isolated closure | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:84:23: warning: call to main actor-isolated class method 'dismiss()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:89:23: warning: call to main actor-isolated class method 'setDefaultMaskType' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:90:23: warning: call to main actor-isolated class method 'show()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/Utils/PollingNetworkRequester.swift:145:31: warning: call to main actor-isolated class method 'dismiss()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Extension/WebView+Extension.swift:14:14: warning: associated value 'genericConversionsFailed' of 'Sendable'-conforming enum 'RunJavaScriptError' contains non-Sendable type 'Any' | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:193:27: warning: conformance of 'HomeController' to protocol 'FSPagerViewDataSource' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:211:27: warning: conformance of 'HomeController' to protocol 'FSPagerViewDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:256:27: warning: conformance of 'HomeController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:172:48: warning: main actor-isolated property 'contentOffset' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/Home/Controller/HomeController.swift:175:40: warning: call to main actor-isolated instance method 'setContentOffset(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:259:29: warning: conformance of 'HotKeyController' to protocol 'TheRouterable' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:277:23: warning: static property 'patternString' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:279:23: warning: static property 'routerClass' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Home/Controller/HotKeyController.swift:268:18: warning: call to main actor-isolated instance method 'tagLayout(hotKeys:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Home/Enum/OtherApp.swift:43:37: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/CustomNetworkActivityPlugin.swift:34:47: warning: converting non-Sendable function value to '@MainActor @Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/CustomNetworkActivityPlugin.swift:46:47: warning: converting non-Sendable function value to '@MainActor @Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:22:24: warning: static property 'activityCount' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:26:24: warning: static property 'targetTypeInterceptor' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:28:24: warning: static property 'beginLoadingCallback' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:30:24: warning: static property 'stopLoadingCallback' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:84:5: warning: let 'activityManagerPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkActivityPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:10:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkActivityManager.swift:84:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:34:27: warning: static property 'all' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:36:27: warning: static property 'concise' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:38:27: warning: static property 'nothing' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:80:27: warning: static property 'haveNothing' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:83:27: warning: static property 'requestMethod' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:85:27: warning: static property 'requestBodyStream' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:87:27: warning: static property 'requestHeaders' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:89:27: warning: static property 'requestParameters' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:92:27: warning: static property 'responseBody' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:95:27: warning: static property 'request' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:97:27: warning: static property 'response' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:99:27: warning: static property 'all' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:101:27: warning: static property 'concise' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:103:27: warning: static property 'diversity' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin.Options.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkDebuggingPlugin.swift:137:20: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:54:13: warning: capture of 'self' with non-Sendable type 'NetworkRequestLoggerPlugin' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:57:37: warning: capture of 'request' with non-Sendable type 'any RequestType' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:12:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:89:20: warning: capture of 'result' with non-Sendable type 'Result<Response, MoyaError>' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/NetworkRequestLoggerPlugin.swift:106:32: warning: capture of 'self' with non-Sendable type 'NetworkRequestLoggerPlugin' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:110:5: warning: let 'userDefaultsCache' is not concurrency-safe because non-'Sendable' type 'UserDefaults' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:181:19: warning: capture of 'self' with non-Sendable type 'ResponseCachePlugin?' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:181:37: warning: capture of 'target' with non-Sendable type 'any TargetType' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:13:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift:184:23: warning: capture of 'response' with non-Sendable type 'Response' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/HttpRequest/Plugin/ResponseInterceptorPlugin.swift:28:31: warning: call to main actor-isolated static method 'showText' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:21:5: warning: let 'networkRequestLoggerPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkRequestLoggerPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:24:5: warning: let 'loggerPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:11:1: warning: add '@preconcurrency' to suppress 'Sendable'-related warnings from module 'Moya' | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:27:5: warning: let 'debuggingPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkDebuggingPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:33:5: warning: let 'activityPlugin' is not concurrency-safe because non-'Sendable' type 'NetworkActivityPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:33:5: warning: main actor-isolated default value in a nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:66:5: warning: let 'responseInterceptorPlugin' is not concurrency-safe because non-'Sendable' type 'ResponseInterceptorPlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:69:5: warning: let 'responseCachePlugin' is not concurrency-safe because non-'Sendable' type 'ResponseCachePlugin' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:72:5: warning: let 'plugins' is not concurrency-safe because non-'Sendable' type '[any PluginType]' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:78:5: warning: let 'homeProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<HomeService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:81:5: warning: let 'myEndpointClosure' is not concurrency-safe because non-'Sendable' type '(MyService) -> Endpoint' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:86:5: warning: let 'myProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<MyService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:89:5: warning: let 'projectProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<ProjectService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:92:5: warning: let 'publicNumberProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<PublicNumberService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:95:5: warning: let 'treeProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<TreeService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:98:5: warning: let 'accountProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<AccountService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:101:5: warning: let 'otherProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<OtherService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:107:5: warning: let 'mockProvider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<MockService>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/HttpRequest/Service/Provider.swift:112:5: warning: let 'provider' is not concurrency-safe because non-'Sendable' type 'MoyaProvider<MultiTarget>' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/InnerViewEvent/InnerEventResponsible.swift:23:19: warning: conformance of 'UIView' to protocol 'BubbleEventProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/InnerViewEvent/InnerEventResponsible.swift:38:29: warning: conformance of 'UIViewController' to protocol 'BubbleEventProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/LogUtils.swift:24:16: warning: static property 'logcat' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/My/Controller/AppIconSelectController.swift:138:18: warning: main actor-isolated property 'appProxy' can not be referenced from a Sendable closure | 本轮新观察 |
| RxStudy/My/Controller/AppIconSelectController.swift:138:53: warning: call to main actor-isolated instance method 'getLogoName()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyCollectionController.swift:197:18: warning: call to main actor-isolated instance method 'setEditing(_:animated:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyCollectionController.swift:205:18: warning: main actor-isolated property 'rightBarButtonItem' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyController.swift:221:25: warning: conformance of 'MyController' to protocol 'InnerEventResponsible' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/My/Controller/MyController.swift:231:25: warning: conformance of 'MyController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:53: warning: call to main actor-isolated instance method 'removeScriptMessageHandler(forName:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:31: warning: main actor-isolated property 'userContentController' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:17: warning: main actor-isolated property 'configuration' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/My/Controller/MyJueJinController.swift:68:9: warning: main actor-isolated property 'webView' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/My/View/MessageCell.swift:67:18: warning: main actor-isolated property 'count' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/My/View/MyView.swift:87:20: warning: main actor-isolated property 'myCoin' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/FooterKey.swift:23:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/FooterKey.swift:27:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/HeaderKey.swift:23:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/SwiftUIExample/View/Refresh/HeaderKey.swift:27:20: warning: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/TabType.swift:25:20: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:27:20: warning: call to main actor-isolated initializer 'init(type:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:29:20: warning: call to main actor-isolated initializer 'init(type:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:31:20: warning: call to main actor-isolated initializer 'init(type:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/TabType.swift:33:20: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Tabs/Controller/TabsController.swift:232:27: warning: conformance of 'TabsController' to protocol 'JXSegmentedViewDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Tabs/Controller/TabsController.swift:244:27: warning: conformance of 'TabsController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Tabs/Controller/TreeController.swift:207:27: warning: conformance of 'TreeController' to protocol 'TabBarViewControllerChildrenRefreshProtocol' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Tabs/Controller/TreeController.swift:217:18: warning: call to main actor-isolated instance method 'tableViewSectionAndCellConfig(tabs:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/Tabs/Controller/TreeController.swift:223:18: warning: call to main actor-isolated instance method 'tableViewSectionAndFlexLayoutCell(tabs:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:13:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'UniMPManager' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:63:25: warning: capture of 'self' with non-Sendable type 'UniMPManager' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:64:25: warning: capture of 'callback' with non-Sendable type '((Result<DCUniMPInstance, any Error>) -> Void)?' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:93:13: warning: capture of 'self' with non-Sendable type 'UniMPManager?' in a '@Sendable' closure | 本轮新观察 |
| RxStudy/UniMP/UniMPManager.swift:109:20: warning: call to main actor-isolated initializer 'init()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/ViewController.swift:206:22: warning: call to main actor-isolated instance method 'refreshChildren()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/ViewController.swift:267:16: warning: call to main actor-isolated instance method 'changeSelectedViewController(direction:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/DownloadWebController.swift:279:34: warning: conformance of 'DownloadWebController' to protocol 'UIDocumentInteractionControllerDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/WebView/Controller/DownloadWebController.swift:147:34: warning: reference to captured var 'self' in concurrently-executing code | 本轮新观察 |
| RxStudy/WebView/Controller/DownloadWebController.swift:230:27: warning: reference to captured var 'self' in concurrently-executing code | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:594:30: warning: conformance of 'WebViewController' to protocol 'HasDelegate' crosses into main actor-isolated code and can cause data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:57: warning: call to main actor-isolated instance method 'removeScriptMessageHandler(forName:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:35: warning: main actor-isolated property 'userContentController' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:21: warning: main actor-isolated property 'configuration' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:133:13: warning: main actor-isolated property 'webView' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/Controller/WebViewController.swift:601:18: warning: call to main actor-isolated instance method 'reload()' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/WebView/RxDelegateTest/RxWebViewControllerDelegateProxy.swift:52:16: warning: main actor-isolated property 'delegate' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/RxDelegateTest/RxWebViewControllerDelegateProxy.swift:56:16: warning: main actor-isolated property 'delegate' can not be mutated from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/View/SafariActivity.swift:44:46: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| RxStudy/WebView/View/SafariActivity.swift:45:34: warning: call to main actor-isolated instance method 'open(_:options:completionHandler:)' in a synchronous nonisolated context | 本轮新观察 |
| RxStudy/WebView/View/SafariActivity.swift:45:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:114:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:115:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: call to main actor-isolated instance method 'onChanged' in a synchronous nonisolated context | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:27:21: warning: static property 'launchImagePlayAndroid' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:28:21: warning: static property 'android' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:29:21: warning: static property 'back' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:30:21: warning: static property 'collect' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:31:21: warning: static property 'collectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:32:21: warning: static property 'home' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:33:21: warning: static property 'homeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:34:21: warning: static property 'loading01' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:35:21: warning: static property 'loading02' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:36:21: warning: static property 'loading03' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:37:21: warning: static property 'loading04' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:38:21: warning: static property 'loading05' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:39:21: warning: static property 'loading06' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:40:21: warning: static property 'loading07' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:41:21: warning: static property 'loading08' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:42:21: warning: static property 'loading09' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:43:21: warning: static property 'loading10' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:44:21: warning: static property 'loading11' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:45:21: warning: static property 'loading12' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:46:21: warning: static property 'mainTheme' is not concurrency-safe because non-'Sendable' type 'ColorAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:47:21: warning: static property 'my' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:48:21: warning: static property 'mySelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:49:21: warning: static property 'notFound' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:50:21: warning: static property 'project' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:51:21: warning: static property 'projectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:52:21: warning: static property 'publicNumber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:53:21: warning: static property 'publicNumberSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:54:21: warning: static property 'saber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:55:21: warning: static property 'safari' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:56:21: warning: static property 'tree' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:57:21: warning: static property 'treeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:58:21: warning: static property 'user' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:59:21: warning: static property 'wanAndroidPlaceholder' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:125:38: warning: non-Sendable '[UIViewController]?'-typed result can not be returned from main actor-isolated instance method 'popToRootViewController(animated:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Packages/ThirdParty/TheRouter/Sources/TheRouter+Jump.swift:290:61: warning: non-Sendable '[UIViewController]?'-typed result can not be returned from main actor-isolated instance method 'popToRootViewController(animated:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:27:30: warning: non-Sendable 'String?'-typed result can not be returned from main actor-isolated instance method 'text(in:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:23: warning: non-Sendable 'String?'-typed result can not be returned from main actor-isolated instance method 'text(in:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Extension/Rx+Operators.swift:40:64: warning: non-Sendable 'String?'-typed result can not be returned from main actor-isolated instance method 'text(in:)' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/My/Controller/AppIconSelectController.swift:138:53: warning: non-Sendable 'String'-typed result can not be returned from main actor-isolated instance method 'getLogoName()' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: sending value of non-Sendable type '(DragGesture.Value) -> ()' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: non-Sendable '_ChangedGesture<DragGesture>'-typed result can not be returned from main actor-isolated instance method 'onChanged' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| RxStudy/Log/Modern/ModernLogRedactor.swift:112:22: warning: Optional Data -> String Conversion Violation: Prefer failable `String(bytes:encoding:)` initializer when converting `Data` to `String` (optional_data_string_conversion) | 基线已有 |

### SwiftUIStudy-Debug settings：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

### SwiftUIStudy-Debug build：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Debug -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

成功标记：True；日志 `Derived/swift6-strict/SwiftUIStudy-Debug-build.log`。

严格并发诊断分布（去重）：{'Packages': 1, 'SwiftUIStudy': 36, 'Shared': 44}。

| 诊断依据（文件:行:列与原文） | 基线关系 |
| --- | --- |
| Packages/ThirdParty/ProgressHUD/SwiftUI/Sources/ProgressHUD.swift:28:20: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ProgressHUD' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Coin/CoinViewModel.swift:28:30: warning: non-Sendable type 'CoinAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Coin/CoinViewModel.swift:29:33: warning: non-Sendable type 'CoinAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Home/HomeViewModel.swift:32:33: warning: non-Sendable type 'HomeAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Home/HomeViewModel.swift:33:37: warning: non-Sendable type 'HomeAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Home/HomeViewModel.swift:34:34: warning: non-Sendable type 'HomeAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Components/ShareSheet.swift:41:46: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| SwiftUIStudy/Components/ShareSheet.swift:42:34: warning: call to main actor-isolated instance method 'open(_:options:completionHandler:)' in a synchronous nonisolated context | 本轮新观察 |
| SwiftUIStudy/Components/ShareSheet.swift:42:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:68:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:74:31: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:81:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:138:21: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:138:37: warning: capture of 'pageResult' with non-Sendable type 'Page<InfoModel>' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:149:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:160:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:52:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:90:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:67:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:72:31: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:79:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:136:21: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:136:37: warning: capture of 'pageResult' with non-Sendable type 'Page<InfoModel>' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:147:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:158:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:51:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:88:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Tree/TreeViewModel.swift:49:17: warning: capture of 'self' with non-Sendable type 'TreeViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Tree/TreeViewModel.swift:54:17: warning: capture of 'self' with non-Sendable type 'TreeViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Tree/TreeViewModel.swift:33:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/AccountAPIService.swift:72:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'AccountAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/CoinAPIService.swift:54:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CoinAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/CollectAPIService.swift:48:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CollectAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/HomeAPIService.swift:69:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'HomeAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/ProjectAPIService.swift:55:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ProjectAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/PublicNumberAPIService.swift:50:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'PublicNumberAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/TreeAPIService.swift:55:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'TreeAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:27:21: warning: static property 'launchImagePlayAndroid' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:28:21: warning: static property 'android' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:29:21: warning: static property 'back' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:30:21: warning: static property 'collect' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:31:21: warning: static property 'collectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:32:21: warning: static property 'home' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:33:21: warning: static property 'homeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:34:21: warning: static property 'loading01' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:35:21: warning: static property 'loading02' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:36:21: warning: static property 'loading03' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:37:21: warning: static property 'loading04' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:38:21: warning: static property 'loading05' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:39:21: warning: static property 'loading06' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:40:21: warning: static property 'loading07' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:41:21: warning: static property 'loading08' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:42:21: warning: static property 'loading09' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:43:21: warning: static property 'loading10' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:44:21: warning: static property 'loading11' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:45:21: warning: static property 'loading12' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:46:21: warning: static property 'mainTheme' is not concurrency-safe because non-'Sendable' type 'ColorAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:47:21: warning: static property 'my' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:48:21: warning: static property 'mySelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:49:21: warning: static property 'notFound' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:50:21: warning: static property 'project' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:51:21: warning: static property 'projectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:52:21: warning: static property 'publicNumber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:53:21: warning: static property 'publicNumberSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:54:21: warning: static property 'saber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:55:21: warning: static property 'safari' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:56:21: warning: static property 'tree' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:57:21: warning: static property 'treeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:58:21: warning: static property 'user' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:59:21: warning: static property 'wanAndroidPlaceholder' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:114:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:115:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: call to main actor-isolated instance method 'onChanged' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: sending value of non-Sendable type '(DragGesture.Value) -> ()' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: non-Sendable '_ChangedGesture<DragGesture>'-typed result can not be returned from main actor-isolated instance method 'onChanged' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |

### SwiftUIStudy-Release settings：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete -showBuildSettings
```

```
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
CODE_SIGNING_ALLOWED = NO
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 5.9
```

### SwiftUIStudy-Release build：退出码 0

```sh
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration Release -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete build
```

成功标记：True；日志 `Derived/swift6-strict/SwiftUIStudy-Release-build.log`。

严格并发诊断分布（去重）：{'Packages': 1, 'Alamofire': 6, 'Moya': 28, 'SwiftUIStudy': 36, 'Shared': 44}。

| 诊断依据（文件:行:列与原文） | 基线关系 |
| --- | --- |
| Packages/ThirdParty/ProgressHUD/SwiftUI/Sources/ProgressHUD.swift:28:20: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ProgressHUD' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Core/DataStreamRequest.swift:165:21: warning: capture of 'stream' with non-Sendable type 'OutputStream' in a '@Sendable' closure | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:339:39: warning: capture of 'event' with non-Sendable type '(any EventMonitor) -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:339:39: warning: reference to captured parameter 'event' in concurrently-executing code | 本轮新观察 |
| Pods/Alamofire/Source/Features/ResponseSerialization.swift:360:20: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Features/ResponseSerialization.swift:360:20: warning: type 'JSONResponseSerializer.SerializedObject' (aka 'Any') does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Alamofire/Source/Features/EventMonitor.swift:558:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:110:9: warning: stored property 'prepare' of 'Sendable'-conforming class 'MoyaRequestInterceptor' is mutable; this is an error in the Swift 6 language mode | 基线已有 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:85:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:89:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:99:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/Moya+Alamofire.swift:103:17: warning: capture of 'completionHandler' with non-Sendable type 'RequestableCompletion' (aka '(Optional<HTTPURLResponse>, Optional<URLRequest>, Optional<Data>, Optional<any Error>) -> ()') in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:7:10: warning: associated value 'imageMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:10:10: warning: associated value 'jsonMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:13:10: warning: associated value 'stringMapping' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:16:10: warning: associated value 'objectMapping' of 'Sendable'-conforming enum 'MoyaError' contains non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:22:10: warning: associated value 'statusCode' of 'Sendable'-conforming enum 'MoyaError' has non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaError.swift:25:10: warning: associated value 'underlying' of 'Sendable'-conforming enum 'MoyaError' contains non-Sendable type 'Response' | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider.swift:145:46: warning: converting non-Sendable function value to '@Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider.swift:151:17: warning: capture of 'stub' with non-Sendable type '() -> Void' in a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:245:46: warning: converting non-Sendable function value to '@Sendable @convention(block) () -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:255:84: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:259:78: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/MoyaProvider+Internal.swift:263:76: warning: converting non-Sendable function value to '@Sendable (Progress) -> Void' may introduce data races | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:162:27: warning: static property 'requestMethod' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:164:27: warning: static property 'requestBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:166:27: warning: static property 'requestHeaders' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:173:27: warning: static property 'formatRequestAscURL' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:175:27: warning: static property 'successResponseBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:177:27: warning: static property 'errorResponseBody' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:181:27: warning: static property 'default' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:183:27: warning: static property 'verbose' is not concurrency-safe because non-'Sendable' type 'NetworkLoggerPlugin.Configuration.LogOptions' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/Plugins/NetworkLoggerPlugin.swift:230:20: warning: static property 'defaultEntryDateFormatter' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Pods/Moya/Sources/Moya/RequestTypeWrapper.swift:29:43: warning: passing non-Sendable parameter 'handler' to function expecting a '@Sendable' closure | 本轮新观察 |
| Pods/Moya/Sources/Moya/URLRequest+Encoding.swift:23:61: warning: type 'Any' does not conform to the 'Sendable' protocol; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Components/ShareSheet.swift:41:46: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| SwiftUIStudy/Components/ShareSheet.swift:42:34: warning: call to main actor-isolated instance method 'open(_:options:completionHandler:)' in a synchronous nonisolated context | 本轮新观察 |
| SwiftUIStudy/Components/ShareSheet.swift:42:27: warning: main actor-isolated class property 'shared' can not be referenced from a nonisolated context | 本轮新观察 |
| SwiftUIStudy/Features/Coin/CoinViewModel.swift:28:30: warning: non-Sendable type 'CoinAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Coin/CoinViewModel.swift:29:33: warning: non-Sendable type 'CoinAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Home/HomeViewModel.swift:32:33: warning: non-Sendable type 'HomeAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Home/HomeViewModel.swift:33:37: warning: non-Sendable type 'HomeAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Home/HomeViewModel.swift:34:34: warning: non-Sendable type 'HomeAPIService' of property 'apiService' cannot exit main actor-isolated context; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:68:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:74:31: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:81:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:138:21: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:138:37: warning: capture of 'pageResult' with non-Sendable type 'Page<InfoModel>' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:149:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:160:17: warning: capture of 'self' with non-Sendable type 'ProjectViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:67:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:72:31: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in an isolated closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:79:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:136:21: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:136:37: warning: capture of 'pageResult' with non-Sendable type 'Page<InfoModel>' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:147:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:158:17: warning: capture of 'self' with non-Sendable type 'PublicNumberViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Tree/TreeViewModel.swift:49:17: warning: capture of 'self' with non-Sendable type 'TreeViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Tree/TreeViewModel.swift:54:17: warning: capture of 'self' with non-Sendable type 'TreeViewModel' in a '@Sendable' closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/AccountAPIService.swift:72:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'AccountAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/CoinAPIService.swift:54:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CoinAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/CollectAPIService.swift:48:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'CollectAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/HomeAPIService.swift:69:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'HomeAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/ProjectAPIService.swift:55:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'ProjectAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/PublicNumberAPIService.swift:50:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'PublicNumberAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Network/TreeAPIService.swift:55:16: warning: static property 'shared' is not concurrency-safe because non-'Sendable' type 'TreeAPIService' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:114:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarousel.swift:115:21: warning: call to main actor-isolated initializer 'init(_:index:spacing:headspace:sidesScaling:isWrap:autoScroll:canMove:content:)' in a synchronous nonisolated context | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:215:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of 'self' with non-Sendable type 'ACarouselViewModel<Data, ID>' in a '@Sendable' closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'Data.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:220:17: warning: capture of non-Sendable type 'ID.Type' in an isolated closure | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: call to main actor-isolated instance method 'onChanged' in a synchronous nonisolated context | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:27:21: warning: static property 'launchImagePlayAndroid' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:28:21: warning: static property 'android' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:29:21: warning: static property 'back' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:30:21: warning: static property 'collect' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:31:21: warning: static property 'collectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:32:21: warning: static property 'home' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:33:21: warning: static property 'homeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:34:21: warning: static property 'loading01' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:35:21: warning: static property 'loading02' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:36:21: warning: static property 'loading03' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:37:21: warning: static property 'loading04' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:38:21: warning: static property 'loading05' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:39:21: warning: static property 'loading06' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:40:21: warning: static property 'loading07' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:41:21: warning: static property 'loading08' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:42:21: warning: static property 'loading09' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:43:21: warning: static property 'loading10' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:44:21: warning: static property 'loading11' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:45:21: warning: static property 'loading12' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:46:21: warning: static property 'mainTheme' is not concurrency-safe because non-'Sendable' type 'ColorAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:47:21: warning: static property 'my' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:48:21: warning: static property 'mySelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:49:21: warning: static property 'notFound' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:50:21: warning: static property 'project' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:51:21: warning: static property 'projectSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:52:21: warning: static property 'publicNumber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:53:21: warning: static property 'publicNumberSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:54:21: warning: static property 'saber' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:55:21: warning: static property 'safari' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:56:21: warning: static property 'tree' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:57:21: warning: static property 'treeSelected' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:58:21: warning: static property 'user' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/Generated/Assets+SwiftGen.swift:59:21: warning: static property 'wanAndroidPlaceholder' is not concurrency-safe because non-'Sendable' type 'ImageAsset' may have shared mutable state; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:52:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Project/ProjectViewModel.swift:90:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:51:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/PublicNumber/PublicNumberViewModel.swift:88:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| SwiftUIStudy/Features/Tree/TreeViewModel.swift:33:9: warning: passing closure as a 'sending' parameter risks causing data races between code in the current task and concurrent execution of the closure; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: sending value of non-Sendable type '(DragGesture.Value) -> ()' risks causing data races; this is an error in the Swift 6 language mode | 本轮新观察 |
| Shared/ACarousel/ACarouselViewModel.swift:232:14: warning: non-Sendable '_ChangedGesture<DragGesture>'-typed result can not be returned from main actor-isolated instance method 'onChanged' to nonisolated context; this is an error in the Swift 6 language mode | 本轮新观察 |

## 分类与覆盖结论

- 共享代码：Shared/API、Models、Business/AccountCookie 和 ACarousel 纳入构建；AccountCookie 是无状态字符串转换。ACarousel 延迟主队列回调及 ObservableObject 状态需按 UI 所有权检查。上方文件级诊断为精确证据，不能仅凭文件名归属推断 Target 成员。
- UI 隔离：SwiftUI Features 中多处 @MainActor，但 Login/Mine 为方法级隔离；UIKit 协议实现与 HUD 插件 DispatchQueue.main.async 不保证协议要求本身已隔离。RequestLoadingPlugin、CustomNetworkActivityPlugin、NetworkActivityManager 均在检查范围。
- 可发送性：ModernLogging 的 completion、DDFileLogger、self 跨队列捕获；ModernNetworkLogger 的闭包捕获见清单。SwiftUI 网络 HomeAPIService 等 Moya 服务及 async 请求传值需与 UI 调用端一起修复。
- 全局状态：AccountManager.shared、AccountServiceContainer._current、NetworkActivityManager 计数/回调、LogUtils.logcat、本地 TheRouterManager 的 apiArray/classMapArray/registerRouterList 是重点；不能直接把所有单例声明 unchecked Sendable。
- Rx/Combine：检查 AppDelegate+NetworkConfig 的 NWPathMonitor listener 与 Rx subscribe 写入账号 Relay；旧 Alamofire listener 也保留。调度至主线程是运行时约定，静态 Actor 保证需显式表达；Combine/Rx 非 Sendable 回调可能不触发完整诊断，零告警不代表无竞态。
- 本地维护源码：TheRouter 直接编入 RxStudy，不能按第三方 Pod 留在 Swift 5 绕开；ProgressHUD 15.0.1 的 podspec 指向 SwiftUI/Sources，锁定 Swift 5.9，与 App 切换独立，仍需核对其 UI 静态状态。脚本测试及实际源码阅读补充编译器盲区。
- 实际跨端入口：AppDelegate.swift 调用 UniMPManager 初始化，UniMPManager 安装/打开资源和 delegate 回调访问可变实例与 Any 参数。属于当前启用入口，需要明确回调线程与 UI 隔离。FlutterManager 位于 canImport 双重条件内，本轮 Flutter 关闭，不声称验证其运行或启用分支。

## 依赖兼容结论

当前锁定依赖支持本次 Swift 5 complete 四项构建（结果见上），并非所有依赖可切换 Swift 6 的证明。命令行覆盖传播到 Pods，暴露 PinLayout、SnapKit、SwiftDate、LifetimeTracker、MarqueeLabel 等内部共享状态或隔离告警；应将 App 语言模式与依赖语言模式分开。RxSwift/RxCocoa、Moya、Combine 扩展及 CocoaLumberjack 的边界需调用端约束；Kingfisher、Alamofire 等本次构建结果只证明当前组合可编译。Objective-C/二进制 unimp、HUD 等不能通过 Swift 诊断证明线程安全。没有本轮证据要求升级锁定依赖；若 App Swift 6 阶段出现不可在边界解决的具体错误，再单列升级任务。

## 验证与后续

完整命令和退出码另存 Derived/swift6-strict/results.json；设置和编译日志完整保留。其他诊断导出各配置 other-diagnostics.txt，包含既有弃用、SwiftLint 等，不混入并发修复范围。现有脚本测试：python3 -m unittest discover -s scripts/tests -p 'test*.py'，12 项通过，日志 tests.log。本轮文档工作没有新增行为测试接缝，不适用 TDD。未运行模拟器、设备或 Flutter 启用验证。迁移顺序、估算、交付与验收、真实依赖及新对话提示词见 Swift6后续任务草案.md。后续任务须用户确认后发布，尚未分配 GitHub 编号。

## 审查记录

按 implement 要求执行 code-review 双轴审查：规范轴发现诊断表格空行破坏渲染，已修正；规格轴发现遗漏 SwiftGen 生成流程与修复批次过大，已补充生成流程验收并拆分 A1–D4 独立单元和确定依赖。最终 git diff --check 通过。仅提交本任务两个新增文档，用户已有文件不纳入。
