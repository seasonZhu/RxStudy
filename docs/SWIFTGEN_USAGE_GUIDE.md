# SwiftGen 使用实践指南

> 在 Tuist 项目中使用 SwiftGen 实现资源类型安全访问

---

## 一、已生成的资源类型

### 1.1 Assets 图片资源

```swift
// RxStudy/Generated/Assets+SwiftGen.swift
public enum Asset {
    // TabBar 图标
    public static let home = ImageAsset(name: "home")
    public static let homeSelected = ImageAsset(name: "home_selected")
    public static let my = ImageAsset(name: "my")
    public static let mySelected = ImageAsset(name: "my_selected")
    public static let project = ImageAsset(name: "project")
    public static let projectSelected = ImageAsset(name: "project_selected")
    public static let collect = ImageAsset(name: "collect")
    public static let collectSelected = ImageAsset(name: "collect_selected")

    // 其他图片
    public static let back = ImageAsset(name: "back")
    public static let android = ImageAsset(name: "android")
    public static let loading01 = ImageAsset(name: "loading_01")
    // ... 更多

    // 颜色
    public static let mainTheme = ColorAsset(name: "mainTheme")
}
```

### 1.2 本地化字符串

```swift
// RxStudy/Generated/Strings+SwiftGen.swift
public enum L10n {
    // 通用
    public enum Common {
        public static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "取消")
        public static let confirm = L10n.tr("Localizable", "common.confirm", fallback: "确认")
        public static let loading = L10n.tr("Localizable", "common.loading", fallback: "加载中...")
    }

    // 首页
    public enum Home {
        public static let title = L10n.tr("Localizable", "home.title", fallback: "首页")
        public static let welcome = L10n.tr("Localizable", "home.welcome", fallback: "欢迎使用玩安卓")
    }

    // 项目
    public enum Project {
        public static let list = L10n.tr("Localizable", "project.list", fallback: "项目列表")
        public static let title = L10n.tr("Localizable", "project.title", fallback: "项目")
    }
}
```

---

## 二、在代码中使用 SwiftGen

### 2.1 UIKit 图片资源

#### UIButton 设置图片

```swift
import UIKit

class LoginViewController: UIViewController {

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        // ✅ 使用 SwiftGen，类型安全
        button.setImage(Asset.back.image, for: .normal)
        button.setImage(Asset.back.image.withRenderingMode(.alwaysTemplate), for: .highlighted)
        return button
    }()
}
```

#### UIImageView 加载图片

```swift
import UIKit

class HomeViewController: UIViewController {

    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        // ✅ 类型安全访问
        iv.image = Asset.android.image
        iv.contentMode = .scaleAspectFit
        return iv
    }()
}
```

#### Navigation Item 设置

```swift
import UIKit

class BaseViewController: UIViewController {

    func setupNavigation() {
        // 返回按钮
        let backItem = UIBarButtonItem(
            image: Asset.back.image.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem = backItem
    }
}
```

### 2.2 SwiftUI 图片资源

```swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            // ✅ 类型安全，自动补全
            Image(asset: Asset.home)
                .resizable()
                .frame(width: 24, height: 24)

            Image(asset: Asset.android)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
    }
}
```

### 2.3 TabBar 配置（完整示例）

#### 方式一：直接使用 Asset.*.image

```swift
import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let home = createHomeVC()
        let project = createProjectVC()
        let my = createMyVC()
        let collect = createCollectVC()

        viewControllers = [home, project, my, collect]
    }

    private func createHomeVC() -> UIViewController {
        let vc = HomeViewController()
        vc.tabBarItem = UITabBarItem(
            title: L10n.Home.title,
            image: Asset.home.image,
            selectedImage: Asset.homeSelected.image
        )
        return vc
    }

    private func createProjectVC() -> UIViewController {
        let vc = ProjectViewController()
        vc.tabBarItem = UITabBarItem(
            title: L10n.Project.title,
            image: Asset.project.image,
            selectedImage: Asset.projectSelected.image
        )
        return vc
    }

    // ... 其他 tab
}
```

#### 方式二：通过 TabType 枚举封装（推荐）

当有多个 Tab 需要管理时，可以通过 `TabType` 枚举统一管理，在内部返回 `UIImage`：

```swift
import UIKit

enum TabType: CaseIterable {
    case home
    case project
    case my
    case collect
}

extension TabType {
    /// ✅ 直接返回 UIImage，调用时更简洁
    var image: UIImage {
        switch self {
        case .home: return Asset.home.image
        case .project: return Asset.project.image
        case .my: return Asset.my.image
        case .collect: return Asset.collect.image
        }
    }

    var selectedImage: UIImage {
        switch self {
        case .home: return Asset.homeSelected.image
        case .project: return Asset.projectSelected.image
        case .my: return Asset.mySelected.image
        case .collect: return Asset.collectSelected.image
        }
    }

    var title: String {
        switch self {
        case .home: return L10n.Home.title
        case .project: return L10n.Project.title
        case .my: return "我的"
        case .collect: return "收藏"
        }
    }
}

// 使用时更简洁
class MainTabBarController: UITabBarController {

    private func setupTabs() {
        viewControllers = TabType.allCases.map { type in
            let vc = createViewController(for: type)
            vc.tabBarItem = UITabBarItem(
                title: type.title,
                image: type.image,              // ✅ 简洁调用
                selectedImage: type.selectedImage
            )
            return vc
        }
    }
}
```

**优势对比**：

| 方式 | 调用方式 | 优势 |
|------|---------|------|
| 方式一：直接使用 | `Asset.home.image` | 简单直接，适合少量使用 |
| 方式二：TabType 封装 | `type.image` | API 更简洁，集中管理，适合 TabBar 等场景 |

