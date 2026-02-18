# Copilot / AI 助手使用指南 — RxStudy 🧭

目标：帮助 AI 代码助手快速在本仓库中上手，通过指出架构要点、开发流程、关键 API 与项目约定，让自动化修改和提议更可靠。

## 快速概览（总体架构）
- 这是一个基于 Swift 的 wanandroid 客户端，使用 MVVM + RxSwift + Moya 进行实现；项目还集成了 Flutter 与 UniApp 模块，分别位于 `flutter_module` 与 `DevelopmentPods`，通过 CocoaPods 集成。
- 主要模式：ViewController 绑定到继承自 `BaseViewModel` 的 ViewModel；网络层使用 Moya 的 `TargetType` 枚举（如 `HomeService`、`MyService` 等）；所有后端响应使用 `BaseModel<T>` 进行统一包装。

## 快速启动（本地开发） ✅
- 若修改 Flutter 模块（只在需要时）：
  - cd `flutter_module` && `flutter pub get`
  - 若遇到插件对 iOS 部署版本要求高，参考 `.ios/Podfile` 的说明进行调整。
- iOS 工作流：
  - 运行 `pod install`（遇到依赖问题可先 `pod repo update`）
  - 使用 Xcode 14+ 打开 `RxStudy.xcworkspace`（工程使用 Swift 5.7 语法）
  - Apple Silicon / 模拟器：参见 `Podfile` 中的 `post_install` 示例（设置 `ONLY_ACTIVE_ARCH = NO`）以避免模拟器编译问题。
- Fastlane（发布自动化）：
  - 上传蒲公英：`bundle exec fastlane ios pg version:1.0.0 mode:Debug env:pre changelog:"..."`
  - 上传 TestFlight：`bundle exec fastlane ios beta changelog:"..."`
  - 具体配置与 secret（如 `FASTLANE_SESSION`、专用密码）见 `fastlane/Fastfile`。

## 关键文件与入口（快速定位） 🔎
- 项目总览：`README.md`
- API 列表：`RxStudy/HttpRequest/Api/Api.swift`
- Moya provider 集中配置：`RxStudy/HttpRequest/Service/Provider.swift`
- 网络响应包装：`RxStudy/HttpRequest/Model/BaseModel.swift`
- ViewModel 基类：`RxStudy/Base/BaseViewModel.swift`
- 账号/状态管理：`RxStudy/Account/Manager/AccountManager.swift`
- 响应缓存插件：`RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift`
- 常用属性包装器：`RxStudy/Extension/Utils/PropertyWrapper.swift`（如 `@UserDefault`, `@CodableUserDefault`）
- Flutter 端网络插件对照：`flutter_module/lib/http_util/plugins.dart`

## 项目约定与实践（必须遵守） ⚙️
- MVVM + Rx:
  - 所有 ViewModel 继承自 `BaseViewModel`，使用 `HasDisposeBag` 或 `disposeBag` 管理订阅。
  - 使用 `BehaviorRelay` / `BehaviorSubject` 暴露输出与状态。
- 网络调用（规范示例）：
  - 选择合适的 provider（例如 `homeProvider`, `myProvider`）
  - 将响应映射为 `BaseModel<T>`，再取 `.data` 字段：

```swift
homeProvider.rx.request(HomeService.banner)
  .map(BaseModel<[Banner]>.self)
  .map { $0.data }
  .compactMap { $0 }
  .asObservable()
  .asSingle()
  .subscribe { event in ... }
  .disposed(by: disposeBag)
```
- `BaseModel<T>`：后端返回的标准结构包含 `errorCode`、`errorMsg`、`data`，在依赖 `data` 之前请始终检查 `isSuccess`。
- 登录态相关：`myProvider` 使用 `endpointClosure` 在登录时自动添加 `cookie` 请求头（参见 `Provider.swift` 中的实现），修改认证逻辑时需同步更新 `AccountManager.cookieHeaderValue` 与对应 provider。
- 加载提示与拦截：`activityPlugin` 用于统一控制 `SVProgressHUD` 的显示/隐藏；有些 API 被加入 `blackList`（在 `Provider.swift` 中）以跳过 loading 行为，新增接口时注意是否需要加入或排除。
- 缓存：`ResponseCachePlugin` 以 `"target.path + task.parametersString"` 作为键进行缓存，修改缓存策略请同时更新该插件。
- 本地持久化：首选属性包装器（`@UserDefault` / `@CodableUserDefault`）而非零散使用 `UserDefaults`。
- 注意：仓库包含 `RxBlocking` 仅用于测试或演示，请勿在生产代码中引入同步阻塞模式。

## 跨模块（Flutter）互通要点 🔁
- `AccountManager` 中含有启动 Flutter 引擎并传递登录信息的逻辑（`runFlutterEngine`, `nativeNotifyToFlutter`），若调整登录/同步逻辑需同时更新 iOS 与 `flutter_module/lib/account_manager` 的实现。
- iOS（Moya + Plugin）与 Flutter（Dio + Interceptor）在网络处理上有并行实现，修改端点或错误展示时尽量保持两端行为一致（如 loading、错误 toast、拦截策略）。

## 常见陷阱与注意事项 ⚠️
- 编译环境：需要 Xcode 14+ 与 Swift 5.7；旧版 Xcode 可能因语法或编译选项导致失败。
- Apple Silicon：Podfile 中有示例 `post_install` 语句以解决模拟器编译问题（`ONLY_ACTIVE_ARCH = NO`）。
- `ResponseCachePlugin` 的实际后端可选（`Cache` / `YYCache` / `UserDefaults`），在不同构建或测试配置下行为可能会有所差异。
- 仓库包含一些本地 Pod（在 `DevelopmentPods/` 下，例如 `HttpRequest`, `HUD`），如修改这些模块请保持本地路径或更新 podspec，避免 CI/合并后破坏依赖。

## 适合 AI 助手的入门任务（Good first tasks）
- 按规范实现一个小型 ViewModel 的网络调用（遵循 map -> compactMap -> 调用 `processRxMoyaRequestEvent` 处理错误）
- 向 `Api.swift` 添加新接口：新增 `TargetType` case，更新 provider/缓存策略，并添加一个示例请求/映射示例
- 更新网络插件（例如调整 `blackList`）并通过一个真实接口验证行为

---
如果你希望我扩展某个章节（例如补充 Fastlane 的发布示例、提供一个新增 API 的代码补丁或测试用例），告诉我想要补充的部分，我会继续完善。🙋‍♂️