# RxStudy 下一步优化计划

## 📅 总体规划

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    当前状态：UIKit + Tuist + SPM ✅                         │
│                    版本标签：v1.0.0-uikit-tuist                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                           下一步：Phase 3                                   │
│                         SwiftUI + Combine 迁移                              │
│                            （预计 8-12 周）                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Phase 3: SwiftUI + Combine 迁移

### 迁移原则

1. **增量迁移** - 保持App始终可用，每次迁移一个模块
2. **UI优先** - 先迁移UI层，后迁移ViewModel层
3. **保持功能** - 迁移过程中功能不能回退
4. **性能优先** - SwiftUI版本性能不低于UIKit版本

### 技术栈对比

| UIKit + RxSwift | SwiftUI + Combine |
|-----------------|-------------------|
| Observable | Publisher |
| BehaviorRelay | @State, @Published |
| Driver | @StateObject |
| rx.items | ForEach |
| rx.tap | .onTapGesture |
| rx.text | @Binding |
| DisposeBag | @StateObject |
| Scheduler | DispatchQueue |

---

## 📋 详细迁移计划

### Week 1-2: 基础组件迁移

| 优先级 | 组件 | 预计时间 | 依赖 |
|-------|------|----------|------|
| 1 | ActivityIndicator组件 | 1天 | 无 |
| 2 | HUD加载组件 | 2天 | ActivityIndicator |
| 3 | 空状态视图 | 1天 | 无 |
| 4 | 通用工具扩展 | 3天 | 无 |

**验收标准：**
- [ ] 所有基础组件可独立使用
- [ ] 支持Dark Mode
- [ ] 性能测试通过

---

### Week 3-4: 账号模块迁移

| 页面/功能 | 预计时间 | 复杂度 | 备注 |
|----------|----------|--------|------|
| LoginPage | 2天 | 低 | 简单表单 |
| RegisterPage | 3天 | 中 | 表单验证 |
| 密码找回 | 2天 | 中 | 表单 + 导航 |
| AccountManager | 3天 | 中 | 状态管理 |
| 登录状态监听 | 2天 | 中 | Combine重写 |

**验收标准：**
- [ ] 登录/注册流程正常
- [ ] 状态保持正确
- [ ] Token自动刷新

---

### Week 5-6: 独立功能模块

| 页面 | 预计时间 | 复杂度 | 备注 |
|------|----------|--------|------|
| CoinRankListPage | 2天 | 低 | 简单列表 |
| 搜索页面 | 3天 | 中 | 搜索历史 + 热词 |
| 收藏页面 | 3天 | 中 | 列表 + 状态管理 |
| 历史记录 | 2天 | 中 | 列表 + 删除 |
| 积分记录 | 2天 | 低 | 简单列表 |
| 我的页面 | 3天 | 中 | 多section列表 |

**验收标准：**
- [ ] 所有列表滚动流畅
- [ ] 搜索功能正常
- [ ] 收藏同步正常

---

### Week 7-8: WebView和展示页面

| 页面 | 预计时间 | 复杂度 | 备注 |
|------|----------|--------|------|
| WebView容器 | 3天 | 中 | UIViewRepresentable |
| 文章详情页 | 3天 | 中 | WebView + 收藏/评论 |
| 关于页面 | 1天 | 低 | 静态内容 |
| 设置页面 | 2天 | 低 | 列表 + 开关 |
| 分享功能 | 2天 | 中 | 系统分享 |

**验收标准：**
- [ ] WebView加载正常
- [ ] 文章详情交互正常
- [ ] 分享功能正常

---

### Week 9-10: 列表和复杂页面

| 页面 | 预计时间 | 复杂度 | 备注 |
|------|----------|--------|------|
| BaseListViewModel迁移 | 4天 | 高 | 核心基类 |
| Home模块列表 | 5天 | 高 | 轮播 + 列表 + 刷新 |
| 体系模块 | 3天 | 高 | 树形结构 |
| 导航模块 | 3天 | 高 | 树形结构 |
| 项目模块 | 3天 | 高 | 列表 + Tab |

**验收标准：**
- [ ] 下拉刷新/上拉加载正常
- [ ] 列表滚动流畅
- [ ] 状态管理正确

---

### Week 11-12: 核心导航和TabBar

| 组件 | 预计时间 | 复杂度 | 备注 |
|------|----------|--------|------|
| JXSegmentedView替代 | 4天 | 高 | 自定义SegmentedView |
| TabBar迁移 | 4天 | 高 | 自定义TabBar样式 |
| 主导航结构 | 3天 | 高 | NavigationStack |
| 路由系统 | 3天 | 高 | TheRouter迁移 |

