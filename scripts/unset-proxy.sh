#!/bin/bash

# 取消代理脚本
# 使用方法: ./unset-proxy.sh

echo "🚫 正在取消代理设置..."

# 取消Git代理
git config --global --unset http.proxy
git config --global --unset https.proxy

# 取消环境变量
export NO_PROXY="*"
export no_proxy="*"
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset all_proxy
unset ALL_PROXY

echo ""
echo "✅ 代理已取消！"
echo ""
echo "当前配置："
HTTP_PROXY_RESULT=$(git config --global http.proxy)
HTTPS_PROXY_RESULT=$(git config --global https.proxy)

if [ -z "$HTTP_PROXY_RESULT" ] && [ -z "$HTTPS_PROXY_RESULT" ]; then
    echo "  Git HTTP代理:  未设置"
    echo "  Git HTTPS代理: 未设置"
else
    echo "  Git HTTP代理:  ${HTTP_PROXY_RESULT}"
    echo "  Git HTTPS代理: ${HTTPS_PROXY_RESULT}"
fi
echo ""
echo "💡 提示：这些环境变量仅在当前终端会话有效"
