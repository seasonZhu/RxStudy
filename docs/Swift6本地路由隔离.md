# Swift 6 本地路由隔离（Issue #20 / D2）

基点 `d19f7a10b`，分支 `codex/swift6-migration`。TheRouter 源码仍直接编入 RxStudy。构建使用当前工作区与 Xcode 26.3（17C529），保留用户未提交文件。Flutter 标记不存在，两份 Pods 锁文件 SHA-256 均为 `6e7f8009ad18b5580dfef26f1297217625b0fba7e1d002f8bae77a235f7db8ff`。

## 诊断与所有权

#11 的诊断在源码重编译时复现，包括路由单例及注册表的全局状态、UIKit 的非隔离访问、HotKeyController 的协议遵循，以及服务队列捕获构造器和 Any 实例。完整日志为 `Derived/swift6-issue20/source-baseline.log`。

| 边界 | 修改前后及依据 |
| --- | --- |
| 注册、模式、拦截器 | 原来 `static let shareInstance = TheRouter()` 可被任意线程取用。现在 TheRouter 和 TheRouterManager 同属 `@MainActor`。AppDelegate 在主 Actor 配置注册。懒注册、优先级排序、匹配、白名单与短路均沿用原同步执行顺序。拦截器与回调由同一 Actor 持有并调用。 |
| 路由协议 | 原来 `protocol TheRouterable` 可从任意线程读取页面静态元数据。现在声明 `@MainActor public protocol TheRouterable`，运行时扫描在同一 Actor 读取模式与优先级。Objective-C 代理的元数据也由主 Actor 扫描路径读取。 |
| 页面与桥接 | TheRouter 的跳转扩展继承主 Actor，覆盖页面实例化、KVC、window 和导航。TheRouerBridge 对 Swift 调用方也声明主 Actor。Objective-C 调用方须在主线程调用，仓库内未发现外部调用者。原有 main.async、延时及完成回调位置不变。 |
| 服务注册表 | 原来 `serviceQueue.async { self.creatorsMap[named] = creator }`，查询通过队列同步等待，动态方法另有直接读表路径。现在服务管理器在主 Actor 同步写入 `self.creatorsMap[named] = creator`。对主 Actor 上的注册后查询，写入先于读取。直接读表同样遵守隔离。创建仍延迟到查询时，原缓存条件、键覆盖和清除规则不变。公开字典的写入现在立即可见。 |
| 纯拼装与 Builder | `generate` 显式 `nonisolated`，仅处理本次传入的 URL 和参数。解析器的默认实现继续独立于注册状态。Builder 仅在读取服务配置、取服务或导航时要求主 Actor。 |

路由请求、服务构造器、拦截器、完成回调以及 `[String: Any]` 都留在原同步调用链，不跨 Actor 传递。本轮没有添加临时兼容声明。`nonisolated` 是纯拼装方法的长期边界，若日后读取 UI 或路由状态，须移除并让调用方进入主 Actor。现有主队列调度仍确保真正的 UIKit 跳转发生在原来的时点。

## 设备交接

1. 安装 Debug 包，冷启动后用 Safari 打开 `wandroid://hotkey`。在 `loadRouterClass`、`registerRouterMap` 和 `routerJump` 下断点，确认启动先发现类，首次请求完成懒注册后才匹配 HotKeyController。返回后再次打开，确认走已注册路径。
2. 在调试入口用 `TheRouter.requestURL("wandroid://hotkey?source=device")` 检查匹配类型及 query。用同一 URL 测重定向或测试模式时，确认优先级及参数合并与迁移前一致。
3. 在仅供设备验证的调试入口注册不同优先级的两个拦截器。高优先级返回 false 时，确认低优先级不执行、页面不跳转。改为 true 后观察低优先级执行与跳转。将目标加入高优先级拦截器白名单后确认跳过该回调。重启清除临时验证状态。
4. 先懒注册，再从已有导航栈调用 `openURL` 并记录完成回调与实际 push 的先后。用默认 push 及应用 URL 入口指定的跳转类型分别验证，配合快速重复打开与返回观察现有导航行为。若验证服务，从主线程注册同名测试服务后立即查询，检查惰性构造、缓存命中与清除。

