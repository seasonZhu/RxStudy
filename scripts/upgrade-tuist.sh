#!/bin/bash
# 独立检查和升级 Tuist，日常切换仍使用项目固定版本。
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
exec python3 "$ROOT/scripts/upgrade-tuist.py" "$@"
