# Tuist Registry、Cloud 与缓存：进阶阅读

日常开发先读 [新手手册](docs/工程生成新手实操手册.md)。本页保留旧链接入口，不作为首次打开工程的操作要求。

## 当前项目状态

当前 Tuist.swift 配置：`fullHandle: nil`、`enableCaching: false`、`registryEnabled: false`。本地生成工程不需要 Cloud 登录，也不需要运行 registry setup。SPM 依赖目前通过仓库 URL 与本地路径声明。

Registry 提供另一种包分发与解析方式；Cloud 和缓存是独立的进阶能力。启用其中一项不意味着其他项自动可用，也不能由此保证下载或编译更快。

## 将来需要时如何评估

先明确要解决的是网络下载、工程生成还是编译耗时，再核对固定版本 4.200.4 对相应配置和命令的支持。官方文档可能描述较新版本，不直接把新字段复制进当前配置。

在单独分支评估，记录服务要求、认证方式、依赖覆盖、离线行为和退出方式；用相同机器与构建条件比较启用前后结果。没有本项目实测数据时，不写固定速度提升百分比。

本教程不修改服务配置、不提供占位凭证、不要求登录，也不保留旧教程中未经本项目验证的性能表。若确实要启用，单独制定和验证配置方案。

官方入口：[Tuist 文档](https://tuist.dev/en/docs)、[Tuist 依赖管理](https://tuist.dev/en/docs/guides/features/projects/dependencies)。
