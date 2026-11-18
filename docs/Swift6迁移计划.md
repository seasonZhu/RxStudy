# Swift 6 迁移计划

## 已确认目标

2026-11-17 确认，两个 App Target 的 Debug、Release 最终启用 Swift 6 语言模式并编译通过。采用边迁移边学习的节奏，保留现有 RxSwift、Combine 业务组织方式，最低支持 iOS 17.6。自动验收使用编译检查，设备运行回归由开发者完成。

迁移分支为 `codex/swift6-migration`，从当前 `develop` 创建。每批修复独立提交，提交信息说明诊断类型与验证结果。

## 当前事实

- 本机 Xcode 26.3，Build 17C529。
- `RxStudy` 与 `SwiftUIStudy` 的 Debug、Release 均显式设置 `SWIFT_VERSION = 5.9`，尚未发现显式完整严格并发配置。
- 当前 workspace 使用 CocoaPods。RxStudy 包含 RxSwift/RxCocoa 6.9.0、Moya 15.0.0、Kingfisher 8.6.2 及 UIKit、ObjC、跨端依赖。
- SwiftUIStudy 包含 Moya 15.0.0、Alamofire 5.11.0、Kingfisher 8.6.2、本地 ProgressHUD。
- 本地 TheRouter 包的 tools version 为 5.9，需要单独检查语言模式与共享状态。
- Flutter 接入受 `.flutter-enabled` 控制，基线应记录实际启用状态。
- CodeGraph 可用，部分索引已过期，问题定位结合源码与实际编译诊断。
- 仓库已有 CocoaPods/Tuist 切换约定，后续若同步另一构建分支，需要分别验证工程配置。

## 阶段与验收

| 阶段 | 工作 | 验收与产出 |
| --- | --- | --- |
| 1 基线 | 记录分支提交、工具链、锁文件、Flutter 开关，分别编译两个 Target 的 Debug/Release | 四项编译结果与日志路径，区分已有错误与迁移新增错误 |
| 2 诊断 | 保持 Swift 5 语言模式，逐 Target 开启完整严格并发检查 | 按共享代码、UI 隔离、可发送性、全局状态、依赖边界归类诊断，估算工作量 |
| 3 修复 | 优先共享代码，再逐模块处理诊断，每批回查两个 Target | 每批具备中文说明和编译结果，避免修复一个 Target 后破坏另一个 |
| 4 切换 | 逐个 Target 启用 Swift 6 语言模式，同时验证 Debug/Release | 四项构建通过，本地包与生成资源引用正常 |
| 5 收尾 | 汇总迁移写法、检查临时兼容标记、完成设备回归清单 | 编译证据完整，设备结果由开发者记录，合并前复核全部差异 |

建议按阶段安排工作，阶段 2 完成后依据诊断数量、依赖阻塞与共享代码影响估算人日。先迁移哪个 Target 由诊断结果决定，优先选择可独立验证且依赖阻塞较少的一侧。

## 学习与修改顺序

1. 语言模式和严格并发检查。先理解诊断何时成为错误，确认每个模块的设置生效范围。
2. Actor 隔离和 `@MainActor`。检查 UIViewController、SwiftUI 状态、HUD、网络回调更新 UI 的路径。
3. `Sendable` 与 `@Sendable`。检查 Task、DispatchQueue 闭包捕获和跨隔离域传值，结合值类型与可变引用理解安全条件。
4. 全局可变状态、单例与静态属性。逐项确认访问线程和所有权，再决定隔离或同步策略。
5. 协议实现与依赖边界。检查 Rx、Combine、ObjC 回调与 SDK 声明之间的隔离约束。
6. 兼容措施。采用 `@preconcurrency`、`@unchecked Sendable` 或 `nonisolated(unsafe)` 时，逐项记录必要性、安全依据与后续处理条件。

每批说明包含原始诊断、原代码、修改后代码、修改原因和其他适用场景。代码示例以仓库实际修复为依据，随实施补充。

## 依赖处理

先验证当前锁定版本，按实际诊断识别阻塞依赖。确需升级时单独提交依赖声明与锁文件，并验证两个 Target。第三方模块的语言模式按模块兼容情况配置，本地维护源码单独纳入检查。重新安装 Pods 后复核设置，确保修复持续生效。

## 编译矩阵

对 `RxStudy`、`SwiftUIStudy` 各执行 Debug 和 Release，使用以下命令替换对应参数。

```sh
xcodebuild -workspace RxStudy.xcworkspace \
  -scheme RxStudy \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO build
```

基线、严格并发阶段、Swift 6 阶段分别保存日志与结果。成功条件为退出码 0 且日志包含 `BUILD SUCCEEDED`。耗时过长或环境阻塞时记录实际进度、首个阻塞原因和复验命令，由开发者补充编译结果。

## 设备回归清单

- 两个 App 的启动、首页、导航和主要页面。
- 网络成功、失败、取消后的 UI 更新与 HUD 展示。
- RxSwift/Combine 订阅、页面释放和重复进入。
- 图片加载、缓存、主题与资源读取。
- 路由跳转，以及当前启用的 UniApp、Flutter 入口。

## 当前执行记录

- 已完成仓库配置与依赖的只读检查。
- 已创建迁移分支。
- 尚未执行基线构建、严格并发诊断或源码迁移。

## 参考

- [Swift 官方迁移指南](https://www.swift.org/migration/documentation/migrationguide/)
- [构建方式切换速查](构建方式切换速查.md)
