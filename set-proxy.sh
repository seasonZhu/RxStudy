#!/bin/bash

# 设置代理脚本
# 使用方法: ./set-proxy.sh [端口号]
# 默认端口号: 7890

# 默认代理端口
PROXY_PORT=${1:-7890}
PROXY_URL="http://127.0.0.1:${PROXY_PORT}"

echo "📡 正在设置代理..."
echo "   代理地址: ${PROXY_URL}"

# 设置Git代理
git config --global http.proxy "${PROXY_URL}"
git config --global https.proxy "${PROXY_URL}"

# 设置环境变量
export http_proxy="${PROXY_URL}"
export https_proxy="${PROXY_URL}"
export HTTP_PROXY="${PROXY_URL}"
export HTTPS_PROXY="${PROXY_URL}"
export all_proxy="${PROXY_URL}"
export ALL_PROXY="${PROXY_URL}"

# 取消NO_PROXY
unset NO_PROXY
unset no_proxy

echo ""
echo "✅ 代理设置完成！"
echo ""
echo "当前配置："
echo "  Git HTTP代理:  $(git config --global http.proxy)"
echo "  Git HTTPS代理: $(git config --global https.proxy)"
echo ""
echo "💡 提示：这些环境变量仅在当前终端会话有效"
echo "   如需永久生效，请将 export 命令添加到 ~/.zshrc 或 ~/.bash_profile"
