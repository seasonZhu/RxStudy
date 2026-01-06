# Copilot / AI Agent Instructions for RxStudy 🧭

Goal: Help an AI code assistant be productive immediately in this codebase by calling out architecture, dev workflows, key APIs and conventions that are specific to this project.

## Quick context (big picture)
- iOS client for WanAndroid implemented in Swift using MVVM + RxSwift + Moya. Flutter and UniApp modules exist under `flutter_module` / `DevelopmentPods` and are integrated via CocoaPods.
- Main patterns: ViewControllers bind to ViewModels (subclass `BaseViewModel`), network calls use Moya `TargetType` enums (`HomeService`, `MyService`, ...), and all API responses are wrapped in `BaseModel<T>`.

## Quick start (local dev) ✅
- Flutter module (if changing Flutter code):
  - cd `flutter_module` && `flutter pub get`
  - follow `.ios/Podfile` notes if plugin requires higher iOS version.
- iOS workspace:
  - `pod install` (edit `Podfile` or run `pod repo update` if dependency issues)
  - open `RxStudy.xcworkspace` in Xcode 14+ (project uses Swift 5.7 syntax)
  - For Apple Silicon/dev simulator see the `post_install` snippet in `Podfile` (ONLY_ACTIVE_ARCH / simulator tweaks).
- Fastlane (release automation):
  - `bundle exec fastlane ios pg version:1.0.0 mode:Debug env:pre changelog:"..."` (pgyer)
  - `bundle exec fastlane ios beta changelog:"..."` (TestFlight)
  - See `fastlane/Fastfile` for env vars (FASTLANE_SESSION, FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD) and lane details.

## Where to look (most important files) 🔎
- App-level: `README.md` (project overview)
- API list: `RxStudy/HttpRequest/Api/Api.swift`
- Moya providers: `RxStudy/HttpRequest/Service/Provider.swift`
- Base networking models: `RxStudy/HttpRequest/Model/BaseModel.swift`
- ViewModel base: `RxStudy/Base/BaseViewModel.swift`
- Account state: `RxStudy/Account/Manager/AccountManager.swift`
- Response cache: `RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift`
- Property wrappers: `RxStudy/Extension/Utils/PropertyWrapper.swift` (`@UserDefault`, `@CodableUserDefault`)
- Flutter plugin parallels: `flutter_module/lib/http_util/plugins.dart`

## Project-specific patterns & conventions (use these exactly) ⚙️
- MVVM + Rx pattern
  - ViewModels subclass `BaseViewModel` and use `disposeBag`/`HasDisposeBag`.
  - Use `BehaviorRelay`/`BehaviorSubject` for outputs and state.
