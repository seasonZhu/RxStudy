# RxStudy Swift 编码标准与模版

> 版本：1.0 · 适用范围：`RxStudy` (UIKit + RxSwift) 与 `SwiftUIApp` (SwiftUI + Combine) 双 Target
> 本标准由项目实际代码提炼而来，所有模版均可直接复用，**新增代码必须遵循**，存量代码在重构时逐步对齐。
> 生成日期：2026-07-03

---

## 目录

1. [总则](#1-总则)
2. [文件组织与命名](#2-文件组织与命名)
3. [代码格式](#3-代码格式)
4. [命名规范](#4-命名规范)
5. [类型设计](#5-类型设计)
6. [通用 Swift 模式](#6-通用-swift-模式)
7. [RxStudy (UIKit) 专项标准](#7-rxstudy-uikit-专项标准)
8. [SwiftUIApp (SwiftUI) 专项标准](#8-swiftuiapp-swiftui-专项标准)
9. [网络层标准](#9-网络层标准)
10. [Model 与 Codable 标准](#10-model-与-codable-标准)
11. [Extension 扩展标准](#11-extension-扩展标准)
12. [状态管理与单例](#12-状态管理与单例)
13. [日志与调试](#13-日志与调试)
14. [SwiftLint 规则](#14-swiftlint-规则)
15. [代码审查清单](#15-代码审查清单)

---

## 1. 总则

### 1.1 设计原则（优先级从高到低）

| 原则 | 在本项目中的体现 |
|------|------------------|
| **KISS** | ViewModel 只暴露 View 真正需要的输入/输出，不预留"以后可能用到"的方法 |
| **YAGNI** | 不提前封装抽象基类/协议，直到有 ≥2 处真实重复（参见 `ListViewModel<M,T>` 是在多页列表重复后才抽象的） |
| **DRY** | 公共逻辑下沉到 `BaseViewController` / `BaseViewModel` / `BaseModel`，列表分页统一走 `PageVMSetting` |
| **SRP（单一职责）** | Controller 只做"UI 搭建 + 绑定"，网络请求放在 ViewModel 的 `private extension`，路由定义放在独立 `Service` 文件 |
| **依赖倒置** | View 依赖 ViewModel（抽象），ViewModel 依赖 `Provider`/`APIService`（抽象），不反向持有 View |

### 1.2 技术基线

- **Swift**：5.9
- **最低部署目标**：iOS 17.6（可放心使用 `@Observable`、`NavigationStack`、`async/await`、存在类型 `any`）
- **架构**：MVVM（View ↔ ViewModel ↔ Service ↔ Network）
- **响应式**：RxStudy 用 RxSwift 6.x；SwiftUIApp 用 Combine + `@Observable`

### 1.3 双 Target 选型决策

| 场景 | 选择 |
|------|------|
| 新页面、新功能 | **优先 SwiftUIApp**（迁移方向） |
| 复杂列表交互、强依赖 UIKit 的控件（如 `JXSegmentedView`、`MJRefresh` 定制） | 暂留 RxStudy |
| 跨 Target 复用的 Model、纯数据结构 | 放 `Shared/` |

---

## 2. 文件组织与命名

### 2.1 文件头注释（强制）

**每个 `.swift` 文件必须以如下注释开头**（Xcode 自动生成格式，禁止手写错乱）：

```swift
//
//  FileName.swift
//  RxStudy                       // 或 RxStudy - SwiftUIApp
//
//  Created by season on 2021/5/20.   // 作者 / 日期
//  Copyright © 2021 season. All rights reserved.
//

import Foundation
```

> 说明：模块说明行（如 `// 首页 ViewModel`）可选，置于 import 之前或文件头之后均可，但一个文件内风格要统一。

### 2.2 文件命名

| 类型 | 规则 | 示例 |
|------|------|------|
| 普通类型 | `类型名.swift` | `HomeViewModel.swift` |
| 扩展 | `被扩展类型+功能.swift`（**统一用 `+`**，不混用中英文） | `UIColor+Extension.swift`、`UIViewController+Extension.swift` |
| SwiftUI View | `XxxView.swift` | `HomeView.swift`、`CoinRankListView.swift` |
| 路由/API | `XxxService.swift`（UIKit）/ `XxxAPI.swift` + `XxxAPIService.swift`（SwiftUI） | `HomeService.swift`、`HomeAPIService.swift` |

### 2.3 目录约定

```
Feature/
├── Controller/        # UIKit 控制器
├── ViewModel/         # ViewModel
├── View/              # UIKit 自定义 View / SwiftUI View
└── Model/             # 该 Feature 专属 Model（共享的放 Shared/Models）
```

> 单个 Feature 的文件按职责分目录；小型 Feature 可全部平铺在同一目录。

---

## 3. 代码格式

### 3.1 缩进与空格

- 缩进 **4 个空格**，不使用 Tab。
- 冒号紧贴左值：字典/协议上下文 `let dict: [String: Any]`、`class Foo: Bar`。
- 逗号后一个空格：`func load(a: Int, b: Int)`。
- 大括号不换行（K&R 风格）：

```swift
// ✅ 正确
if condition {
    doSomething()
} else {
    doOther()
}

// ❌ 错误
if condition
{
    doSomething()
}
```

### 3.2 `// MARK:` 分区（强制）

**类型内部必须用 `MARK` 划分逻辑区**，保持与现有代码一致：

```swift
class HomeViewModel {
    // MARK: - 状态
    private(set) var articles: [InfoModel] = []

    // MARK: - 私有属性
    private let apiService = HomeAPIService.shared

    // MARK: - 初始化
    init() {}

    // MARK: - 公共方法
    func refresh() async {}

    // MARK: - 私有方法
    private func loadData() async {}
}
```

跨协议实现用 `// MARK: - 协议名`：

```swift
// MARK: - 网络请求
private extension HomeViewModel {
    func requestData() {}
}

// MARK: - UITableViewDelegate
extension MyController: UITableViewDelegate {}
```

### 3.3 文档注释

- 公开类型、公开方法、公开属性**必须**有 `///` 文档注释，**使用简体中文**。
- 复杂逻辑用 `///` 说明"为什么"，而非"做了什么"。

```swift
/// 请求是否成功
var isSuccess: Bool { errorCode == 0 }

/// 网络请求重试逻辑
///
/// - Parameter errorObservable: 错误序列
/// - Returns: 重试触发序列，返回重试次数
///
/// # 重试规则
/// - 只对超时和网络错误进行重试
/// - 最大重试次数为 `maxRetryCount`（默认 3 次）
func retryLogic(errorObservable: Observable<Error>) -> Observable<Int> { ... }
```

---

## 4. 命名规范

### 4.1 类型与方法

| 元素 | 规则 | 示例 |
|------|------|------|
| 类型（class/struct/enum/protocol） | 大驼峰 | `HomeViewModel`、`ScrollViewActionType` |
| 方法、属性、变量 | 小驼峰 | `loadData()`、`dataSource` |
| 协议 | 名词描述能力用 `able`/`ible`，描述关系用 `Protocol` | `VMInputs`、`PageVMSetting`、`TypeNameProtocol` |
| 枚举值 | 小驼峰 | `.refresh`、`.loadMore` |
| 常量 | 小驼峰（**不用全大写**） | `let maxRetryCount = 3` |

### 4.2 缩写

- 仅在**业界通用**时保留缩写：`URL`、`HTTP`、`API`、`ID`、`JSON`、`VIPER`。
- 本项目约定：`Api`（非 `API`，沿用现有命名）、`Api.baseUrl`。

### 4.3 ViewModel 输入/输出前缀（UIKit 专项）

通过 `BaseViewModel` 的 `inputs` / `outputs` 前缀区分数据流向，**View 只调用 `viewModel.inputs.xxx()`、只订阅 `viewModel.outputs.xxx`**：

```swift
// View 侧
viewModel.inputs.loadData(actionType: .refresh)
viewModel.outputs.dataSource.bind(to: tableView.rx.items)
```

---

## 5. 类型设计

### 5.1 struct vs class

| 用 class | 用 struct |
|----------|-----------|
| 需要引用语义、被多处共享可变（如 `AccountManager`） | 纯数据模型（Codable Model） |
| UIKit 子类（`UIViewController`/`UIView`） | 几何尺寸、配置项 |
| RxSwift 的 ViewModel（继承 `BaseViewModel`） | — |

> SwiftUIApp 的 ViewModel 虽然是 class（`@Observable` 要求引用类型），但用 `final` + `private(set)` 模拟值语义的可控性。

### 5.2 final

- SwiftUIApp 的 ViewModel、Service 类一律加 `final`：`final class HomeAPIService`。
- 不被继承的 UIKit ViewModel 鼓励加 `final`。

### 5.3 访问控制

- 默认 `internal`；跨 Package 的类型/方法加 `public`（见 `Packages/`）。
- ViewModel 暴露给 View 的状态用 `private(set)`：外部只读、内部可写。

```swift
@Observable
final class HomeViewModel {
    private(set) var articles: [InfoModel] = []   // ✅ 外部只读
    private var currentPage = 0                    // ✅ 完全私有
}
```

### 5.4 协议设计

- 协议**只描述"能做什么"**，不携带存储属性。
- 带 `associatedtype` 的协议用作泛型约束，不直接当存在类型（除非用 `any`）。

---

## 6. 通用 Swift 模式

### 6.1 可选型

- 禁止无脑 `!` 强解包（网络数据、`Bundle` 路径等**不可靠来源**）。
- 优先 `guard let` 提前退出，避免深层嵌套：

```swift
guard let username = accountInfo?.username,
      let password = accountInfo?.password else {
    return
}
```

- 用 `compactMap` 过滤 nil：`.map { $0.data }.compactMap { $0 }`。
- 字符串插值可选型时注意 `String(describing:)` 的差异。

### 6.2 错误处理

- 业务错误用 `throw` + `do-catch`，不要用可选型伪装错误（参考 `APIError`）。
- 不要静默 `try?` 吞掉错误，除非明确"失败就用默认值"。

```swift
// ✅ SwiftUIApp 标准
do {
    let result = try await provider.requestDecoded(.banner, responseType: BaseModel<[Banner]>.self)
} catch {
    errorMessage = error.localizedDescription
}
```

### 6.3 并发

- SwiftUIApp 统一 `async/await`，禁止再用闭包回调嵌套。
- 跨并发域更新 UI 用 `await MainActor.run { }`。
- `async let` 并发请求提升首页等多接口场景的体验。

### 6.4 闭包与 `[weak self]`

- 闭包**默认加 `[weak self]`**，除非闭包生命周期 ≤ 持有者。
- 用 `guard let self else { return }` 解包后再用，避免 `self?` 散落。

```swift
viewModel.outputs.dataSource
    .subscribe(onNext: { [weak self] items in
        guard let self else { return }
        self.handle(items)
    })
    .disposed(by: rx.disposeBag)
```

---

## 7. RxStudy (UIKit) 专项标准

### 7.1 ViewModel 标准模版

```swift
//
//  XxxViewModel.swift
//  RxStudy
//
//  Created by season on 2026/7/3.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import NSObject_Rx

import Moya
import RxMoya

class XxxViewModel: BaseViewModel, VMInputs, VMOutputs, PageVMSetting {

    // MARK: - 分页
    var pageNum: Int

    init(pageNum: Int = 1) {
        self.pageNum = pageNum
        super.init()
    }

    // MARK: - Outputs
    /// 数据源
    let dataSource = BehaviorRelay<[XxxModel]>(value: [])

    /// 刷新状态
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)

    // MARK: - Inputs
    func loadData(actionType: ScrollViewActionType) {
        switch actionType {
        case .refresh:
            refresh()
        case .loadMore:
            loadMore()
        }
    }
}

// MARK: - 网络请求
private extension XxxViewModel {

    /// 下拉刷新
    func refresh() {
        resetCurrentPageAndMjFooter()
        requestData(page: pageNum)
    }

    /// 上拉加载
    func loadMore() {
        pageNum = pageNum + 1
        requestData(page: pageNum, loadMoreFailureResetCurrentPageCallback: loadMoreFailureResetCurrentPage)
    }

    /// 请求列表数据
    /// - Parameter page: 页码
    func requestData(page: Int, loadMoreFailureResetCurrentPageCallback: (() -> Void)? = nil) {
        xxxProvider.rx.request(XxxService.list(page))
            .map { try $0.map(BaseModel<Page<XxxModel>>.self) }
            .compactMap { $0.data }
            .asObservable()
            .asSingle()
            .subscribe { [weak self] event in
                guard let self else { return }

                // 无论成功失败都结束刷新状态
                self.pageNum == 1
                    ? self.refreshSubject.onNext(.stopRefresh)
                    : self.refreshSubject.onNext(.stopLoadmore)

                switch event {
                case .success(let pageModel):
                    if let datas = pageModel.datas {
                        // 第 1 页赋值，其余页合并
                        self.dataSource.accept(
                            self.pageNum == 1 ? datas : self.dataSource.value + datas
                        )
                    }
                    if pageModel.isNoMoreData {
                        self.refreshSubject.onNext(.showNomoreData)
                    }
                case .failure:
                    loadMoreFailureResetCurrentPageCallback?()
                    // 仅当数据为空时才展示错误页
                    if self.dataSource.value.isEmpty {
                        self.processRxMoyaRequestEvent(event: event)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - 分页状态重置
extension XxxViewModel {
    func resetCurrentPageAndMjFooter() {
        pageNum = 1
        refreshSubject.onNext(.resetNomoreData)
    }

    func loadMoreFailureResetCurrentPage() {
        pageNum = pageNum - 1
    }
}
```

**要点：**
- 数据源类型统一 `BehaviorRelay<[T]>(value: [])`。
- 网络请求放 `private extension`，对外只暴露 `inputs.loadData(actionType:)`。
- 所有订阅 `.disposed(by: disposeBag)`（来自 `NSObject_Rx` 的 `HasDisposeBag`）。
- 刷新状态统一驱动 `refreshSubject`，View 侧 `bind(to: tableView.rx.refreshAction)`。

### 7.2 Controller 标准模版

```swift
//
//  XxxController.swift
//  RxStudy
//
//  Created by season on 2026/7/3.
//  Copyright © 2026 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import MJRefresh

class XxxController: BaseTableViewController {

    private var viewModel: XxxViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

// MARK: - UI 搭建
private extension XxxController {
    func setupUI() {
        title = "标题"
    }
}

// MARK: - 绑定
private extension XxxController {
    func binding() {
        let viewModel = XxxViewModel()
        self.viewModel = viewModel

        // 下拉刷新
        tableView.mj_header?.rx.refresh
            .map { ScrollViewActionType.refresh }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        // 上拉加载
        tableView.mj_footer?.rx.refresh
            .map { ScrollViewActionType.loadMore }
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        // 数据源 → 列表
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: XxxCell.className)) { _, model, cell in
                (cell as? XxxCell)?.model = model
            }
            .disposed(by: rx.disposeBag)

        // 数据是否为空 → 空页面
        viewModel.outputs.dataSource
            .map { $0.isEmpty }
            .bind(to: isEmptyRelay)
            .disposed(by: rx.disposeBag)

        // 刷新状态 → tableView
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)

        // 点击 cell
        tableView.rx.modelSelected(XxxModel.self)
            .subscribe(onNext: { [weak self] model in
                guard let self else { return }
                self.pushToWebViewController(webLoadInfo: model.toWebLoadInfo())
            })
            .disposed(by: rx.disposeBag)
    }
}
```

**要点：**
- `viewDidLoad` 只调 `setupUI()` + `binding()`，**不写业务逻辑**。
- 所有订阅 `.disposed(by: rx.disposeBag)`（`_RX_` 的，区别于 ViewModel 的 `disposeBag`）。
- Cell 复用统一走 `BaseTableViewController.allClass` 注册 + `className` 作 identifier。
- 网络错误页通过 `viewModel.outputs.networkError.bind(to: rx.networkError)` 接入基类。

### 7.3 自定义 Cell 标准模版

```swift
//
//  XxxCell.swift
//  RxStudy
//
//  Created by season on 2026/7/3.
//  Copyright © 2026 season. All rights reserved.
//

import UIKit

import SnapKit

class XxxCell: UITableViewCell {

    /// 对外的数据模型
    var model: XxxModel? {
        didSet {
            guard let model else { return }
            titleLabel.text = model.title
        }
    }

    private lazy var titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI 搭建
private extension XxxCell {
    func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15))
        }
    }
}
```

**要点：**
- `init(coder:)` 用 `@available(*, unavailable)` 标记并 `fatalError`，统一约定。
- `model` 属性 + `didSet` 驱动 UI，不暴露 setter 方法。
- SnapKit 约束写在 `private extension` 的 `setupUI()` 中。

---

## 8. SwiftUIApp (SwiftUI) 专项标准

### 8.1 ViewModel 标准模版

```swift
//
//  XxxViewModel.swift
//  RxStudy - SwiftUIApp
//
//  Xxx 模块 ViewModel
//  使用 @Observable + async/await
//

import Foundation

@Observable
final class XxxViewModel {
    // MARK: - 状态（对外只读）
    /// 列表数据
    private(set) var items: [XxxModel] = []

    /// 是否正在加载
    private(set) var isLoading = false

    /// 是否正在加载更多
    private(set) var isLoadingMore = false

    /// 是否还有更多数据
    private(set) var hasMoreData = true

    /// 错误信息
    private(set) var errorMessage: String?

    // MARK: - 分页（完全私有）
    private var currentPage = 0
    private let pageSize = 20

    // MARK: - 依赖
    private let apiService = XxxAPIService.shared

    // MARK: - 初始化
    init() {}

    // MARK: - 公共方法
    /// 刷新数据
    func refresh() async {
        currentPage = 0
        hasMoreData = true
        await loadData(isRefresh: true)
    }

    /// 加载更多
    func loadMore() async {
        guard !isLoadingMore && hasMoreData else { return }
        await loadData(isRefresh: false)
    }

    /// 接近底部时触发加载（由 View 调用）
    func loadMoreIfNeeded(_ item: XxxModel) async {
        guard let index = items.firstIndex(where: { $0.id == item.id }),
              index >= items.count - 3,
              !isLoadingMore,
              hasMoreData else {
            return
        }
        await loadMore()
    }

    // MARK: - 私有方法
    private func loadData(isRefresh: Bool) async {
        if isRefresh {
            isLoading = true
        } else {
            isLoadingMore = true
            currentPage += 1
        }
        errorMessage = nil

        do {
            let result = try await apiService.fetchList(page: currentPage)
            await MainActor.run {
                if isRefresh {
                    items = result.datas ?? []
                } else {
                    items.append(contentsOf: result.datas ?? [])
                }
                hasMoreData = result.hasMore
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                if !isRefresh { currentPage -= 1 }   // 加载更多失败回退页码
            }
        }

        await MainActor.run {
            isLoading = false
            isLoadingMore = false
        }
    }
}
```

**要点：**
- 一律 `@Observable final class`（iOS 17+ 新范式，替代 `ObservableObject` + `@Published`）。
- 状态属性 `private(set)`；分页、依赖 `private`。
- `async/await` + `MainActor.run` 更新 UI 状态。
- 加载更多失败必须**回退页码**。

### 8.2 View 标准模版

```swift
//
//  XxxView.swift
//  RxStudy - SwiftUIApp
//
//  Xxx 视图
//

import SwiftUI

struct XxxView: View {
    @State private var viewModel = XxxViewModel()

    var body: some View {
        contentView
            .navigationTitle("标题")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if viewModel.items.isEmpty {
                    await viewModel.refresh()
                }
            }
    }

    // MARK: - 内容视图
    @ViewBuilder
    private var contentView: some View {
        if !viewModel.items.isEmpty {
            listView
        } else if viewModel.isLoading {
            loadingView
        } else if viewModel.errorMessage != nil {
            errorView
        } else {
            EmptyView()
        }
    }

    // MARK: - 列表
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.items) { item in
                    NavigationLink(destination: WebUIController(article: item)) {
                        XxxCellView(item: item)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded(item) }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - 辅助视图
    private var loadingView: some View {
        ProgressView("加载中...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(viewModel.errorMessage ?? "加载失败")
                .foregroundColor(.red)
            Button("重新加载") {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - 预览
#Preview {
    NavigationStack {
        XxxView()
    }
}
```

**要点：**
- `@State private var viewModel`（配合 `@Observable`，无需 `@StateObject`）。
- `body` 保持精简，复杂 UI 拆成 `@ViewBuilder` 计算属性（`listView` / `loadingView` / `errorView`）。
- 首次加载用 `.task`，下拉刷新用 `.refreshable`，触底加载用 `.onAppear` + `loadMoreIfNeeded`。
- **每个 View 必须有 `#Preview`**。

### 8.3 子 Cell View 标准模版

```swift
//
//  XxxCellView.swift
//  RxStudy - SwiftUIApp
//

import SwiftUI

struct XxxCellView: View {
    let item: XxxModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            Text(item.desc)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(Color.systemBackground)
    }
}

#Preview {
    XxxCellView(item: .preview)
}
```

---

## 9. 网络层标准

### 9.1 RxStudy（RxSwift）Service 模版

```swift
//
//  XxxService.swift
//  RxStudy
//

import Foundation
import Moya

enum XxxService {
    case list(page: Int)
    case detail(id: Int)
}

extension XxxService: TargetType {
    var baseURL: URL { URL(string: Api.baseUrl)! }

    var path: String {
        switch self {
        case .list(let page):
            return Api.Xxx.list + page.toString + "/json"
        case .detail(let id):
            return Api.Xxx.detail + id.toString + "/json"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list:   return .get
        case .detail: return .get
        }
    }

    var task: Task {
        switch self {
        case .list:   return .requestPlain
        case .detail: return .requestPlain
        }
    }

    var headers: [String: String]? { nil }
}
```

> Provider 集中管理在 `RxStudy/HttpRequest/Service/Provider.swift`，新增 Service 在此追加：
> `let xxxProvider = MoyaProvider<XxxService>(plugins: plugins)`

### 9.2 SwiftUIApp（async/await）APIService 模版

**第一部分：API 定义（路由）**

```swift
//
//  XxxAPI.swift（或并入 XxxAPIService.swift 顶部）
//  RxStudy - SwiftUIApp
//

import Foundation
import Moya

enum XxxAPI {
    case list(page: Int)
    case detail(id: Int)
}

extension XxxAPI: TargetType {
    var baseURL: URL { URL(string: "https://wanandroid.com")! }

    var path: String {
        switch self {
        case .list(let page):   return "/xxx/list/\(page)/json"
        case .detail(let id):   return "/xxx/detail/\(id)/json"
        }
    }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case .list, .detail: return .requestPlain
        }
    }

    var headers: [String: String]? {
        let cookie = AccountAPIService.shared.cookieHeaderValue
        return cookie.isEmpty ? nil : ["cookie": cookie]
    }
}
```

**第二部分：Service 实现（单例）**

```swift
// MARK: - Xxx API 服务

@Observable
final class XxxAPIService {
    static let shared = XxxAPIService()

    private let provider = MoyaProvider<XxxAPI>()
    private init() {}

    // MARK: - 请求方法

    /// 获取列表
    func fetchList(page: Int) async throws -> Page<XxxModel> {
        try await provider.requestDecoded(
            .list(page: page),
            responseType: BaseModel<Page<XxxModel>>.self
        )
    }

    /// 获取详情
    func fetchDetail(id: Int) async throws -> XxxModel {
        try await provider.requestDecoded(
            .detail(id: id),
            responseType: BaseModel<XxxModel>.self
        )
    }
}
```

**要点：**
- 统一通过 `MoyaProvider.requestDecoded(_:responseType:)`（在 `APIService.swift` 扩展）调用，**一行完成"请求 + 解码 + 取 data + 抛业务错误"**。
- 错误统一走 `APIError`，View 层 `catch` 后赋给 `errorMessage`。
- 路由 URL 字符串：UIKit 用 `Api` 枚举集中管理；SwiftUI 直接写在 `path`（迁移期可容忍，统一时再抽）。

---

## 10. Model 与 Codable 标准

### 10.1 BaseModel 统一响应壳

```swift
/// 基础响应模型
public struct BaseModel<T: Codable>: Codable {
    public let data: T?
    public let errorCode: Int?
    public let errorMsg: String?

    public var isSuccess: Bool { errorCode == 0 }
}
```

- RxStudy：额外在 `APIService.swift` 提供 `getData() throws -> T`（失败抛 `APIError.businessError`）。
- **不要在 View/Controller 里手写 `errorCode == 0` 判断**，统一走 `isSuccess` / `getData()`。

### 10.2 Model 定义规范

```swift
/// 文章模型
struct InfoModel: Identifiable, Codable {
    let id: Int
    let title: String
    let author: String?
    let link: String?
    let publishTime: TimeInterval?

    /// 兼容旧字段名的解码（示例：服务端字段名不一致）
    enum CodingKeys: String, CodingKeys {
        case id, title, author, link, publishTime
    }
}
```

- 能用 `struct` 就不用 `class`，统一 `Codable`。
- 列表项 Model **必须实现 `Identifiable`**（SwiftUI `ForEach` 需要）。
- 可空字段用可选型，**不要用空字符串/0 哨兵值**。
- 服务端字段类型不稳定（如 `id` 时而是 Int 时而是 String）时，用 `StringInt`（见 `Codable+Extension.swift`）等兼容类型。

### 10.3 默认值处理

对于"key 缺失或类型不符就给默认值"的字段，用 `@Default` 属性包装器（已封装）：

```swift
struct Foo: Codable {
    @Default<String> var name: String      // 缺失时为 ""
    @Default<Bool>   var isLike: Bool      // 缺失时为 false
}
```

---

## 11. Extension 扩展标准

### 11.1 文件与组织

- 文件名：`Type+功能.swift`（如 `UIColor+Extension.swift`）。
- 一个类型的相关扩展可集中在同一文件，用 `// MARK:` 分区。
- 扩展方法必须有 `///` 文档注释。

### 11.2 颜色扩展（支持深色模式）

```swift
public extension UIColor {
    /// 文字颜色 light 为黑、dark 为白
    static let playAndroidTitle = UIColor(lightThemeColor: .black, darkThemeColor: .white)

    /// 背景颜色 light 为白、dark 为黑
    static let playAndroidBackground = UIColor(lightThemeColor: .white, darkThemeColor: .black)
}
```

> 所有自定义颜色**必须通过 `UIColor(lightThemeColor:darkThemeColor:)` 构造**，确保深色模式生效。

### 11.3 类型名作复用标识

```swift
// 利用 TypeNameProtocol，所有类型可用 .className
tableView.register(XxxCell.self, forCellReuseIdentifier: XxxCell.className)
let cell = tableView.dequeueReusableCell(withIdentifier: XxxCell.className) as! XxxCell
```

### 11.4 Rx 扩展（Reactive）

为自定义控件写 Rx 扩展时，统一 `extension Reactive where Base: XxxType`：

```swift
extension Reactive where Base: UITableView {
    /// 绑定编辑状态
    var isShowEdit: Binder<Bool> {
        Binder(base) { base, isEdit in
            base.setEditing(isEdit, animated: true)
        }
    }
}
```

### 11.5 禁止事项

- ❌ 不要给 `Foundation` 原始类型（`Int`/`String`）加无关业务方法。
- ❌ 不要用扩展"重写"父类方法（用子类化替代）。

---

## 12. 状态管理与单例

### 12.1 单例模版

```swift
public final class AccountManager {
    public static let shared = AccountManager()
    private init() {}

    // 通过 BehaviorRelay 暴露可观察状态
    public let isLoginRelay = BehaviorRelay(value: false)

    // 通过 @UserDefault 持久化
    @UserDefault(key: "kUsername", defaultValue: nil)
    public var username: String?

    // 只读对外属性
    public private(set) var accountInfo: AccountInfo?
}
```

**要点：**
- `final` + `static let shared` + `private init()`。
- 全局状态用 `BehaviorRelay` 暴露，让 Rx 订阅者响应变化。
- 持久化用 `@UserDefault` 属性包装器，而非散落的 `UserDefaults.set`。

### 12.2 状态暴露对照

| 需求 | UIKit（RxSwift） | SwiftUI（Combine） |
|------|------------------|---------------------|
| 全局可变状态 | `BehaviorRelay` | `@Observable` 单例 |
| View 私有状态 | `BehaviorRelay`/`PublishSubject` | `@State` |
| ViewModel → View | `outputs.xxx.bind(...)` | `private(set) var xxx` |
| 表单双向绑定 | `bind(to: textField.rx.text)` | `@Bindable` + `TextField` |

---

## 13. 日志与调试

### 13.1 日志 API 选择

| 场景 | 使用 |
|------|------|
| 调试打印（Release 自动屏蔽） | `debugLog("xxx")` |
| 分级日志（debug/info/warn/error） | `LogUtils.debug(...)` / `.error(...)` |
| 网络请求日志 | `NetworkRequestLoggerPlugin`（已配置） |

- **禁止在生产代码用 `print()`**，统一替换为 `debugLog()` 或 `LogUtils`。
- 日志内容用中文描述 + 插值变量，方便在 Console.app 用 `logger` 检索。

```swift
// ✅ 正确
debugLog("第 \(attempt + 1) 次重试...")
LogUtils.error("登录失败: \(error.localizedDescription)")

// ❌ 错误
print("err", error)
```

### 13.2 销毁日志

ViewModel 继承 `BaseViewModel`，`deinit` 自动打印销毁日志，便于排查循环引用。**自定义 deinit 不要遗漏 `super` 调用链中的日志**。

---

## 14. SwiftLint 规则

项目使用 `.swiftlint.yml`，关键规则：

| 规则 | 阈值 |
|------|------|
| `cyclomatic_complexity` | 20 |
| `type_body_length` | warning 800 / error 1200 |
| `force_cast` / `force_try` | warning（允许但需谨慎） |
| `line_length` / `file_length` | **禁用**（不强求换行） |

新增代码应做到：
- 单个方法圈复杂度 > 15 时考虑拆分。
- `as!` 强转仅用于已注册 Cell（确保安全），其余场景用 `as?` + `guard`。
- 用 `// swiftlint:disable:next 规则名` 显式标注豁免，并写明原因。

---

## 15. 代码审查清单

提交 PR / 自查时逐条核对：

**通用**
- [ ] 文件头注释完整、作者/日期正确
- [ ] 公开 API 有 `///` 中文文档注释
- [ ] `// MARK:` 分区清晰
- [ ] 无 `print()`，统一 `debugLog` / `LogUtils`
- [ ] 闭包有 `[weak self]`，无循环引用风险
- [ ] 强解包 `!` 仅用于确定安全的场景

**UIKit（RxStudy）**
- [ ] ViewModel 继承 `BaseViewModel`，遵守 `VMInputs` / `VMOutputs`
- [ ] Controller 的 `viewDidLoad` 只调 `setupUI()` + `binding()`
- [ ] 订阅全部 `.disposed(by: rx.disposeBag)` 或 `disposeBag`
- [ ] 下拉/上拉状态绑定到 `refreshSubject`
- [ ] 颜色用 `UIColor(lightThemeColor:darkThemeColor:)`

**SwiftUI（SwiftUIApp）**
- [ ] ViewModel 用 `@Observable final class`
- [ ] 状态属性 `private(set)`
- [ ] View 有 `#Preview`
- [ ] 网络调用用 `requestDecoded`，错误进 `errorMessage`
- [ ] `body` 精简，复杂 UI 拆 `@ViewBuilder` 子视图

**网络与数据**
- [ ] Service 实现完整 `TargetType`
- [ ] 响应解析走 `BaseModel` + `isSuccess`/`getData()`
- [ ] 新路由在 `Provider.swift` / 单例 Service 中注册
- [ ] 列表 Model 实现 `Identifiable`

---

## 附录：双 Target 模式速查表

| 维度 | RxStudy (UIKit) | SwiftUIApp (SwiftUI) |
|------|-----------------|----------------------|
| 响应式框架 | RxSwift 6.x | Combine + `@Observable` |
| ViewModel 基类 | `BaseViewModel` | 无基类，`@Observable final class` |
| 数据流 | `BehaviorRelay` / `Observable` | `private(set) var` |
| 输入输出 | `inputs`/`outputs` 前缀 | 方法 + 只读属性 |
| 网络回调 | `Single` / `Observable` | `async/await` |
| 列表 | `UITableView` + MJRefresh | `ScrollView` + `LazyVStack` + `.refreshable` |
| 刷新 | `refreshSubject` → `rx.refreshAction` | `viewModel.refresh()` |
| 导航 | `UINavigationController` push | `NavigationStack` / `NavigationLink` |
| 订阅生命周期 | `disposeBag` / `rx.disposeBag` | Task 自动随 View 销毁 |
| 错误页 | `networkError` + `errorImage` | `errorMessage` + `errorView` |

---

> **维护说明**：本标准随项目演进持续更新。新增通用模式时，请同步补充对应章节与模版，并在变更记录中登记。
