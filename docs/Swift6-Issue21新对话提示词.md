# Issue #21 新对话提示词

> 执行 `$implement`，完成 seasonZhu/RxStudy Issue #21「Swift 6 迁移：修复 UniMP 入口与事件回调的隔离边界」。先读取 #21、#9、#11 和《Swift6本地路由隔离.md》。在 `codex/swift6-migration` 分支保持用户未提交文件、锁定依赖与 Flutter 关闭状态。
>
> 只实施 UniMP 入口、初始化、安装、打开与事件回调的隔离，核实二进制回调的线程保证及 Any 参数所有权。单列无证据的线程保证，保留业务调用顺序，不提前修改缓存或切换语言模式。
>
> 先执行针对性源码编译，再用 RxStudy.xcworkspace、generic/platform=iOS、CODE_SIGNING_ALLOWED=NO、SWIFT_VERSION=5.9、SWIFT_STRICT_CONCURRENCY=complete 验证 RxStudy Debug/Release。涉及共享代码时回查 SwiftUIStudy。记录实际设置、命令、退出码及完整日志，完整运行 scripts/tests/test*.py。提供中文说明、设备验证步骤及兼容边界移除条件，完成双轴独立审查和独立提交。
