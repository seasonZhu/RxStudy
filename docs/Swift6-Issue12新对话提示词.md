# Issue #12 新对话提示词

执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #12（Swift 6 迁移：修复共享资源生成流程的并发诊断）。先读取该 Issue、父规格 #9、已完成 #11、docs/Swift6严格并发诊断.md 和 docs/Swift6后续任务草案.md。在 codex/swift6-migration 分支工作，保留全部用户未提交文件。保持锁定依赖、Flutter 关闭和 Swift 5 语言模式。只实施已发布 A1 任务中的共享资源生成流程修复，不提前切换 Target 或修改无关依赖。逐项依据诊断处理隔离与 Sendable，不用无安全依据的兼容标记压制告警。共享变更回查两个 Target Debug/Release，沿用 RxStudy.xcworkspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_STRICT_CONCURRENCY=complete，记录设置、完整命令、退出码与日志；运行相关脚本测试和完整现有测试。附中文学习说明、修改前后示例和安全边界，按技能审查并提交，明确设备验证待开发者执行。
