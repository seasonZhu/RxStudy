# Flutter 模块一键接入与卸载

适用于含 `Podfile` 与 `RxStudy.xcodeproj` 的 CocoaPods 工程。只接入 `RxStudy` Target，不切换分支；Tuist 工程不在支持范围内。

## 使用

在仓库根目录执行，也可从任意目录通过脚本绝对路径调用：

```bash
# 中文菜单
bash scripts/switch-flutter.sh

# 接入：准备 iOS 引擎缓存、解析 Flutter 依赖、生成配置、安装 Pods
bash scripts/switch-flutter.sh enable

# 卸载：解除 iOS 集成，保留 Flutter 源码与缓存
bash scripts/switch-flutter.sh disable

# 只读检查开关、SDK 版本、锁文件与构建阶段
bash scripts/switch-flutter.sh status
```

完成后打开 `RxStudy.xcworkspace`。切换前关闭正在构建的 Xcode 工程；脚本不会主动启动 Xcode 或模拟器，也不会构建 App。卸载会通过 `xcodebuild clean` 清理该 Scheme 的 Xcode 构建产物，防止旧 `Flutter.framework` 让 `canImport(Flutter)` 继续成立或残留在 App 中，下一次原生构建需要重新编译。

开关通过仓库根目录的 `.flutter-enabled` 文件保存，已加入 Git 忽略列表，默认关闭。日常直接执行 `pod install` 也会遵守当前开关。请使用脚本切换，避免只改开关却遗漏重新安装依赖。

**本机开关不入库不代表切换不会产生 Git 差异。** 本仓库跟踪 Pods、工程和锁文件，`pod install` 会修改这些文件。脚本保留用户已有源码修改，不执行 Git 清理、重置或自动提交。若准备提交纯原生状态，先运行 `disable`，再检查差异；不要直接覆盖或还原已有业务修改。

## 工具与兼容基准

- 接入需要 PATH 中可用的 `flutter`、`pod`、`ruby`、`git`、`xcodebuild`，以及完整 Xcode。CocoaPods 插件沿用当前 Podfile 的要求。
- 卸载需要 `pod`、`ruby`、`git`、`xcodebuild` 和完整 Xcode，不要求 Flutter SDK；`status` 不启动 Flutter，仅在 Ruby 可用时读取 SDK 版本缓存。
- 本次兼容基准为 Flutter 3.47.0、Dart 3.13.0。模块 Dart 约束为 `>=3.8.0 <4.0.0`，实际依赖版本记录于 `flutter_module/pubspec.lock`。其它 SDK 版本需要另行验证。
- 日常脚本执行 `flutter precache --ios`、`flutter pub get` 和 `pod install`，不执行 `pub upgrade`、`pod update`，也不修改系统 Flutter 配置。首次运行需要网络访问，SDK 可能补充自身缓存；更换 SDK 后可能产生其固定传递依赖的锁文件变化。
- Flutter 的 `.ios` 是生成目录，不手工维护。官方 helper 负责生成 Flutter 编译、嵌入及插件注册配置，并通过 Pods 配置关闭所需的脚本沙箱，无需手工添加 Xcode 构建阶段。

原生页面和通信沿用现有 `canImport(Flutter)` / `canImport(FlutterPluginRegistrant)` 条件编译。卸载不删除页面源码、Dart 文件、Flutter SDK 缓存或 `.ios`、`.dart_tool` 等模块配置缓存，也不会卸载电脑上的 Flutter SDK。Xcode 构建产物会清理。

默认按 Xcode 的 workspace 设置清理构建目录。如果日常命令行构建指定了自定义 DerivedData 路径，卸载时传入相同路径：

```bash
RXSTUDY_DERIVED_DATA_PATH="/你的路径/DerivedData" bash scripts/switch-flutter.sh disable
```

其它独立构建目录需各自执行 Clean；`status` 检查的是集成配置，不扫描所有历史产物。

## 失败恢复

脚本与 `switch-dependencies.sh` 共用 Git 公共目录下的 `dependency-switch.lock`，防止同时切换依赖；正在进行合并、变基等 Git 操作时会停止。

每次安装都会输出临时日志路径。失败或被中断后恢复原来的开关状态，但 **Pods、工程、Flutter 生成配置或 Xcode 构建产物可能已经部分改变，并非完整回滚**。按失败步骤解决环境或网络问题，然后重新运行同一命令；如希望返回纯原生状态，运行 `disable`。日志不会自动删除。

`status` 在锁文件缺失、两份锁文件不同，或 Flutter 依赖、构建阶段与开关不匹配时返回非零退出码，并输出修复命令。若进程被强制结束导致遗留互斥锁，只能在确认没有其他切换任务运行后手动移除报出的锁目录。

## 验证

```bash
bash -n scripts/switch-flutter.sh
ruby -c Podfile
python3 scripts/tests/test_switch_flutter.py
cd flutter_module
flutter analyze --no-pub
flutter test --no-pub
```

脚本测试在临时仓库模拟工具，覆盖带空格路径、重复启停、缺少工具、安装失败恢复、状态不一致和互斥锁，不需要真实安装 Pods。

主工程已有 SwiftLint 自动修复构建阶段。验证启用、关闭后的 Debug / Release 编译时，建议复制到临时目录执行无签名构建，防止格式修复改动工作区。静态分析中的既有风格警告与真实编译错误需分开判断。

接入机制参考 [Flutter 官方 CocoaPods 模块接入说明](https://docs.flutter.dev/add-to-app/ios/project-setup-legacy)。

### 本次验证结果（2026-10-19）

环境：Flutter 3.47.0、Dart 3.13.0、Xcode 26.3，使用真机通用目标、关闭代码签名，在临时副本构建，未启动模拟器。

| 检查 | 结果 |
| --- | --- |
| 脚本行为测试 | 12 项通过，含失败恢复、无 Flutter 卸载、清理失败及自定义 DerivedData |
| Flutter 页面测试 | 2 项通过 |
| Flutter 静态分析 | 无 error，既有代码仍报告 88 项 warning/info，命令因此返回非零 |
| 启用 Flutter 编译 | Debug、Release 均通过，包含 Flutter 构建与嵌入 |
| 关闭 Flutter 编译 | 自动清理后，Debug、Release 均通过 |
| 关闭后的产物 | 两种配置的二进制均无 Flutter 链接，App 内均无 Flutter.framework、App.framework、FlutterPluginRegistrant.framework |

四次 `xcodebuild` 均成功退出。构建仍有原有依赖告警，SwiftLint 扫描临时副本的 Tuist 缓存时也报告了格式违规；本次未扩展修改这些代码。
