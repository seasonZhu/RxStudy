# Swift 6 后续任务（已确认并发布）

用户于 2026-11-17 确认发布，全部关联父规格 #9，使用 ready-for-agent 标签与 GitHub 原生阻塞关系。#9 的正文与状态未修改。

## 已发布任务与真实依赖

| 单元 | GitHub 任务 | 阻塞于 |
| --- | --- | --- |
| A1 | [#12 Swift 6 迁移：修复共享资源生成流程的并发诊断](https://github.com/seasonZhu/RxStudy/issues/12) | #11 |
| A2 | [#13 Swift 6 迁移：修复共享模型与轮播状态的并发边界](https://github.com/seasonZhu/RxStudy/issues/13) | #11 |
| D2 | [#14 Swift 6 迁移：修复账号与全局状态的并发访问](https://github.com/seasonZhu/RxStudy/issues/14) | #11 |
| B1 | [#15 Swift 6 迁移：修复 SwiftUI 网络服务的可发送性边界](https://github.com/seasonZhu/RxStudy/issues/15) | #11 |
| B2 | [#16 Swift 6 迁移：修复 SwiftUI 页面状态与本地 HUD 隔离](https://github.com/seasonZhu/RxStudy/issues/16) | #11 |
| C1 | [#17 Swift 6 迁移：修复 Rx 网络与 HUD 插件的隔离边界](https://github.com/seasonZhu/RxStudy/issues/17) | #14 |
| C2 | [#18 Swift 6 迁移：修复 Rx 与 Combine 回调及 UIKit 隔离](https://github.com/seasonZhu/RxStudy/issues/18) | #14 |
| D1 | [#19 Swift 6 迁移：修复日志导出与日志单例的跨队列捕获](https://github.com/seasonZhu/RxStudy/issues/19) | #11 |
| D3 | [#20 Swift 6 迁移：修复本地路由源码的全局状态与隔离](https://github.com/seasonZhu/RxStudy/issues/20) | #11 |
| D4 | [#21 Swift 6 迁移：修复 UniMP 入口与事件回调的隔离边界](https://github.com/seasonZhu/RxStudy/issues/21) | #11 |
| E | [#22 Swift 6 迁移：切换 SwiftUIStudy 为 Swift 6 语言模式](https://github.com/seasonZhu/RxStudy/issues/22) | #12、#13、#15、#16 |
| F | [#23 Swift 6 迁移：切换 RxStudy 为 Swift 6 语言模式](https://github.com/seasonZhu/RxStudy/issues/23) | #12、#13、#17、#18、#19、#14、#20、#21 |
| G | [#24 Swift 6 迁移：完成 Swift 6 四项编译验收与设备回归交接](https://github.com/seasonZhu/RxStudy/issues/24) | #22、#23 |

## 依赖核对结论

- 移除原草案中 A1→A2 及共享批次→日志/路由/UniMP 等顺序性依赖；没有源码证据证明这些任务必须等待其他修复完成。各项以已完成 #11 为起点，可独立开始。
- 账号状态所有权影响网络 Provider 和网络监听 Relay 写入，因此网络/HUD、Rx/Combine 回调修复等待账号状态任务。账号任务必须同步调整必要调用端，保证自身构建通过；后续任务承担剩余诊断，不留半成品接口。
- SwiftUI 网络与页面/HUD 可独立修复；最终切换等待两者及共享资源、共享模型修复。RxStudy 切换等待该 Target 的所有相关修复。最终验收等待两个切换完成。
- 共享文件相互影响时在同一迁移分支顺序提交并复验，不把潜在编辑冲突伪装为技术阻塞。

建议先 #12，再按就绪任务推进；优先完成 SwiftUIStudy 切换以缩小验证面，但 RxStudy 切换不人为依赖 SwiftUIStudy 切换。

## 工期、学习与验证要求

发布时按细分任务重新加总，单人预计 8–15 人日，设备另计 0.5–1 人日。原 7–13 人日是粗分组估算；细分后补计日志、路由及跨端边界独立验收。依据为 #11 观察到的生成资源共享状态、异步传值、Rx 回调约束、本地路由与日志跨队列捕获。复杂任务超过单次会话时应按可独立验证的调用路径再拆分，不承诺半日至一天必然完成。

每项 Issue 已包含交付、验收、真实阻塞、估算和中文学习说明：实际诊断、修改前后示例、原因及边界；临时兼容标记须说明必要性、安全依据与移除条件。保持锁定依赖、Flutter 关闭、保留用户文件。修复阶段保持 Swift 5 complete；切换任务才持久化目标 App 的 Swift 6 设置。依赖模块独立决定语言模式，不批量强制到 Swift 6。

设备由开发者验证；交接覆盖两个 App 的启动、页面、导航、网络成功/失败/取消、HUD、订阅释放与重复进入、图片缓存、主题资源、路由和 UniMP。Flutter 启用需另建基线。最终任务交付编译证据与设备清单，尚未执行的设备结果必须明确标记，不宣称整个规格已完成设备验收。

## 第一项新对话提示词

执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #12（Swift 6 迁移：修复共享资源生成流程的并发诊断）。先读取该 Issue、父规格 #9、已完成 #11、docs/Swift6严格并发诊断.md 和 docs/Swift6后续任务草案.md。在 codex/swift6-migration 分支工作，保留全部用户未提交文件。保持锁定依赖、Flutter 关闭和 Swift 5 语言模式。只实施已发布 A1 任务中的共享资源生成流程修复，不提前切换 Target 或修改无关依赖。逐项依据诊断处理隔离与 Sendable，不用无安全依据的兼容标记压制告警。共享变更回查两个 Target Debug/Release，沿用 RxStudy.xcworkspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_STRICT_CONCURRENCY=complete，记录设置、完整命令、退出码与日志；运行相关脚本测试和完整现有测试。附中文学习说明、修改前后示例和安全边界，按技能审查并提交，明确设备验证待开发者执行。
