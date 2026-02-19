#!/bin/bash

# 检查代理状态脚本
# 使用方法: ./check-proxy.sh

echo "🔍 检查当前代理状态..."
echo ""

# 检查Git代理配置
echo "📦 Git代理配置:"
GIT_HTTP_PROXY=$(git config --global http.proxy)
GIT_HTTPS_PROXY=$(git config --global https.proxy)

if [ -n "$GIT_HTTP_PROXY" ]; then
    echo "  ✅ Git HTTP代理:  ${GIT_HTTP_PROXY}"
else
    echo "  ❌ Git HTTP代理:  未设置"
fi

if [ -n "$GIT_HTTPS_PROXY" ]; then
    echo "  ✅ Git HTTPS代理: ${GIT_HTTPS_PROXY}"
else
    echo "  ❌ Git HTTPS代理: 未设置"
fi

echo ""
echo "🌐 环境变量代理:"

# 检查环境变量
[ -n "$http_proxy" ] && echo "  http_proxy=${http_proxy}" || echo "  http_proxy=未设置"
[ -n "$https_proxy" ] && echo "  https_proxy=${https_proxy}" || echo "  https_proxy=未设置"
[ -n "$HTTP_PROXY" ] && echo "  HTTP_PROXY=${HTTP_PROXY}" || echo "  HTTP_PROXY=未设置"
[ -n "$HTTPS_PROXY" ] && echo "  HTTPS_PROXY=${HTTPS_PROXY}" || echo "  HTTPS_PROXY=未设置"
[ -n "$all_proxy" ] && echo "  all_proxy=${all_proxy}" || echo "  all_proxy=未设置"
[ -n "$NO_PROXY" ] && echo "  NO_PROXY=${NO_PROXY}" || echo "  NO_PROXY=未设置"

echo ""
echo "🧪 测试连接..."

# 测试GitHub连接
if curl -s -I --connect-timeout 5 https://github.com > /dev/null 2>&1; then
    echo "  ✅ GitHub连接: 正常"
else
    echo "  ❌ GitHub连接: 失败（可能需要代理）"
fi

# 测试代理连接
if curl -s -I --connect-timeout 5 --proxy http://127.0.0.1:7890 https://www.google.com > /dev/null 2>&1; then
    echo "  ✅ 代理(127.0.0.1:7890): 正常"
else
    echo "  ❌ 代理(127.0.0.1:7890): 无响应"
fi

echo ""
echo "💡 提示："
echo "  设置代理: ./set-proxy.sh [端口号]"
echo "  取消代理: ./unset-proxy.sh"
