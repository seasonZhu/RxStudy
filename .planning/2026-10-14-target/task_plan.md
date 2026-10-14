# 双依赖管理双 Target 统一
## 目标
CocoaPods 与 Tuist 两条开发线共用 RxStudy、SwiftUIStudy、Shared 应用源码，保留全部旧实验。
## 已完成
- SwiftUIApp 重命名为 SwiftUIStudy；补齐 CocoaPods 双 Target。
- Tuist 补齐 UniMP、换图标、FlexLayout、崩溃与日志等旧实验依赖。
- 共享 API、模型、Cookie 规则及资源；应用源码比较零差异。
- 两种构建方式共四个 scheme 均通过无签名通用 iOS Debug 编译。
- CocoaPods 改动转到 codex/pods-dual-target；develop 保持 e7cb0c60d。
- 清理本次误导入的 45 个分支和 80 个 tag；原项目引用保留。
## 完成状态
CocoaPods 提交 1204cd716；Tuist 提交 077adb1bd。develop 提交保持 e7cb0c60d。
最后一次应用源码比较零差异，四个 scheme 编译通过。
本次误导入的 PR 引用不在用户要求的分支/tag 清理范围内，自动审批拒绝扩大清理，已保留。
