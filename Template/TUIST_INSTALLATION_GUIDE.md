# Tuist 安装与管理指南

本文档详细介绍 Tuist 的安装、升级和卸载方法。

## 目录

1. [系统要求](#系统要求)
2. [安装方法](#安装方法)
3. [升级更新](#升级更新)
4. [卸载](#卸载)
5. [版本管理](#版本管理)
6. [常见问题](#常见问题)

---

## 系统要求

### 最低要求

- **macOS**: 13.0 (Ventura) 或更高版本
- **Xcode**: 15.0 或更高版本
- **Swift**: 5.9 或更高版本

### 推荐配置

- **macOS**: 14.0 (Sonoma) 或更高版本
- **Xcode**: 15.2 或更高版本
- **内存**: 8GB RAM 或更多（大型项目建议 16GB+）
- **磁盘空间**: 至少 10GB 可用空间

---

## 安装方法

Tuist 提供多种安装方式，推荐使用 **Mint** 或 **Homebrew** 进行安装。

### 方法 1: 使用 Mint（推荐）

Mint 是 Swift CLI 工具的包管理器，可以轻松管理 Tuist 版本。

#### 步骤 1: 安装 Mint

```bash
# 如果已安装 Homebrew
brew install mint

# 或从源码安装
git clone https://github.com/yonaskolb/Mint.git
cd Mint
make install
```

#### 步骤 2: 安装 Tuist

```bash
# 安装最新版本
mint install tuist/tuist

# 安装特定版本
mint install tuist/tuist@3.18.0

# 验证安装
mint run tuist version
```

#### 步骤 3: 创建全局别名（可选）

在 `~/.zshrc` 或 `~/.bash_profile` 中添加：

```bash
# Tuist alias
alias tuist='mint run tuist/tuist'
```

然后执行：

```bash
source ~/.zshrc  # 或 source ~/.bash_profile
```

### 方法 2: 使用 Homebrew

#### 步骤 1: 添加 Tap

```bash
brew tap tuist/tuist
```

#### 步骤 2: 安装 Tuist

```bash
# 安装最新版本
brew install tuist

# 安装特定版本
brew install tuist@3.18.0
```

#### 步骤 3: 验证安装

```bash
tuist version
```

### 方法 3: 使用官方安装脚本

Tuist 提供了自动安装脚本，适合快速安装。

```bash
# 安装最新版本
curl -Ls https://install.tuist.dev | bash

# 安装特定版本
curl -Ls https://install.tuist.dev | bash -s -- --install-version 3.18.0
```

安装完成后，将以下内容添加到 `~/.zshrc`：

```bash
# Tuist
export PATH="$HOME/.tuist/bin:$PATH"
```

### 方法 4: 手动安装

#### 步骤 1: 下载预编译二进制文件

访问 [Tuist Releases](https://github.com/tuist/tuist/releases) 下载对应版本的 `.zip` 文件。

#### 步骤 2: 解压并安装

```bash
# 解压
unzip tuist.zip

# 移动到安装目录
sudo mkdir -p /usr/local/bin
sudo mv tuist /usr/local/bin/

# 验证
tuist version
```

### 方法 5: 从源码编译

适合需要自定义 Tuist 或参与开发的用户。

#### 步骤 1: 克隆仓库

```bash
git clone https://github.com/tuist/tuist.git
cd tuist
```

#### 步骤 2: 编译安装

```bash
# 使用 Swift 编译
swift build -c release

# 复制到安装目录
sudo cp .build/release/tuist /usr/local/bin/

# 验证
tuist version
```

---

## 升级更新

### 使用 Mint 升级

```bash
# 升级到最新版本
mint install tuist/tuist

# 升级到特定版本
mint install tuist/tuist@3.20.0

# 清理旧版本
mint uninstall tuist/tuist@3.18.0
```

### 使用 Homebrew 升级

```bash
# 更新 Homebrew
brew update

# 升级 Tuist
brew upgrade tuist

# 或升级特定版本
brew upgrade tuist@3.20.0

# 清理旧版本
brew cleanup
```

### 使用安装脚本升级

```bash
# 重新运行安装脚本
curl -Ls https://install.tuist.dev | bash

# 升级到特定版本
curl -Ls https://install.tuist.dev | bash -s -- --install-version 3.20.0
```

### 手动升级

```bash
# 1. 下载新版本
curl -LO https://github.com/tuist/tuist/releases/download/3.20.0/tuist.zip

# 2. 解压
unzip tuist.zip

# 3. 替换旧版本
sudo mv tuist /usr/local/bin/

# 4. 验证
tuist version
```

### 从源码升级

```bash
# 1. 进入源码目录
cd tuist

# 2. 拉取最新代码
git pull origin main
git checkout 3.20.0  # 或使用特定版本标签

# 3. 重新编译
swift build -c release

# 4. 替换二进制文件
sudo cp .build/release/tuist /usr/local/bin/
```

### 检查可用更新

```bash
# 查看当前版本
tuist version

# 查看最新版本（GitHub）
curl -s https://api.github.com/repos/tuist/tuist/releases/latest | grep tag_name

# 或直接访问
open https://github.com/tuist/tuist/releases
```

---

## 卸载

### 使用 Mint 卸载

```bash
# 卸载特定版本
mint uninstall tuist/tuist@3.18.0

# 卸载所有版本
mint uninstall tuist/tuist

# 删除别名（如果设置了）
# 编辑 ~/.zshrc 或 ~/.bash_profile，删除 tuist alias
```

### 使用 Homebrew 卸载

```bash
# 卸载 Tuist
brew uninstall tuist

# 卸载特定版本
brew uninstall tuist@3.18.0

# 清理相关文件
brew cleanup
```

### 完全卸载（所有安装方式）

```bash
# 1. 删除二进制文件
sudo rm -f /usr/local/bin/tuist
sudo rm -f ~/.tuist/bin/tuist

# 2. 删除配置和缓存
rm -rf ~/.tuist
rm -rf ~/Library/Caches/tuist
rm -rf ~/Library/Application\ Support/tuist

# 3. 删除 Mint 缓存（如果使用 Mint）
mint uninstall tuist/tuist

# 4. 删除 Homebrew 安装（如果使用 Homebrew）
brew uninstall tuist
brew untap tuist/tuist

# 5. 删除别名（如果设置了）
# 编辑 ~/.zshrc 或 ~/.bash_profile，删除以下行：
# alias tuist='mint run tuist/tuist'
# export PATH="$HOME/.tuist/bin:$PATH"

# 6. 重新加载 Shell 配置
source ~/.zshrc
```

---

## 版本管理

### 查看当前版本

```bash
tuist version
```

### 安装特定版本

#### Mint

```bash
mint install tuist/tuist@3.18.0
```

#### Homebrew

```bash
# 查看可用版本
brew info tuist

# 安装特定版本
brew install tuist@3.18.0
```

#### 安装脚本

```bash
curl -Ls https://install.tuist.dev | bash -s -- --install-version 3.18.0
```

### 多版本管理

#### 使用 Mint（推荐）

Mint 天然支持多版本管理：

```bash
# 安装多个版本
mint install tuist/tuist@3.18.0
mint install tuist/tuist@3.20.0

# 使用特定版本
mint run tuist/tuist@3.18.0 version
mint run tuist/tuist@3.20.0 version

# 设置默认版本（通过别名）
alias tuist318='mint run tuist/tuist@3.18.0'
alias tuist320='mint run tuist/tuist@3.20.0'
alias tuist='mint run tuist/tuist@3.20.0'  # 默认使用 3.20.0
```

#### 手动管理多个版本

```bash
# 1. 创建版本目录
mkdir -p ~/.tuist/versions

# 2. 下载并解压多个版本
cd ~/.tuist/versions
curl -LO https://github.com/tuist/tuist/releases/download/3.18.0/tuist.zip
unzip tuist.zip -d 3.18.0
rm tuist.zip

curl -LO https://github.com/tuist/tuist/releases/download/3.20.0/tuist.zip
unzip tuist.zip -d 3.20.0
rm tuist.zip

# 3. 创建切换脚本
cat > ~/.tuist-switch.sh << 'EOF'
#!/bin/bash
VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: tuist-switch <version>"
    echo "Available versions:"
    ls ~/.tuist/versions
    exit 1
fi
ln -sf ~/.tuist/versions/$VERSION/tuist ~/.tuist/bin/tuist
echo "Switched to Tuist $VERSION"
tuist version
EOF

chmod +x ~/.tuist-switch.sh

# 4. 添加到 PATH
export PATH="$HOME/.tuist/bin:$PATH"

# 5. 切换版本
tuist-switch 3.18.0
tuist-switch 3.20.0
```

### 项目版本锁定

在项目中指定 Tuist 版本：

```bash
# 创建 .tuist-version 文件
echo "3.18.0" > .tuist-version
```

或使用 `.tuist-supported-version`：

```bash
# .tuist-supported-version
3.18.0
```

### 版本兼容性

| Tuist 版本 | 最低 macOS | 最低 Xcode | Swift 版本 |
|------------|-----------|------------|------------|
| 3.x | 13.0 | 15.0 | 5.9 |
| 2.x | 12.0 | 14.0 | 5.7 |
| 1.x | 11.0 | 13.0 | 5.5 |

---

## 常见问题

### Q1: 安装后提示 "command not found: tuist"

**解决方案**:

```bash
# 1. 确认安装位置
which tuist
# 或
find /usr/local -name tuist 2>/dev/null

# 2. 添加到 PATH
export PATH="/usr/local/bin:$PATH"

# 3. 或创建符号链接
sudo ln -s ~/.tuist/bin/tuist /usr/local/bin/tuist

# 4. 重新加载 Shell 配置
source ~/.zshrc
```

### Q2: 升级后项目报错

**解决方案**:

```bash
# 1. 清理缓存
tuist clean

# 2. 重新安装依赖
tuist install

# 3. 检查版本兼容性
tuist version
cat .tuist-supported-version

# 4. 如果需要，降级到兼容版本
mint install tuist/tuist@3.18.0
```

### Q3: Mint 安装后无法运行

**解决方案**:

```bash
# 1. 确保 Mint 正确安装
mint --version

# 2. 重新安装 Tuist
mint uninstall tuist/tuist
mint install tuist/tuist

# 3. 检查 Mint 缓存
mint list

# 4. 清理并重试
rm -rf ~/.mint/tuist
mint install tuist/tuist
```

### Q4: 权限错误

**解决方案**:

```bash
# 1. 修复权限
sudo chown -R $(whoami) ~/.tuist
sudo chown -R $(whoami) ~/Library/Caches/tuist

# 2. 或重新安装到用户目录
mint install tuist/tuist
```

### Q5: 编译错误 "Swift version mismatch"

**解决方案**:

```bash
# 1. 检查 Xcode Swift 版本
xcrun swift --version

# 2. 切换 Xcode 版本
sudo xcode-select -s /Applications/Xcode-15.2.app

# 3. 重新安装 Tuist
mint reinstall tuist/tuist
```

### Q6: 缓存问题导致构建失败

**解决方案**:

```bash
# 1. 清理 Tuist 缓存
tuist clean

# 2. 清理本地缓存
rm -rf ~/.tuist/cache
rm -rf ~/Library/Caches/tuist

# 3. 清理 Xcode 派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData

# 4. 重新生成项目
tuist install && tuist generate
```

### Q7: 如何在 CI/CD 中使用 Tuist

#### GitHub Actions 示例

```yaml
name: Build

jobs:
  build:
    runs-on: macos-14

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Tuist
        run: |
          curl -Ls https://install.tuist.dev | bash
          echo "$HOME/.tuist/bin" >> $GITHUB_PATH

      - name: Verify Tuist
        run: tuist version

      - name: Install dependencies
        run: tuist install

      - name: Generate project
        run: tuist generate

      - name: Build
        run: xcodebuild -workspace App.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 15' build
```

#### GitLab CI 示例

```yaml
build:
  image: macos-14-xcode-15
  script:
    # 安装 Tuist
    - curl -Ls https://install.tuist.dev | bash
    - export PATH="$HOME/.tuist/bin:$PATH"

    # 验证安装
    - tuist version

    # 构建项目
    - tuist install
    - tuist generate
    - xcodebuild -workspace App.xcworkspace -scheme App -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Q8: 与 Xcode Server / CI 集成

```bash
# 1. 指定 Xcode 路径
sudo xcode-select -s /Applications/Xcode.app

# 2. 设置环境变量
export DEVELOPER_DIR=/Applications/Xcode.app

# 3. 运行 Tuist
tuist generate
```

---

## 附录

### A. 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `TUIST_CONFIG_PATH` | 配置文件路径 | `~/.tuist/config.yml` |
| `TUIST_CACHE_PATH` | 缓存目录路径 | `~/.tuist/cache` |
| `TUIST_ANALYTICS_DISABLED` | 禁用分析 | `false` |
| `DEVELOPER_DIR` | Xcode 开发者目录 | - |

### B. 目录结构

```
~/.tuist/                    # Tuist 主目录
├── bin/                     # 二进制文件
│   └── tuist
├── cache/                   # 缓存目录
│   ├── frameworks/          # 缓存的框架
│   └── dependencies/        # 缓存的依赖
├── config.yml               # 配置文件
└── versions/                # 多版本安装目录（手动管理）
    ├── 3.18.0/
    │   └── tuist
    └── 3.20.0/
        └── tuist

~/Library/Caches/tuist/      # 系统缓存
~/Library/Application Support/tuist/  # 应用支持文件
```

### C. 相关链接

- **官方网站**: https://tuist.dev
- **GitHub 仓库**: https://github.com/tuist/tuist
- **文档**: https://tuist.dev/docs/
- **发布页面**: https://github.com/tuist/tuist/releases
- **社区讨论**: https://community.tuist.dev
- **Twitter**: [@tuistapp](https://twitter.com/tuistapp)

### D. 快速参考

```bash
# 安装最新版本
curl -Ls https://install.tuist.dev | bash

# 安装特定版本
curl -Ls https://install.tuist.dev | bash -s -- --install-version 3.18.0

# 使用 Mint 安装
mint install tuist/tuist

# 使用 Homebrew 安装
brew install tuist

# 查看版本
tuist version

# 升级
brew upgrade tuist

# 卸载
brew uninstall tuist

# 完全卸载
rm -rf ~/.tuist
rm -rf ~/Library/Caches/tuist
```

---

**最后更新**: 2026-02-27
**适用版本**: Tuist 3.x
