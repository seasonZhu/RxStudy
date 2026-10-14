# 双依赖管理双 Target 统一
## Goal
两条开发线共用 RxStudy、SwiftUIStudy、Shared 源码，仅依赖和工程配置不同，独立 worktree。
## Next Step
统一 Tuist 命名与依赖锁定；确认旧实验功能的共同基线。
### Phase 1: 差异核对
**Status:** in_progress
- 当前 develop 脏文件保持不动。
- Tuist 分支没有 UniApp、换图标入口，FlexLayout 示例已屏蔽；基线待用户回答。
### Phase 2: Tuist 命名与构建
**Status:** pending
### Phase 3: CocoaPods 双 Target
**Status:** pending
### Phase 4: 同步规则与验证
**Status:** pending
## Decisions Made
- 保留历史；develop 与 develop-tuist 长期演进。
- SwiftUIApp 重命名 SwiftUIStudy。
- 允许 CocoaPods 分支少量 SPM/源码例外。
