# RxStudy 开发指南

当前项目有 CocoaPods 与 Tuist 两种构建方式，两边都提供 RxStudy 和 SwiftUIStudy 两个应用 Target。

## 从这里开始

- [切换构建方式速查](docs/构建方式切换速查.md)
- [Tuist 新手实操手册](docs/工程生成新手实操手册.md)
- [可复制配置示例](docs/配置示例/工程配置示例.md)
- [SwiftGen 资源使用](docs/资源生成使用指南.md)
- [常见错误排查](docs/编译问题排查指南.md)

业务目录保持原结构。UIKit 在 RxStudy 中开发，SwiftUI 在 SwiftUIStudy 中开发，确实共用的代码放入 Shared。依赖与工程设置通过对应构建方式维护，不把生成工程当作 Tuist 的配置源。

本页替代旧的重复命令说明；旧迁移过程另见 [迁移历史](docs/迁移历史记录.md)。