上述步骤由开发者在设备执行。现有 Python 脚本无 UIKit 路由行为接缝，编译验证隔离，设备验证路由行为。

## 构建与脚本证据

每次执行的完整命令、退出码和未截断日志分别保存在 `Derived/swift6-issue20/<名称>.command`、`.exit`、`.log`。复用独立 DerivedData `Derived/swift6-issue18/build`。命令公共部分如下，追加表中参数。

```sh
xcodebuild -workspace RxStudy.xcworkspace -destination generic/platform=iOS -derivedDataPath Derived/swift6-issue18/build CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.9 SWIFT_STRICT_CONCURRENCY=complete
```

| 日志名称 | 追加参数 | 退出码 |
| --- | --- | --- |
| source-baseline | `-scheme RxStudy -configuration Debug build` | 0 |
| targeted | 同上 | 65 |
| targeted2 | 同上 | 0 |
| targeted3 | 同上 | 0 |
| RxStudy-Debug-settings / build | `-scheme RxStudy -configuration Debug` 后追加 `-showBuildSettings` 或 `build` | 0 / 0 |
| RxStudy-Release-settings / build | `-scheme RxStudy -configuration Release` 后追加 `-showBuildSettings` 或 `build` | 0 / 0 |
| SwiftUIStudy-Debug-settings / build | `-scheme SwiftUIStudy -configuration Debug` 后追加 `-showBuildSettings` 或 `build` | 0 / 0 |

三组实际设置均为 `SWIFT_VERSION = 5.9`、`SWIFT_STRICT_CONCURRENCY = complete` 和 `CODE_SIGNING_ALLOWED = NO`。三个最终构建均出现 `BUILD SUCCEEDED`。SwiftUIStudy 为共享工作区回查，本地路由只编入 RxStudy。没有环境阻塞。targeted 首次失败来自纯参数拼装方法的隔离传播。targeted2 修复该错误，仍有服务单例诊断，targeted3 完成服务隔离并触发相关源码重编译。结合 Release 源码编译，#11 的 D2 并发诊断均未再出现。

范围外编译警告包括 UniMP 并发边界、ResponseCachePlugin 捕获、MBProgressHUD progress 和 MJRefresh observer 传递，以及锁定依赖、构建脚本、链接、弃用与 SwiftLint。完整原文保留在构建日志。

脚本以 `python3 scripts/tests/<文件名>.py` 分别执行。完整输出保存在同一目录的同名 `.log`，命令参数和各退出码见下方清单。

- `python3 scripts/tests/test_switch_flutter.py` 退出 0。
- `python3 scripts/tests/test-account-session.py` 退出 0。
- `python3 scripts/tests/test-async-request-integration.py` 退出 0。
- `python3 scripts/tests/test-async-request.py` 退出 0。
- `python3 scripts/tests/test-category-source.py` 退出 0。
- `python3 scripts/tests/test-flutter-bridge.py` 退出 0。
- `python3 scripts/tests/test-pagination.py` 退出 0。
- `python3 scripts/tests/test-rxstudy-logging.py` 退出 0。
- `python3 scripts/tests/test-upgrade-tuist.py` 退出 0。

## 双轴独立审查

- Standards 核对固定基点到本轮的源码差异，未发现编码规范违规或需要修改的代码气味。交接已明确 Objective-C 主线程契约与服务写入立即可见。
- Spec 核对 #20、#9 及 D2 范围，未发现注册、匹配、拦截或跳转顺序回归。Objective-C 调用端没有 Swift 的静态 Actor 约束，文档记录了主线程前提。设备步骤包含 Debug 注入拦截器。

下一项就绪任务为 #21，见 [新对话提示词](Swift6-Issue21新对话提示词.md)。
