# 下一项就绪任务：Issue #20（D2）

#20《Swift 6 迁移：修复本地路由源码的全局状态与隔离》仅阻塞于已关闭的 #11，可继续实施。#19 设备检查由开发者执行。

```text
执行 [$implement](/Users/dy/.cc-switch/skills/implement/SKILL.md)，完成 seasonZhu/RxStudy Issue #20。先读取 #20、#9、#11、《Swift6回调与UIKit隔离.md》《Swift6日志导出与单例隔离.md》及本地路由相关诊断。保持 codex/swift6-migration、用户未提交文件、锁定依赖、Flutter 关闭和 Swift 5 模式。

只实施 D2：依据真实诊断检查 Packages/ThirdParty/TheRouter 的注册表、拦截器、协议和 UI 跳转所有权，不能将本地源码当外部 Swift 5 模块绕过；保留路由注册、匹配、拦截和跳转顺序。不提前实施 UniMP、缓存或语言模式切换。记录每个 Actor/Sendable 边界和临时兼容声明的依据与移除条件。

先源码针对性编译，稳定后执行 RxStudy Debug/Release 严格构建；涉及共享代码回查 SwiftUIStudy。使用 RxStudy.xcworkspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete，可复用独立 DerivedData。记录完整命令、实际设置、退出码、完整日志及环境问题。结束完整运行 scripts/tests/test*.py。附中文前后示例、路由注册/匹配/拦截/跳转设备步骤，完成双轴独立审查及独立提交。设备验证由开发者执行；提供下一项就绪任务提示词。
```
