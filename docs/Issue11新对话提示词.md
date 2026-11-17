执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy 的 Issue #11。

先读取 #11、父规格 #9 及已完成的 #10，在 codex/swift6-migration 分支上实施。阅读 docs/Swift6编译基线.md；基点为 648f01214f663a0345cdbd71c6a24f1fa9d625b3，四项基线均成功，日志在 Derived/swift6-baseline/。保持当前锁定依赖与 Flutter 关闭状态，保留用户已有未提交文件。

保持 Swift 5 语言模式，分别对 RxStudy、SwiftUIStudy 的 Debug/Release 执行完整严格并发检查，使用既有 workspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO。记录生效设置、完整命令、退出码与日志，区分基线告警与新增诊断。按 #11 要求覆盖共享代码、UI 隔离、可发送性、全局状态及依赖边界，检查本地维护源码和实际跨端入口。

输出中文诊断清单、依赖兼容结论、迁移顺序、带依据的工期估算及后续修复任务草案；每项包含交付、验收、真实阻塞关系与中文学习说明要求。草案覆盖共享修复、两个 Target 切换、最终四项编译和设备回归交接。提交用户确认后再发布后续任务，不提前实施后续迁移。按技能完成审查并提交本任务改动，最终明确验证范围和遗留项。
