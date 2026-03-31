[根目录](../../CLAUDE.md) > [RxStudy](../) > **Tabs**

# Tabs 模块

## 模块职责

Tabs模块包含项目Tab和公众号Tab的功能实现，通过 `TabsController` 和 `SingleTabListController` 实现Tab切换和列表展示。

## 入口与启动

- **入口控制器**: `TabsController`
- **列表控制器**: `SingleTabListController`
- **ViewModel**: `SingleTabListViewModel`, `TabsViewModel`

## 对外接口

### 枚举定义
```swift
// LayoutType - 布局类型
enum LayoutType {
    case project   // 项目布局
    case publicNumber  // 公众号布局
    case tree  // 体系布局
}

// TagType - 标签类型
enum TagType {
    case project   // 项目标签
    case publicNumber  // 公众号标签
    case tree  // 体系标签
}
```

### 控制器方法
```swift
// TabsController
init(type: LayoutType)

// SingleTabListController
init(type: LayoutType, tag: Tab)
```

## 关键依赖与配置

| 依赖 | 用途 |
|------|------|
| JXSegmentedView | Tab指示器 |
| MJRefresh | 刷新 |
| SnapKit | 布局 |

### API接口
- `Api.Project.tags` / `tagList` - 项目分类
- `Api.PublicNumber.tags` / `tagList` - 公众号分类
- `Api.Tree.tags` / `tagList` - 体系分类

## 数据模型

| 模型 | 说明 |
|------|------|
| `TabModel` | Tab标签数据 |
| `TabAble` | Tab协议 |
| `Info` | 文章/项目信息 |

## 测试与质量

- **单元测试**: 无
- **UI测试**: 无

## 常见问题 (FAQ)

**Q: 如何添加新的Tab类型?**
A: 在 `LayoutType` 和 `TagType` 枚举中添加新case。

## 相关文件清单

| 文件 | 路径 |
|------|------|
| TabsController | `Tabs/Controller/TabsController.swift` |
| SingleTabListController | `Tabs/Controller/SingleTabListController.swift` |
| TreeController | `Tabs/Controller/TreeController.swift` |
| LayoutType | `Tabs/Enum/LayoutType.swift` |
| TagType | `Tabs/Enum/TagType.swift` |

## 变更记录 (Changelog)

### 2026-03-24
- 创建模块文档
