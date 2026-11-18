# SwiftUIStudy 切换 Swift 6 语言模式（#22）

## 范围和交付基点

分支 `codex/swift6-migration`，基点 `b745263ca`。#9 规定先修复、再逐 Target 切换；#11 已关闭，其《Swift6严格并发诊断.md》用 Swift 5 加 `SWIFT_STRICT_CONCURRENCY=complete` 收集诊断。下列前置交付已在当前分支，但 GitHub 上仍为开放状态；本次按明确指令验证实际交付，未变更工单状态。

| 前置 | 提交与中文说明 | #11 诊断对照：本轮两配置均未复现 |
| --- | --- | --- |
| #12 | `cf85a1ac2`，《Swift6共享资源修复.md》 | 资源生成类型静态值的并发安全告警；修复落在 SwiftGen 模板与生成产物 |
| #13 | `ec31ac28f`，《Swift6共享模型与轮播修复.md》 | 轮播延迟闭包捕获、手势跨域及组件库预览初始化隔离诊断 |
| #15 | `b5f73640d`，《Swift6网络服务可发送性修复.md》 | Moya 服务共享实例、返回模型和 continuation 跨域传值诊断 |
| #16 | `5201fb191`，《Swift6页面状态与本地HUD隔离.md》 | 页面任务发送 `self` / ViewModel、默认值隔离、账号服务与本地 HUD 共享状态诊断 |

仅对 `93CC6ADDB6D1AAF6AA0F937C`（SwiftUIStudy Release）和 `F9CFB2175198DE18B7FC52DC`（SwiftUIStudy Debug）作如下修改：

```diff
- SWIFT_VERSION = 5.9;
+ SWIFT_VERSION = 6;
```

不改项目级设置或全局覆盖 Swift 版本，Swift 6 模式已包含完整严格并发检查，不再另加 `SWIFT_STRICT_CONCURRENCY`。提交未纳入工作区原有工程重排、RxStudy 两配置的 `5.9 → 5.0`、Pods 工程、`.DS_Store` 或未跟踪文档；构建使用保留这些本地文件的当前工作区。两个锁文件 SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`，`.flutter-enabled` 始终不存在。未改应用或共享源码，因此不触发 RxStudy 两配置回查；#23 负责切换 RxStudy，#24 负责双 Target 最终矩阵。

## Actor 与 Sendable 边界

- 前置 #13 的 `class ACarouselViewModel: ObservableObject` → `@MainActor class ACarouselViewModel: ObservableObject`，是把绑定和手势状态归到 UI Actor，不是把 `Binding` 或 `KeyPath` 当成可跨域值。#16 的页面 ViewModel 与本地 HUD 同理，不能把主 Actor 保证推广到任意回调。
- #15 的请求桥接由非泛型 `AsyncRequestState` 改为 `AsyncRequestState<Value: Sendable>`：回调在本地解码 Moya `Response`，不直接发送响应对象；仅传可发送模型。`Codable` 不等于 `Sendable`。
- 本轮未引入或修改兼容标记。沿用 #15 的 `@unchecked Sendable`，因为取消和响应回调可从不同线程访问桥接状态；`NSLock` 保护状态、continuation 和取消句柄，先原子摘除状态，再解锁恢复或取消，避免同步重入持锁。待换成编译器能检查的同步容器且验证完成/取消仍只终结一次后，可移除标记。
- Moya 等 Pods 保留原有语言模式，并不表示对其内部并发安全作出保证。只有依赖自身可在 Swift 6 下构建并通过相关运行回归时，才考虑移除 Swift 5 兼容保留；本轮没有必须升级的证据，不开升级任务。实际构建无错误，无需回到 Swift 5 complete 修复。

## 构建证据

2026-11-18，Xcode 26.3（17C529）；Debug、Release 各从不同的空 Derived Data 目录构建。以下是实际命令的循环写法（`$c` 分别展开为 `Debug`、`Release`）。原始未截断输出、命令行和逐项退出码保留在本机忽略目录 `Derived/swift6-issue22/`，未将构建产物或含本机路径的日志提交入库。

```sh
D=/tmp/rx22.V0batm
for c in Debug Release; do
  xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration "$c" -destination generic/platform=iOS -derivedDataPath "$D/$c" CODE_SIGNING_ALLOWED=NO -showBuildSettings
  xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -configuration "$c" -destination generic/platform=iOS -derivedDataPath "$D/$c" CODE_SIGNING_ALLOWED=NO build
  xcodebuild -project Pods/Pods.xcodeproj -alltargets -configuration "$c" -sdk iphoneos CODE_SIGNING_ALLOWED=NO -showBuildSettings