- Network calls (canonical example):
  - Choose provider (global `homeProvider`, `myProvider`, etc.)
  - Call Moya and map to `BaseModel<T>` then to `.data`:

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
- `BaseModel<T>`: API responses use `errorCode`, `errorMsg`, `data`. Check `isSuccess` before relying on `data`.
- `myProvider` special case: its `endpointClosure` adds a `cookie` header when `AccountManager.shared.isLoginRelay.value == true` (see `Provider.swift`). When modifying auth behavior, update `AccountManager.cookieHeaderValue` and relevant providers.
- Loading / UI feedback: `activityPlugin` (Moya plugin) shows/hides `SVProgressHUD`. Some APIs are excluded from loading via `blackList` (see `Provider.swift`). Keep that behavior when you add similar APIs.
- Caching: `ResponseCachePlugin` caches responses keyed by `target.path + parametersString`. If you change caching rules, update this plugin.
- Property wrappers used for local persistence (`@UserDefault`, `@CodableUserDefault`) are preferred over direct `UserDefaults` calls.
- Avoid `RxBlocking` in production code (it's used for tests/demos). The README calls out this specifically.

## Cross-component / Flutter integration notes 🔁
- `AccountManager` contains code to start the Flutter engine and pass login info (`runFlutterEngine`, `nativeNotifyToFlutter`). If you change login/account state flows, update both iOS `AccountManager` and Flutter's `AccountManager` under `flutter_module/lib/account_manager`.
- Flutter and iOS network stacks mirror each other: iOS uses Moya + plugins; Flutter uses Dio + interceptors (see `flutter_module/lib/http_util/plugins.dart`). Keep behaviors (loading, intercept, error toast) consistent when changing endpoints.

## Useful edges and gotchas ⚠️
- Xcode target / Swift version: repo requires Xcode 14+, Swift 5.7 features—some contributors report Xcode compile issues when using older versions.
- CocoaPods architecture differences on Apple Silicon: Podfile contains an example `post_install` to set `ONLY_ACTIVE_ARCH = NO` for simulators.
- `ResponseCachePlugin` uses different storage backends depending on available libraries (`Cache`, `YYCache`, or `UserDefaults`)—be aware tests on Debug/Release may behave differently.
- There are some local development pods under `DevelopmentPods/` (e.g., `HttpRequest`, `HUD`). If you change them, keep them local or update Podspecs accordingly.

## Good first tasks for an AI agent
- Implement small ViewModel change using the canonical network pattern (map -> compactMap -> handle success/failure via `processRxMoyaRequestEvent`)
- Add a new API entry to `Api.swift` and corresponding `TargetType` case + add mapping & caching rules
- Update network plugin (e.g., adjust `blackList`) and ensure unit behaviour by testing an example request

---
If any section is unclear or you want me to expand with concrete code examples/tests or add a checklist for PRs/commits, tell me which parts to expand. 🙋‍♂️
## Quick start (local dev) ✅
- Flutter module (if changing Flutter code):
  - cd `flutter_module` && `flutter pub get`
  - follow `.ios/Podfile` notes if plugin requires higher iOS version.
- iOS workspace:
  - `pod install` (edit `Podfile` or run `pod repo update` if dependency issues)
  - open `RxStudy.xcworkspace` in Xcode 14+ (project uses Swift 5.7 syntax)
  - For Apple Silicon/dev simulator see the `post_install` snippet in `Podfile` (ONLY_ACTIVE_ARCH / simulator tweaks).
- Fastlane (release automation):
  - `bundle exec fastlane ios pg version:1.0.0 mode:Debug env:pre changelog:"..."` (pgyer)
  - `bundle exec fastlane ios beta changelog:"..."` (TestFlight)
  - See `fastlane/Fastfile` for env vars (FASTLANE_SESSION, FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD) and lane details.

## Where to look (most important files) 🔎
- App-level: `README.md` (project overview)
- API list: `RxStudy/HttpRequest/Api/Api.swift`
- Moya providers: `RxStudy/HttpRequest/Service/Provider.swift`
- Base networking models: `RxStudy/HttpRequest/Model/BaseModel.swift`
- ViewModel base: `RxStudy/Base/BaseViewModel.swift`
- Account state: `RxStudy/Account/Manager/AccountManager.swift`
- Response cache: `RxStudy/HttpRequest/Plugin/ResponseCachePlugin.swift`
- Property wrappers: `RxStudy/Extension/Utils/PropertyWrapper.swift` (`@UserDefault`, `@CodableUserDefault`)
- Flutter plugin parallels: `flutter_module/lib/http_util/plugins.dart`

## Project-specific patterns & conventions (use these exactly) ⚙️
- MVVM + Rx pattern
  - ViewModels subclass `BaseViewModel` and use `disposeBag`/`HasDisposeBag`.
  - Use `BehaviorRelay`/`BehaviorSubject` for outputs and state.
- Network calls (canonical example):
  - Choose provider (global `homeProvider`, `myProvider`, etc.)
  - Call Moya and map to `BaseModel<T>` then to `.data`:

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
- `BaseModel<T>`: API responses use `errorCode`, `errorMsg`, `data`. Check `isSuccess` before relying on `data`.
- `myProvider` special case: its `endpointClosure` adds a `cookie` header when `AccountManager.shared.isLoginRelay.value == true` (see `Provider.swift`). When modifying auth behavior, update `AccountManager.cookieHeaderValue` and relevant providers.
- Loading / UI feedback: `activityPlugin` (Moya plugin) shows/hides `SVProgressHUD`. Some APIs are excluded from loading via `blackList` (see `Provider.swift`). Keep that behavior when you add similar APIs.
- Caching: `ResponseCachePlugin` caches responses keyed by `target.path + parametersString`. If you change caching rules, update this plugin.
- Property wrappers used for local persistence (`@UserDefault`, `@CodableUserDefault`) are preferred over direct `UserDefaults` calls.
- Avoid `RxBlocking` in production code (it's used for tests/demos). The README calls out this specifically.

## Cross-component / Flutter integration notes 🔁
- `AccountManager` contains code to start the Flutter engine and pass login info (`runFlutterEngine`, `nativeNotifyToFlutter`). If you change login/account state flows, update both iOS `AccountManager` and Flutter's `AccountManager` under `flutter_module/lib/account_manager`.
- Flutter and iOS network stacks mirror each other: iOS uses Moya + plugins; Flutter uses Dio + interceptors (see `flutter_module/lib/http_util/plugins.dart`). Keep behaviors (loading, intercept, error toast) consistent when changing endpoints.

## Useful edges and gotchas ⚠️
- Xcode target / Swift version: repo requires Xcode 14+, Swift 5.7 features—some contributors report Xcode compile issues when using older versions.
- CocoaPods architecture differences on Apple Silicon: Podfile contains an example `post_install` to set `ONLY_ACTIVE_ARCH = NO` for simulators.
- `ResponseCachePlugin` uses different storage backends depending on available libraries (`Cache`, `YYCache`, or `UserDefaults`)—be aware tests on Debug/Release may behave differently.
- There are some local development pods under `DevelopmentPods/` (e.g., `HttpRequest`, `HUD`). If you change them, keep them local or update Podspecs accordingly.

## Good first tasks for an AI agent
- Implement small ViewModel change using the canonical network pattern (map -> compactMap -> handle success/failure via `processRxMoyaRequestEvent`)
- Add a new API entry to `Api.swift` and corresponding `TargetType` case + add mapping & caching rules
- Update network plugin (e.g., adjust `blackList`) and ensure unit behaviour by testing an example request

---
If any section is unclear or you want me to expand with concrete code examples/tests or add a checklist for PRs/commits, tell me which parts to expand. 🙋‍♂️