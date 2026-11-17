# Swift 6 后续任务草案（待用户确认，不发布）

编号仅为建议，GitHub 实际编号由发布时分配，不保证下一项一定为 #12。全部属于 #9。
每项必须提交中文学习说明：实际诊断、修改前后示例、原因、Actor/Sendable 适用边界；临时兼容标记逐项说明安全依据与移除条件。保持依赖锁定、Flutter 关闭、保留用户文件，每批独立提交。

| 代号 | 交付 | 验收 | 真实阻塞 | 估算 |
| --- | --- | --- | --- | --- |
| A（建议 #12） | 共享源码 Shared/Generated/Assets+SwiftGen.swift 的 SwiftGen 模板/生成流程（禁止仅手改生成文件）、API、模型、AccountCookie、ACarousel 隔离与传值修复；核对两 Target 源文件成员关系 | 两 Target Debug/Release Swift 5 complete 成功，共享新增诊断消除；既有脚本测试通过 | #11 完成且用户确认发布 | 1–2 人日 |
| B | SwiftUIStudy 网络服务、状态与本地 ProgressHUD 边界修复 | 两配置 complete 构建，异步请求/分页/账号测试；中文说明 | A；若共享签名不变可提前调查 | 1–2 人日 |
| C | RxStudy 网络/HUD、Rx/Combine 回调与 UI 协议隔离修复 | 两配置 complete；账号、网络、订阅释放回归清单 | A | 2–3 人日 |
| D | 日志、全局单例、TheRouter 本地源码及 UniMP 回调隔离修复 | 两配置 complete；日志与跨端桥脚本测试；不以批量 unchecked 掩盖问题 | C 仅在接口发生依赖时，否则可独立 | 1–2 人日 |
| E | SwiftUIStudy 两配置切换 Swift 6；依赖仍按模块保留合适模式 | 生效 SWIFT_VERSION=6、Debug/Release 成功且 Swift 编译命令确认；测试通过 | A、B | 0.5–1 人日 |
| F | RxStudy 两配置切换 Swift 6；持久化 App 配置，不把所有 Pods 强制切到 6 | 生效 SWIFT_VERSION=6、Debug/Release 成功；依赖阻塞提供具体日志 | A、C、D | 1–2 人日 |
| G | 最终四项构建证据、学习记录汇总与设备回归交接 | E、F 后四项均 exit 0 + BUILD SUCCEEDED；设备结果单列，不以构建代替回归 | E、F；设备实测依赖开发者设备 | 0.5–1 人日，加设备 0.5–1 人日 |

总计约 7–13 人日，含设备 7.5–14 人日。估算基于跨 Target 共享签名、Rx 回调缺乏静态可发送保证、本地路由全局状态和日志跨队列捕获；按单人熟悉业务计算，依赖二进制运行问题另估。A 先行，SwiftUIStudy 先切换以缩小验证面，RxStudy 因调试 Pods、路由和 UniMP 边界后切换；不要求 E 完成才开始 F。

设备交接：两个 App 启动、主要页面、导航、网络成功/失败/取消、HUD、订阅释放和重复进入、图片缓存、主题资源、路由、UniMP 安装/打开/回调；Flutter 当前关闭，重新开启需单独建立依赖与设备基线。记录设备型号、系统、提交号、步骤及实际结果。

## 发布时细分约定

上表是工期分组，实际发布按以下单会话交付单元拆分，禁止把 C、D 合并成一个 Ticket。每项均沿用表中中文学习说明要求、独立提交、Swift 5 complete 和对应 Target 两配置验收。

| 单元 | 交付与独立验收 | 阻塞 |
| --- | --- | --- |
| A1（建议 #12） | SwiftGen 模板/生成流程和共享资源诊断；重新生成不丢失修复，两 Target 四项构建 | #11 与用户确认 |
| A2 | 共享 API/模型/AccountCookie/ACarousel 诊断；四项构建与相关测试 | A1（共享构建基点） |
| B1 | SwiftUI 网络服务与异步传值；两配置及请求脚本测试 | A2 |
| B2 | SwiftUI 状态、ProgressHUD 边界；两配置及分页/账号测试 | B1 |
| C1 | Rx 网络/HUD 插件隔离；两配置及请求测试 | A2 |
| C2 | Rx/Combine 回调与 UIKit 协议隔离；两配置及账号测试 | C1 |
| D1 | ModernLogging/ModernNetworkLogger 跨队列捕获；两配置及日志测试 | A2 |
| D2 | AccountServiceContainer 等全局状态与单例；两配置及账号测试 | C2 |
| D3 | 本地 TheRouter 隔离与路由共享状态；两配置并交付路由回归步骤 | A2 |
| D4 | UniMP 初始化、打开与事件回调边界；两配置并交付设备检查步骤 | A2 |

A、B、C、D 的估算为各自子单元合计，每个子单元预计半日至一天；超出单会话时按文件簇继续拆分，先交付可独立验证的边界。E 阻塞 A2/B2，F 阻塞 C2/D1/D2/D3/D4；G 阻塞 E/F。D1/D3/D4 不依赖 C2，不制造串行阻塞。

## 新对话提示词（发布 A 后核对编号）

执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #12（先核对标题为共享资源生成流程修复，若编号不同使用实际编号）。先读取该 Issue、父规格 #9、已完成 #11、docs/Swift6严格并发诊断.md 和 docs/Swift6后续任务草案.md。在 codex/swift6-migration 分支工作，保留全部用户未提交文件。保持锁定依赖、Flutter 关闭和 Swift 5 语言模式。只实施已发布 A1 任务中的共享资源生成流程修复，不提前切换 Target 或修改无关依赖。逐项依据诊断处理隔离与 Sendable，不用无安全依据的兼容标记压制告警。共享变更回查两个 Target Debug/Release，沿用 RxStudy.xcworkspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_STRICT_CONCURRENCY=complete，记录设置、完整命令、退出码与日志；运行相关脚本测试和完整现有测试。附中文学习说明、修改前后示例和安全边界，按技能审查并提交，明确设备验证待开发者执行。