**验收标准：**
- [ ] Tab切换正常
- [ ] 页面跳转正常
- [ ] 深层链接正常

---

## 📦 SwiftUI组件替代方案

### UIKit → SwiftUI 映射

| UIKit组件 | SwiftUI替代 | 实现方案 |
|----------|-------------|---------|
| UITableView | List | .listStyle() |
| UICollectionView | LazyVGrid/HGrid | GridItem定义 |
| MJRefresh | .refreshable | RefreshAction |
| JXSegmentedView | Picker | .pickerStyle() |
| FSPagerView | TabView | .pageTabViewStyle() |
| UIActivityIndicatorView | ProgressView | .progressViewStyle() |
| UIAlertController | Alert/Sheet | .alert()/.sheet() |
| UIPageViewController | TabView | .pageTabViewStyle() |
| UINavigationController | NavigationStack | iOS 16+ |

### UIViewRepresentable 桥接

对于暂无SwiftUI替代的组件，使用UIViewRepresentable：

```swift
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
```

---

## 🔄 RxSwift → Combine 迁移

### 常用模式映射

| RxSwift | Combine | SwiftUI |
|---------|---------|---------|
| `Observable` | `Publisher` | `@State`, `@Published` |
| `BehaviorRelay` | `CurrentValueSubject` | `@State` |
| `PublishRelay` | `PassthroughSubject` | `@State` + onChange |
| `Driver` | `Publisher` | `@StateObject` |
| `.bind(to:)` | `.assign(to:on:)` | 直接绑定 |
| `.flatMap` | `.flatMap` | 相同 |
| `.compactMap` | `.compactMap` | 相同 |
| `.filter` | `.filter` | 相同 |
| `.debounce` | `.debounce` | 相同 |
| `.distinctUntilChanged` | `.removeDuplicates` | 相同 |
| `DisposeBag` | `@StateObject` | 自动管理 |

### ViewModel迁移示例

**RxSwift版本：**
```swift
class HomeViewModel: BaseViewModel {
    let dataSource = BehaviorRelay<[Info]>(value: [])
    let refreshSubject = BehaviorSubject<MJRefreshAction>(value: .begainRefresh)

    func loadData() {
        homeProvider.rx.request(HomeService.normalArticle(page))
            .map { try $0.map(BaseModel<Page<Info>>.self) }
            .subscribe(onSuccess: { [weak self] in
                self?.dataSource.accept($0.data?.datas ?? [])
            })
            .disposed(by: disposeBag)
    }
}
```

**Combine版本：**
```swift
@MainActor
class HomeViewModel: ObservableObject {
    @Published var dataSource: [Info] = []
    @Published var refreshState: RefreshState = .idle

    func loadData() {
        Task {
            do {
                let response = try await homeProvider.request(.normalArticle(page))
                let model = try JSONDecoder().decode(BaseModel<Page<Info>>.self, from: response.data)
                dataSource = model.data?.datas ?? []
                refreshState = .idle
            } catch {
                refreshState = .error(error)
            }
        }
    }
}
```

---

## 🗑️ 依赖更新（SwiftUI迁移后）

### 移除的依赖

```
❌ RxSwift, RxCocoa (替换为Combine)
❌ RxDataSources (SwiftUI原生ForEach)
❌ RxGesture (SwiftUI原生手势)
❌ RxTheme (SwiftUI @Environment)
❌ SnapKit (SwiftUI声明式布局)
❌ NSObject+Rx (SwiftUI @StateObject)
❌ JXSegmentedView (自定义SwiftUI组件)
❌ FSPagerView (TabView + pageTabViewStyle)
❌ MJRefresh (.refreshable)
```

### 保留的依赖

```
✅ Moya + RxMoya (逐步迁移到async/await)
✅ Alamofire (保持)
✅ Kingfisher (或迁移到AsyncImage)
✅ KeychainAccess (保持)
✅ CocoaLumberjack (保持)
✅ ZipArchive (保持)
```

### 新增的依赖（可选）

```
📦 CombineCocoa (与UIKit桥接)
📦 SwiftUI相关组件库
```

---

## 📂 文件迁移清单

### 需要重写的文件

| 原路径 | 新路径 | 操作 |
|--------|--------|------|
| `RxStudy/*/Controller/*.swift` | `RxStudy/*/Views/*.swift` | 重写为View |
| `RxStudy/*/ViewModel/*.swift` | `RxStudy/*/ViewModels/*.swift` | 迁移到Combine |
| `RxStudy/Base/BaseViewController.swift` | - | 移除（SwiftUI不需要） |
| `RxStudy/Base/BaseViewModel.swift` | `RxStudy/Base/BaseViewModel.swift` | 改写@ObservableObject |

### 需要新建的文件

