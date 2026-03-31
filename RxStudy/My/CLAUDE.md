[根目录](../../CLAUDE.md) > [RxStudy](../) > **My**

# My 模块

## 模块职责

我的模块负责展示用户个人中心页面，包括用户积分信息、积分排行榜、收藏文章、工具列表、第三方App展示等功能。

## 入口与启动

- **入口控制器**: `MyController`
- **入口ViewModel**: `MyViewModel`
- **初始化**: TabBar点击"我的"进入

## 对外接口

### 控制器
```swift
// 积分排行榜
CoinRankListController

// 我的积分
MyCoinController

// 我的收藏
MyCollectionController

// 工具列表
ToolController

// 消息中心
MyMessageController
```

### ViewModel
```swift
MyViewModel
CoinRankViewModel
MyCoinViewModel
MyCollectionViewModel
ToolViewModel
MessageViewModel
```

## 关键依赖与配置

| 依赖 | 用途 |
|------|------|
| Kingfisher | 头像/图片加载 |
| MJRefresh | 刷新 |
| SnapKit | 布局 |

### API接口
- `Api.My.coinRank` - 积分排行榜
- `Api.My.userCoinInfo` - 用户积分信息
- `Api.My.myCoinList` - 积分记录
- `Api.My.collectArticleList` - 收藏文章
- `Api.My.unreadCount` - 未读消息数
- `Api.Other.tools` - 工具列表

## 数据模型

| 模型 | 说明 |
|------|------|
| `CoinRank` | 积分排名数据 |
| `AccountInfo` | 用户账户信息 |
| `Info` | 文章信息 |

## 测试与质量

- **单元测试**: 无
- **UI测试**: 无

## 常见问题 (FAQ)

**Q: 如何查看积分排行榜?**
A: 从我的页面点击"积分排行榜"进入 `CoinRankListController`。

**Q: 收藏文章如何同步?**
A: 通过 `AccountManager` 维护收藏状态，登录后自动同步。

## 相关文件清单

| 文件 | 路径 |
|------|------|
| MyController | `My/Controller/MyController.swift` |
| MyViewModel | `My/ViewModel/MyViewModel.swift` |
| CoinRankListController | `My/Controller/CoinRankListController.swift` |
| MyCoinController | `My/Controller/MyCoinController.swift` |
| MyCollectionController | `My/Controller/MyCollectionController.swift` |
| ToolController | `My/Controller/ToolController.swift` |

## 变更记录 (Changelog)

### 2026-03-24
- 创建模块文档
