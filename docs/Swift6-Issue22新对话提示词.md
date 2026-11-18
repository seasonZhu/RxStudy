# Issue #22 新对话提示词

> 执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #22「Swift 6 迁移：切换 SwiftUIStudy 为 Swift 6 语言模式」。先读取 #22、#9、#11，核对前置 #12、#13、#15、#16 的交付和相关中文说明，并对照《Swift6严格并发诊断.md》。在 `codex/swift6-migration` 分支工作，保留用户未提交文件、当前锁定依赖与 Flutter 关闭状态。尤其先核对 `RxStudy.xcodeproj/project.pbxproj` 的现有未提交差异，仅编辑并提交本任务所需的配置变更。
>
> 只持久化 SwiftUIStudy 应用 Target 的 Debug 和 Release Swift 6 语言设置。检查依赖模块实际使用的语言模式，保留适合各模块的设置。若遇到编译错误，先区分应用源码、共享源码、锁定依赖和环境问题。需要修复时，先在 Swift 5 和 `SWIFT_STRICT_CONCURRENCY=complete` 下复现并做最小修复；必要的依赖升级单列证据与后续任务。RxStudy 语言切换留给 #23，最终双 Target 四项验收留给 #24。若修改共享源码，回查 RxStudy 的 Debug 和 Release，沿用该 Target 当前语言模式。
>
> 用 `RxStudy.xcworkspace`、`-scheme SwiftUIStudy`、`-destination generic/platform=iOS`、`CODE_SIGNING_ALLOWED=NO` 分别验证 Debug 和 Release。验收命令不传全局 `SWIFT_VERSION`，通过 `-showBuildSettings` 确认应用 Target 持久化为 `SWIFT_VERSION=6`，并从两配置的实际 Swift 编译命令确认应用模块使用 `-swift-version 6`。两次构建均须退出 0 且出现 `BUILD SUCCEEDED`。记录应用与相关依赖的生效设置、完整命令、退出码和未截断日志，对照 #11 解释本轮诊断变化，单列范围外既有告警。完整运行 `scripts/tests/test*.py`，逐文件记录结果；缺少行为测试接缝时说明验证范围。
>
> 提交中文学习说明，包含实际诊断、配置和必要源码的修改前后示例、选择理由、Actor 与 Sendable 边界，以及临时兼容措施的必要性、安全依据和移除条件。给出 SwiftUIStudy 真机回归步骤，区分编译、自动化测试、环境阻塞和开发者待验证项。按 implement 完成 Standards / Spec 双轴独立审查，将本任务改动独立提交。