| 路径 | 说明 |
|------|------|
| `RxStudy/Views/Components/` | SwiftUI组件库 |
| `RxStudy/State/` | 全局状态管理 |
| `RxStudy/Theme/` | SwiftUI主题系统 |
| `RxStudy/Extensions/View+` | View扩展 |

---

## 🧪 测试策略

### 单元测试
- [ ] ViewModel测试（Combine Publisher测试）
- [ ] 网络层测试（Mock响应）
- [ ] 工具类测试

### UI测试
- [ ] 关键流程UI测试
- [ ] 截图测试（Snapshot）

### 性能测试
- [ ] 启动时间 ≤ 原版本
- [ ] 内存占用 ≤ 原版本
- [ ] 滚动帧率 ≥ 60fps
- [ ] 页面切换流畅度

---

## 🎯 验收标准

### 功能验收
- [ ] 所有页面使用SwiftUI实现
- [ ] 所有交互功能正常
- [ ] 状态管理正确
- [ ] 主题切换正常
- [ ] 横竖屏适配正常
- [ ] 深层链接正常

### 性能验收
- [ ] 启动时间不增加
- [ ] 内存占用不增加
- [ ] 滚动性能不降低
- [ ] 动画流畅度保持

### 代码质量
- [ ] 无编译警告
- [ ] 代码规范一致
- [ ] 注释完整
- [ ] 测试覆盖率 ≥ 60%

---

## 📊 风险与应对

| 风险 | 影响 | 应对措施 |
|-----|------|---------|
| SwiftUI功能限制 | 高 | 使用UIViewRepresentable桥接 |
| 性能回退 | 中 | 性能测试对比，优化关键路径 |
| 学习曲线 | 中 | 团队培训，参考官方文档 |
| 迁移周期过长 | 中 | 分阶段交付，每个模块独立可用 |
| 兼容性问题 | 低 | 最低版本iOS 17.6 |

---

## 🚀 迁移启动命令

### 1. 创建迁移分支
```bash
git checkout -b refactor/swiftui-migration
```

### 2. 创建基础组件库
```bash
mkdir -p RxStudy/Views/Components
mkdir -p RxStudy/State
mkdir -p RxStudy/Theme
```

### 3. 更新Project.swift（添加SwiftUI支持）
```swift
targets: [
    .target(
        name: "RxStudy",
        // ...
        settings: .settings(
            base: [
                "ENABLE_PREVIEWS": "YES",  // SwiftUI预览
                // ...
            ]
        )
    )
]
```

### 4. 开始迁移第一个模块
建议从 `ActivityIndicator` 组件开始

---

## 📚 参考资料

### 官方文档
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [SwiftUI by Example](https://www.hackingwithswift.com/quick-start/swiftui)

### 推荐文章
- [RxSwift to Combine Cheat Sheet](https://github.com/RxSwiftCommunity/RxSwiftCombine)
- [SwiftUI Migration Guide](https://developer.apple.com/videos/play/wwdc2022/10055/)

### 项目参考
- TemplateTuist项目中的SwiftUI示例

---

## 📝 当前状态总结

### ✅ 已完成
- [x] Phase 1: Tuist构建系统
- [x] Phase 2: SPM依赖迁移
- [x] 移除Flutter和UniApp
- [x] 修复所有编译错误
- [x] 真机测试通过
- [x] 启动屏修复
- [x] Git标签 v1.0.0-uikit-tuist

### 🔄 进行中
- [ ] Phase 3: SwiftUI + Combine迁移

### ⏭️ 待开始
- [ ] 创建SwiftUI基础组件库
- [ ] 迁移账号模块
- [ ] 迁移Home模块
- [ ] 迁移导航结构

---

## 🎉 里程碑规划

| 里程碑 | 预计完成 | 标签 | 说明 |
|--------|----------|------|------|
| UIKit + Tuist | ✅ 2025-02-18 | `v1.0.0-uikit-tuist` | 当前版本 |
| SwiftUI基础组件 | Week 2 | `v1.1.0-swiftui-base` | 基础组件库完成 |
| 账号模块迁移 | Week 4 | `v1.2.0-swiftui-account` | 账号模块完成 |
| 独立功能迁移 | Week 6 | `v1.3.0-swiftui-features` | 功能模块完成 |
| WebView迁移 | Week 8 | `v1.4.0-swiftui-webview` | WebView迁移完成 |
| 列表迁移 | Week 10 | `v1.5.0-swiftui-lists` | 复杂列表完成 |
| 导航迁移 | Week 12 | `v2.0.0-swiftui-complete` | SwiftUI迁移完成 |

---

*最后更新：2025年2月18日*
*下次继续：启动SwiftUI + Combine迁移*