### 2.4 本地化字符串使用

```swift
import UIKit

// ✅ 旧方式（容易拼写错误）
let label1 = UILabel()
label1.text = NSLocalizedString("home.title", comment: "")

// ✅ 新方式（类型安全，自动补全）
let label2 = UILabel()
label2.text = L10n.Home.title

// Alert
let alert = UIAlertController(
    title: L10n.Common.confirm,
    message: nil,
    preferredStyle: .alert
)

// Button
let button = UIButton()
button.setTitle(L10n.Common.cancel, for: .normal)
```

### 2.5 SwiftUI 本地化

```swift
import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            Text(L10n.Home.welcome)
                .font(.title)

            Button(L10n.Common.confirm) {
                // 登录操作
            }

            Button(L10n.Common.cancel) {
                // 取消操作
            }
        }
    }
}
```

---

## 三、添加新资源的完整流程

### 3.1 添加新图片

#### 步骤 1：在 Assets.xcassets 中添加图片

1. 在 Xcode 中打开 `RxStudy/Assets.xcassets`
2. 拖入新的图片资源，例如 `new_icon`

#### 步骤 2：运行 SwiftGen

```bash
./scripts/swiftgen.sh
```

#### 步骤 3：使用新资源

```swift
// SwiftGen 自动生成 Asset.newIcon
let image = Asset.newIcon.image
```

---

### 3.2 添加新的本地化字符串

#### 步骤 1：编辑 Localizable.strings

**`RxStudy/zh-Hans.lproj/Localizable.strings`**
```
"new.feature.title" = "新功能";
"new.feature.description" = "这是一个很棒的新功能";
```

**`RxStudy/en.lproj/Localizable.strings`**
```
"new.feature.title" = "New Feature";
"new.feature.description" = "This is an awesome new feature";
```

#### 步骤 2：添加到 SwiftGen 配置

如果你创建了新的分组（如 `NewFeature`），SwiftGen 会自动生成：

```swift
// 运行 ./scripts/swiftgen.sh 后自动生成
public enum L10n {
    public enum NewFeature {
        public static let title = L10n.tr("Localizable", "new.feature.title", fallback: "新功能")
        public static let description = L10n.tr("Localizable", "new.feature.description", fallback: "这是一个很棒的新功能")
    }
}
```

#### 步骤 3：使用新字符串

```swift
let title = L10n.NewFeature.title
let desc = L10n.NewFeature.description
```

---

## 四、实际代码示例

### 4.1 完整的 ViewController 示例

```swift
import UIKit
import RxSwift

class HomeViewController: BaseViewController {

    // MARK: - UI Components

    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Asset.android.image  // SwiftGen
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Home.welcome  // SwiftGen
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Asset.loading01.image, for: .normal)  // SwiftGen
        button.setTitle(L10n.Common.loading, for: .normal)  // SwiftGen
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(welcomeLabel)
        view.addSubview(refreshButton)

        // 布局代码...
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel?.loading
            .map { loading in
                loading ? Asset.loading02.image : Asset.loading01.image
            }
            .drive(refreshButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
    }
}
```

### 4.2 SwiftUI View 示例

```swift
import SwiftUI

struct ProjectListView: View {
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            List {
                // Header
                HStack {
                    Image(asset: Asset.project.image)
                    Text(L10n.Project.title)
                    Spacer()
                }

                // Loading
                if isLoading {
                    HStack {
                        Image(asset: Asset.loading01.image)
                            .rotationEffect(isLoading ? .constant(Double.pi) : .zero)
                        Text(L10n.Common.loading)
                    }
                }
            }
            .navigationTitle(L10n.Project.list)
        }
    }
}
```

---

## 五、最佳实践

### 5.1 命名规范

**Assets.xcassets 命名**：
- 使用小写字母和下划线：`home_icon` → `Asset.homeIcon`
- 避免空格和特殊字符
- 使用描述性名称：`back_button` 而不是 `img1`

**Localizable.strings 命名**：
- 使用点号分隔命名空间：`home.title`
- 按功能分组：`common.confirm`, `common.cancel`

### 5.2 开发工作流

```
┌─────────────────────────────────────────────────────────────┐
│              开发工作流                                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 在 Assets.xcassets 中添加新图片                        │
│     或在 Localizable.strings 中添加新字符串                  │
│     ↓                                                       │
│  2. 运行 SwiftGen                                          │
│     ./scripts/swiftgen.sh                                 │
│     ↓                                                       │
│  3. 代码中自动获得类型安全访问                             │
│     Asset.newImage.image ✅                               │
│     L10n.NewString ✅                                       │
│     ↓                                                       │
│  4. 正常开发，编译时自动检查                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 团队协作

- ✅ `RxStudy/Generated/` 已加入 `.gitignore`
- ✅ 每个开发者运行 `./scripts/swiftgen.sh` 即可
- ✅ 生成的代码完全相同，无冲突风险

---

## 六、常见问题

### Q: 添加新资源后需要手动运行 SwiftGen 吗？

A: 是的，SwiftGen 不会自动运行：

```bash
# 每次添加新资源后运行
./scripts/swiftgen.sh
```

### Q: 可以自动化吗？

A: 可以创建 Makefile 或使用构建脚本：

```bash
# 自动化脚本
./scripts/swiftgen.sh && tuist generate
```

### Q: SwiftGen 生成的文件需要提交到 Git 吗？

A: 不需要，已在 `.gitignore` 中忽略：
```
RxStudy/Generated/
```

---

**文档版本**: v1.0
**更新日期**: 2026-02-24
**SwiftGen 版本**: 6.6.3
