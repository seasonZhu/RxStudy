#!/bin/bash

# SwiftGen 运行脚本
# 在打开任一构建方式的工程前生成资源访问代码

set -e

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "📦 运行 SwiftGen 生成资源访问代码..."

# 检查 SwiftGen 是否安装
if ! command -v swiftgen &> /dev/null; then
    echo "❌ SwiftGen 未安装"
    echo "   请运行: brew install swiftgen"
    exit 1
fi

# 运行 SwiftGen
mkdir -p Shared/Generated
swiftgen config run --config swiftgen.yml

echo "✅ SwiftGen 完成！"
echo ""
echo "生成的文件:"
echo "  - Shared/Generated/Strings+SwiftGen.swift"
echo "  - Shared/Generated/Assets+SwiftGen.swift"
echo "  - Shared/Generated/Fonts+SwiftGen.swift (如果有字体)"