done
```

| 配置 | 应用 settings / build / Pods settings 退出码 | 应用生效设置 | 实际应用 Swift 编译命令 | 构建结论 |
| --- | --- | --- | --- | --- |
| Debug | `0 / 0 / 0` | `SWIFT_VERSION=6`，`CODE_SIGNING_ALLOWED=NO` | `-module-name SwiftUIStudy`，`-swift-version 6` | `BUILD SUCCEEDED` |
| Release | `0 / 0 / 0` | `SWIFT_VERSION=6`，`CODE_SIGNING_ALLOWED=NO` | `-module-name SwiftUIStudy`，`-swift-version 6` | `BUILD SUCCEEDED` |

两项应用 settings 未列出显式 `SWIFT_STRICT_CONCURRENCY` 或 `SWIFT_DEFAULT_ACTOR_ISOLATION`。用 `rg -- '-module-name SwiftUIStudy' Derived/swift6-issue22/{Debug,Release}.build.log` 查看完整调用。实际 Swift 依赖模块如下（两配置一致）；Pods 设置日志也列出另一 Moya 变体，不能据名称将其当成本应用的编译目标。

| Swift 模块 | Pods `SWIFT_VERSION` | 实际 `-swift-version` |
| --- | --- | --- |
| Alamofire | `5` | `5` |
| Kingfisher | `5.0` | `5` |
| Moya | `5.3` | `5` |
| ProgressHUD | `5.9` | `5` |

**范围外告警：** 两配置无应用并发诊断。Moya 的 `cURLDescription(calling:)` 可发送性不匹配、`MoyaRequestInterceptor.prepare` 可变属性告警仍来自 Swift 5 模式的 Pod，不是应用 Swift 6 错误。另有 Moya 跨变体隐式链接匹配、Kingfisher `kUTTypeJPEG` / `kUTTypeGIF` 弃用、应用已有 `WebUIController` 四条 WebKit 可选方法近似匹配及 `HotKeyView` 导航弃用；构建还报告资源未指派/缺少 AccentColor、方向配置、SwiftGen 缺少声明输出和 AppIntents 元数据跳过。不以告警条数与 #11 比较，因为 #11 的命令行严格检查覆盖也传播到 Pods，且构建范围不同。

- **编译了模块，检查强度不同：** #11 在 Alamofire 报告 `OutputStream` 闭包捕获和 JSON 序列化 `Any` 不可发送，在 Moya 报告 `completionHandler` 捕获和 `MoyaError` 携带不可发送的 `Response`。这些锁定模块本轮仍编译，但未收到全局 `complete` 覆盖，此类告警未复现不表示依赖源码已修复。
- **未编译模块，不适用：** #11 双 Target 基线中的 PinLayout、SnapKit、SwiftDate、LifetimeTracker、MarqueeLabel 不在本轮实际 Swift 编译命令中；不对其诊断消除或 Swift 6 兼容性作结论。

## 自动化和设备验证

逐文件执行 `python3 scripts/tests/<文件>`，完整输出和退出码见同目录的 `<文件>.log`、`<文件>.exit`。语言模式变化没有新的用户行为测试接缝；以实际编译和现有脚本为验证，不增加镜像断言。脚本中的传输替身、宿主编译和夹具不等于 iOS App 真机覆盖。

| 脚本 | 退出码 |
| --- | --- |
| `test-account-session.py` | 0 |
| `test-async-request.py` | 0 |
| `test-async-request-integration.py` | 0 |
| `test-category-source.py` | 0 |
| `test-flutter-bridge.py` | 0 |
| `test-pagination.py` | 0 |
| `test-rxstudy-logging.py` | 0 |
| `test-upgrade-tuist.py` | 0 |
| `test_switch_flutter.py` | 0 |

编译无环境阻塞；通用目的地不执行安装或签名，未运行模拟器或真机。开发者在 Xcode 选择 `SwiftUIStudy` Scheme 和已签名的 iOS 17.6 或以上设备，按下列步骤回归，必要时以 Release 再跑一次：

1. 冷启动，在首页滑动轮播、等待自动滚动并切换标签页，确认没有跳动、重复计时或资源缺失。
2. 首页、项目、公众号、体系和搜索分别验证首次加载、分页、返回和重进。网络处理中快速退出页面，断网再恢复，确认无过期结果覆盖当前状态、无重复更新且 HUD 最终消失。
3. 用测试账号尝试登录失败和成功，验证收藏、积分、退出登录及重新进首页后状态正确；检查快速重复操作不会恢复旧会话。
4. 打开文章、返回、触发分享；有测试网页时验证导航决策和 JavaScript 对话框，留意 WebKit 既有告警对应的行为。Flutter 保持关闭，脚本通过不构成 Flutter 入口设备验收。
5. 在「设置」切换浅色和深色外观并回到首页，检查图标、图片和动态颜色。在相同图片 URL 首次加载成功后重进页面，通过 Instruments 网络记录检查图片是否重复下载；不把页面数据接口的重载误判为图片缓存未命中。
6. 在加载或观察状态的页面反复进入和退出；使用 Instruments Allocations 或 Xcode Memory Graph 确认不再需要的页面状态没有持续累积，并在旧请求返回时确认离页后的旧观察者不再更新页面。

## 独立审查

- Standards：0 项规范违规，0 项代码异味；两项配置必须各自显式声明，不抽取公共设置。
- Spec：确认仅切换 SwiftUIStudy；两项文档发现（依赖诊断按检查配置/模块范围区分、补足主题/缓存/订阅设备检查）已采纳。未因文档补充重复构建。

## 下一项候选：#23

#23 的代码前置交付已落地但相关工单仍开放，尚不能宣称跟踪器已就绪；确认或整理前置工单后使用下列提示词：

> 执行 `$implement`，完成 seasonZhu/RxStudy #23「Swift 6 迁移：切换 RxStudy 为 Swift 6 语言模式」。先读 #23、#9、#11 和各前置 #12/#13/#14/#17–#21 的交付及中文文档，并复用 #22 的实际语言模式取证方法。在 `codex/swift6-migration` 保留用户改动、锁定依赖及 Flutter 关闭；先检查工程文件现有差异，仅持久化 RxStudy Debug/Release 的 Swift 6 设置，不改 SwiftUIStudy。若失败先分类，最小修复前在 Swift 5 complete 复现；共享源码变动回查 SwiftUIStudy Debug/Release，依赖升级另列证据。用原 workspace、RxStudy scheme、generic/platform=iOS、关闭签名且不覆盖全局 SWIFT_VERSION 验收两配置，记录设置、实际 `-swift-version 6`、完整命令、日志及退出码；完整逐文件跑脚本，提交中文说明和真机步骤，双轴审查后独立提交。最终矩阵留给 #24。
