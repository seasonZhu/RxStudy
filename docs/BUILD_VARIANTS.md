# 双构建方式

`codex/pods-dual-target` 使用 CocoaPods，`develop-tuist` 使用 Tuist。`develop` 保持原有提交不变，CocoaPods 改造先在独立分支审阅。两条开发线都构建 `RxStudy`（UIKit + RxSwift）与 `SwiftUIStudy`（SwiftUI）。源码目录 `RxStudy/`、`SwiftUIStudy/`、`Shared/` 及业务资源应保持一致；依赖清单与工程定义分别维护。

建议把两条分支放在独立的 Git worktree。切换项目时打开对应目录的工程，避免 Pods、Tuist 缓存和生成工程相互覆盖。不要在同一工作目录反复切换这两个分支。

## CocoaPods

```sh
bash scripts/swiftgen.sh
pod install
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

`Podfile.lock` 固定 CocoaPods 解析结果。UIKit 的 UniMP、FlexLayout 等实验使用当前 Podfile 中的版本。SwiftUIStudy 的 ProgressHUD 使用仓库中 15.0.1 源码快照，对齐 Tuist 使用的版本。

## Tuist

```sh
bash scripts/swiftgen.sh
tuist install
tuist generate
xcodebuild -workspace RxStudy.xcworkspace -scheme RxStudy -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -workspace RxStudy.xcworkspace -scheme SwiftUIStudy -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

`mise.toml` 固定 Tuist 版本，`Tuist/Package.resolved` 固定 SPM 依赖版本。`Project.swift` 是工程定义；Xcode 工程由 Tuist 生成。无法通过 SPM 直接使用的旧实验依赖保存在 `Packages/ThirdParty`，其版本来自 CocoaPods 旧锁文件；UniMP 为 4.36，本地二进制与资源随目录保存。

## 同步约定

先确认改动属于源码还是构建配置。功能修复、API 常量、模型、资源和两个 Target 的页面修改都同步到两条分支；Podfile、Project.swift、Tuist/Package.swift 只在各自的构建分支维护。同步后运行 `scripts/check-shared-sources.py` 比较两个 worktree，并分别编译两个 scheme。两条分支没有共同祖先，采用小范围补丁或文件同步，不做整分支合并。

`Shared/API` 持有 API 路径定义，`Shared/Models` 持有共用数据模型，`Shared/Business` 持有共用 Cookie 规则，`Shared/Resources` 持有图片、启动页和 JavaScript。RxSwift 与 async/await 的适配代码分别保留在各自 Target。
