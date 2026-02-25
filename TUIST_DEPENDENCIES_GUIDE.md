# Tuist 第三方库管理说明

## 📁 第三方库存储位置

### 1. 项目级缓存（当前项目专用）

```
/Users/dy/Documents/Swift Git/RxStudy/Tuist/.build/
```

**目录结构**：
```
Tuist/.build/
├── artifacts/           # 构建产物
├── checkouts/          # 📦 第三方源码下载位置
│   ├── RxGesture/
│   └── RxOptional/
├── repositories/       # 📚 Git 仓库克隆位置（已下载 18 个）
│   ├── Alamofire-63cd6d99/
│   ├── RxSwift-25ac69bd/
│   ├── Moya-20582669/
│   ├── Kingfisher-adb94c78/
│   ├── SnapKit-a5691e5b/
│   └── ... (共 18 个依赖)
└── workspace-state.json # 工作空间状态
```

### 2. 全局缓存（所有项目共享）

```
~/.cache/tuist/
```

**目录结构**：
```
~/.cache/tuist/
├── Binaries/             # 二进制文件缓存
├── Manifests/            # 依赖清单缓存（28 个文件）
├── Plugins/              # Tuist 插件缓存
├── Projects/             # 项目描述缓存
└── Runs/                 # 运行缓存
```

## 📊 已下载的依赖列表

### ✅ 成功下载到本地（18 个）

| 依赖 | 仓库目录 | 状态 |
|------|----------|------|
| Alamofire | `Alamofire-63cd6d99` | ✅ |
| CocoaLumberjack | `CocoaLumberjack-e116e071` | ✅ |
| KeychainAccess | `KeychainAccess-bf77584f` | ✅ |
| Kingfisher | `Kingfisher-adb94c78` | ✅ |
| MarqueeLabel | `MarqueeLabel-f3749f74` | ✅ |
| Moya | `Moya-20582669` | ✅ |
| ReactiveSwift | `ReactiveSwift-6916d001` | ✅ |
| RxDataSources | `RxDataSources-f27095ef` | ✅ |
| RxGesture | `RxGesture-b4de69ad` | ✅ |
| RxOptional | `RxOptional-bdc0e319` | ✅ |
| RxSwift | `RxSwift-25ac69bd` | ✅ |
| RxSwiftExt | `RxSwiftExt-0c4f27cc` | ✅ |
| RxTheme | `RxTheme-2ea15fbe` | ✅ |
| SFSafeSymbols | `SFSafeSymbols-6f8cc402` | ✅ |
| SnapKit | `SnapKit-a5691e5b` | ✅ |
| swift-log | `swift-log-ba8887eb` | ✅ |
| ZipArchive | `ZipArchive-15c030fd` | ✅ |

## 🔄 依赖管理流程

### 下载流程

```
tuist install
  ↓
读取 Tuist/Package.swift 中的依赖定义
  ↓
解析版本要求（from: "6.7.0"）
  ↓
克隆到: Tuist/.build/repositories/[名称]-[hash]/
  ↓
检出到: Tuist/.build/checkouts/[名称]/
  ↓
缓存到: ~/.cache/tuist/Manifests/
```

### 生成项目流程

```
tuist generate
  ↓
读取 Project.swift 中的 TargetDependency.external(name:)
  ↓
从 Tuist/.build/ 中查找已下载的依赖
  ↓
链接依赖到生成的 Xcode 项目
  ↓
生成 RxStudy.xcodeproj
```

## 🛠️ 常用操作

### 查看已下载的依赖

```bash
# 查看所有仓库
ls ~/Documents/Swift\ Git/RxStudy/Tuist/.build/repositories/

# 查看具体依赖的源码
ls ~/Documents/Swift\ Git/RxStudy/Tuist/.build/checkouts/RxSwift/
```

### 清理缓存

```bash
# 清理项目级缓存
rm -rf ~/Documents/Swift\ Git/RxStudy/Tuist/.build

# 清理全局缓存
rm -rf ~/.cache/tuist
```

### 重新下载依赖

```bash
cd ~/Documents/Swift\ Git/RxStudy
tuist install
```

## 📌 关键文件说明

| 文件 | 位置 | 作用 |
|------|------|------|
| **Tuist/Package.swift** | 项目根目录 | 定义需要下载的依赖列表 |
| **Project.swift** | 项目根目录 | 定义项目结构和 TargetDependency.external(name:) 引用 |
| **Tuist/.build/** | Tuist/.build/ | 依赖源码存储位置 |
| **~/.cache/tuist/** | 系统缓存 | Tuist 全局缓存 |

## ✅ 当前状态

- ✅ **依赖已下载**: 18 个第三方库已下载到本地
- ✅ **配置正确**: Tuist/Package.swift 和 Project.swift 配置正确
- ✅ **网络正常**: set-proxy 脚本已配置 Git 代理

## 🚀 下一步

现在您可以运行 `tuist generate` 生成 Xcode 项目了！
