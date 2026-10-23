# NoCompile 热重载调试指南

本文面向 CocoaPods 构建方式下的 `RxStudy` UIKit target，记录开发时热重载的操作与排错经验，不涉及正式 App 的在线更新或 `SwiftUIStudy` 接入。

记录日期：2026-10-23。本次排查的客户端版本为 NoCompile 0.2.9，本机 Xcode 为 26.3。以下缺陷结论仅针对已检查的 0.2.9，不代表后续版本仍有相同问题。

## 1. 接入与首次运行

当前 [Podfile](../Podfile) 在 `RxStudy` target 中声明：

```ruby
pod 'NoCompile', :configurations => ['Debug']
```

本次 `Podfile.lock` 锁定到 0.2.9。已有安装使用 `pod install`，避免为接入调试工具执行全量 `pod update`。项目使用 `use_frameworks!`，最低系统版本为 iOS 17.6。

依据 [0.2.9 官方接入指南](https://github.com/wangwanjie/NoCompile/blob/v0.2.9/Docs/Integration.md)，CocoaPods 方式会自动添加 `-Xlinker -interposable`，客户端加载后自动启动。基础接入无需 `import NoCompile` 或额外启动调用，也不要重复接入 bundle。确认 Debug 最终链接参数包含该选项，Release 不链接、嵌入 NoCompile，也不包含该选项；Debug 不应启用 Whole Module Optimization。

首次运行步骤：

1. 安装 NoCompile.app，使用不含空格的真实工程路径，原因见第 3 节。
2. 在项目根目录执行 `pod install`，用 Xcode 打开该目录的 `RxStudy.xcworkspace`。
3. 选择 `RxStudy` scheme，确认 Run 使用 Debug，连接 USB 真机。
4. 在 Xcode 按 `⌘R`，成功完成一次完整构建并运行。NoCompile 需要构建日志中的编译命令和签名信息。
5. 启动 NoCompile.app，选择同一目录的 workspace，确认显示当前 App 和设备已连接、引擎就绪。

工程位于“文稿”等受保护目录时，需要允许 NoCompile 访问该目录。若使用自定义 DerivedData，应让 NoCompile 指向 Xcode 实际使用的位置；CLI 可通过 `--derived-data` 指定。

## 2. 日常修改与页面刷新

保持 NoCompile 开启、App 在前台运行，修改已有页面的一处文字、颜色或布局参数，按 `⌘S` 保存。查看编译和注入结果，成功后退出该页面，再重新进入以创建新实例。普通方法实现或界面参数调整无需每次按 `⌘R`。

### 默认刷新与自动重建

默认不重建已加载页面。已注入但当前画面未变化时，先确认改动是否位于 `viewDidLoad`、`loadView` 或初始化逻辑中，以及重进页面是否确实创建了新实例。

根页面无法退出时，可按官方指南在 NoCompile 偏好设置中开启“自动重建已加载的页面”，或在 Debug 代码中配置 `NoCompile.autoReloadViewControllers = true`。此模式会重新执行视图加载与相关生命周期方法，可能重复创建 Rx 订阅、注册通知、发起网络请求，或丢失页面状态。本项目优先采用默认方式；需要自动重建时，应先确认页面支持重复执行这些逻辑。

本次检查时，[AppDelegate.swift](../RxStudy/AppDelegate.swift) 的新增导入与自动刷新设置使用了 `#if DEBUF`。标准调试条件是 `#if DEBUG`；若工程未自定义 `DEBUF`，其中的代码不会执行。客户端依然可由 Pod 自动启动，因此“已连接”不能证明自动刷新设置已生效。本次仅记录该问题，不修改现有代码。

### 需要重新构建运行的情况

- 增删、调整存储属性或实例变量，或其他导致类型内存布局、Swift 方法派发表变化的修改；出现“内存布局变了”提示时重新运行。
- 修改依赖、构建配置或桥接头，或新增 ObjC 类需要被 Swift 使用。
- 跨文件私有符号等改动无法注入，或切换分支、大批量变更导致工具跳过热重载。
- Mac 端与客户端协议修订不兼容。按工具提示更新客户端并重新构建；版本号不同本身不一定表示协议不兼容。

热重载用于缩短迭代时间。完成修改后，仍需正常构建并验证从启动开始的真实行为，不能仅用旧进程中的注入结果代替验收。

## 3. 实例：含空格路径导致 Swift 命令展开失败

### 现象与环境

原工程位于 `/Users/dy/Documents/Swift Git/RxStudy`。NoCompile 显示真机已连接，客户端 0.2.9，构建日志解析完成且引擎就绪，但保存多个 Swift 文件均报错：

```text
无法展开 Swift 编译命令：error: unexpected input file: /Users/dy/Documents/Swift
```

路径恰好截断在 `Swift Git` 的空格前。该阶段尚未进入代码注入，不能按设备连接失败或业务代码编译错误处理。

### 排查证据与原因

本机读取了 `Failures/2026-10-23_10-15-56.147_展开命令_HotKeyFlexBoxController.swift.txt`，并使用其中的命令重放 `swiftc -###`，复现了同一错误。此参数用于展开编译任务，本次重放没有执行完整 App 构建或真机注入。

记录显示，目标文件是 `HotKeyFlexBoxController.swift`，选用的命令却是 `-module-name Kingfisher`。结合 0.2.9 的 [BuildLog.swift](https://github.com/wangwanjie/NoCompile/blob/v0.2.9/Sources/NoCompileKit/BuildLog.swift) 和 [Recompiler.swift](https://github.com/wangwanjie/NoCompile/blob/v0.2.9/Sources/NoCompileKit/Recompiler.swift)，问题链路如下：

1. Xcode 的 Swift 文件列表将含空格路径写成 `Swift\ Git`；NoCompile 读取源文件集合时未还原路径转义，影响文件归属判断，本次错误选择了 Kingfisher 模块。
2. 借用模块命令时，NoCompile 把业务文件路径追加到临时 `.SwiftFileList`，新增路径未转义空格。
3. Swift 编译器读取响应文件，将追加路径拆开，报 `unexpected input file`。

临时列表中的关键差异（省略无关目录）：

```text
/Users/dy/Documents/Swift\ Git/RxStudy/Pods/Kingfisher/…/UIButton+Kingfisher.swift
/Users/dy/Documents/Swift Git/RxStudy/RxStudy/Home/Controller/HotKeyFlexBoxController.swift
```

**本机验证**：原始列表重放退出码为 1；仅在临时测试副本中还原路径并改为双引号包裹后，命令展开退出码为 0。这证明了该展开错误与路径转义有关，不代表错误模块选择已修复，也不代表完整热重载通过。

**用户验证**：随后用户将项目放到其他不含空格的目录验证，反馈运行正常、问题消失。这是绕过方案可用的反馈，与上述命令级验证分别记录。

### 处理方案

1. 停止调试并退出 NoCompile，保留原目录及所有未提交修改。
2. 将完整项目复制到不含空格的真实路径，例如 `~/Developer/RxStudy`；父目录也不要包含空格。不建议仅创建软链接，工具可能还原真实路径。
3. 在新目录执行 `pod install`，打开新目录的 workspace。
4. 在 Xcode 执行 Product → Clean Build Folder，再使用 Debug 完整编译并运行真机。
5. NoCompile 重新选择新 workspace，确认构建日志和设备连接属于该项目，再修改一处现有文字验证。

不要把修改 NoCompile 临时文件列表作为长期修复：后续注入会重新生成文件，而且错误选择模块的问题仍然存在。保留含空格目录需要修复并重新构建 Mac 端工具；仅修改 Pod 客户端不能解决此处的命令生成问题。升级后应重新验证该用例，不预设新版本是否已修复。

## 4. 按失败阶段排查

| 阶段 | 观察点 | 优先处理 |
| --- | --- | --- |
| 连接 | Mac 端未显示当前 App；Xcode 没有客户端启动日志 | 检查 Debug、Pod 是否加载、USB、App 是否前台运行以及选中的 workspace；真机客户端通常记录监听 `127.0.0.1:21891` |
| 构建日志 | 未找到日志、命令或 SDK；工程不匹配 | 使用当前 Xcode 完整构建，核对项目真实路径、平台及 DerivedData；迁移目录后不要继续选择旧 workspace |
| 命令展开 | `无法展开 Swift 编译命令` | 查看失败文件中的命令、模块、工作目录和响应文件；路径被空格截断时参考第 3 节 |
| 编译 | Swift/ObjC 源码诊断 | 先看第一条真实错误，确认使用正确模块和文件；结构性修改改用完整构建 |
| 签名 | 真机 dylib 签名失败 | 先在 Xcode 成功构建并运行同一 App、同一设备，使日志包含与 App 一致的开发者签名信息 |
| 注入 | 版本不兼容、未解析符号、未替换实现 | 按具体提示检查客户端修订兼容性、符号导出及 Debug 最终链接参数，不盲目清理全局缓存 |
| 页面刷新 | 注入成功但画面未变化 | 退出后新建页面实例；确认修改的生命周期位置，谨慎使用自动重建 |

保存后没有监听事件时，可点击 NoCompile 的“检查改动”；连接多台设备时，确认目标设备被标为“当前”。需要临时排除工具影响时，可设置运行环境变量 `NOCOMPILE_DISABLE=1` 后重新运行。

## 5. 日志、诊断包与验收

本次本机日志位于 `~/Library/Logs/NoCompile/`，包含 `Diagnostics.log` 与 `Failures/`。该位置是本次实际观察值，其他版本以工具导出的诊断包为准。失败记录包含工作目录、完整命令和输出；重放前检查命令用途与内容，不直接执行来源不明的脚本。

按官方指南，在控制台日志栏点击 📦 或选择菜单“导出诊断包…”。诊断包通常包含：

- `Diagnostics.log`：监听、命令解析、编译、签名与连接等环节。
- `Failures/`：各次失败的命令和输出。
- `Summary.txt`：系统、Xcode、工程、DerivedData、客户端握手及注入信息。
- `Hangs/`：工具采集到的卡顿信息（若有）。

分享前检查并脱敏用户名、绝对路径、设备标识、签名身份及可能出现的业务信息或凭据。无需把完整诊断包或本机临时响应文件提交到项目。

验收时分别记录：Debug 编译是否通过、Release 是否隔离调试依赖、真机是否连接、注入是否成功、页面新建后是否显示改动。仅连接成功或命令展开成功不能代表完整功能通过。

本文整理时核对了仓库配置与 0.2.9 官方文档，未重新构建项目、启动模拟器或执行新一轮真机注入；无空格目录下的功能结果来自本次用户反馈。
