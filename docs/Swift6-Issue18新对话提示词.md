# 下一项任务：Issue #18（C2）

技术前置 #14 已提交并有构建证据，GitHub 仍为 OPEN。下方提示词包含明确的状态豁免；开发者决定继续时可直接使用。Issue #17 的实现与验证见《Swift6Rx网络与HUD隔离.md》，设备验证仍由开发者执行。

```text
执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #18（Swift 6 迁移：修复 Rx 与 Combine 回调及 UIKit 隔离）。先读取 #18、#9、#11、#14、#17 及现有 Swift6 修复文档。授权以已提交且验证过的 #14 实现作为前置基线，忽略其 GitHub OPEN 状态继续本任务。保持 codex/swift6-migration、用户未提交文件、锁定依赖、Flutter 关闭和 Swift 5 模式。

只实施 C2，依据真实诊断处理 Rx/Combine 回调、网络监听写 Relay 与 UIKit 协议隔离，逐项说明调度语义变化。复用 C1 的 LoadingProvider/令牌收尾，不重复实现活动计数；回查 C1 隔离传播后暴露的 CombineCoinRankListViewModel.futureTest 中 Future.value 非 Sendable 跨主 Actor 告警，以及既有主题、刷新 PreferenceKey 和 UIKit 回调诊断，按证据界定范围。

先源码针对性编译，稳定后按 Issue 执行 RxStudy Debug/Release 严格构建、账号与相关请求脚本，结束时完整运行现有脚本。沿用 RxStudy.xcworkspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete。记录命令、实际设置、退出码、完整日志及既有日志脚本 legacy 断言失败，区分编译、自动化测试、环境阻塞与设备验证。附中文前后示例、Actor/Sendable 安全边界、订阅释放和重复进入的设备步骤；完成双轴审查并独立提交。设备验证由开发者执行。完成后提供下一项就绪任务提示词。
```
