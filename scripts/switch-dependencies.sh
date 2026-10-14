#!/bin/bash
# 在同一工作目录安全切换 CocoaPods 与 Tuist。
set -eEuo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"
usage() { echo '用法：bash scripts/switch-dependencies.sh [pods|tuist]'; }
fail() { echo "错误：$*" >&2; exit 1; }
MODE="${1:-}"
if [ "$#" -gt 1 ]; then usage; exit 2; fi
case "$MODE" in
    -h|--help) usage; exit 0 ;;
    '')
        printf '请选择依赖方案：\n1) CocoaPods（develop-pods）\n2) Tuist（develop-tuist）\n'
        read -r -p '输入 1 或 2：' MODE || exit 2
        case "$MODE" in 1) MODE=pods ;; 2) MODE=tuist ;; esac ;;
esac
case "$MODE" in
    pods) BRANCH=develop-pods; TOOL=pod ;;
    tuist) BRANCH=develop-tuist; TOOL=mise ;;
    *) usage; exit 2 ;;
esac
for tool in git swiftgen "$TOOL" open; do
    command -v "$tool" >/dev/null || fail "缺少工具：$tool，请先安装后重试。"
done
[ "$(git rev-parse --show-toplevel)" = "$ROOT" ] || fail '脚本必须位于仓库根目录的 scripts 下。'
COMMON="$(cd "$(git rev-parse --git-common-dir)" && pwd -P)"
LOCK="$COMMON/dependency-switch.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
    [ ! -d "$LOCK" ] || fail "已有切换任务或遗留锁：${LOCK}。确认没有任务运行后才可移除该锁目录。"
    fail "无法创建切换锁，请检查仓库写入权限：$COMMON"
fi
trap 'rmdir "$LOCK"' EXIT
STEP='检查仓库'
trap 'echo "失败步骤：${STEP}；当前分支：$(git branch --show-current)。修复原因后重试：bash scripts/switch-dependencies.sh $MODE" >&2' ERR
for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply sequencer BISECT_LOG; do
    [ ! -e "$(git rev-parse --git-path "$marker")" ] || fail "存在进行中的 Git 操作：$marker"
done
[ -z "$(git status --porcelain --untracked-files=all)" ] || fail '存在未提交或未跟踪修改，请先自行提交或暂存。'
git show-ref --verify --quiet "refs/heads/$BRANCH" || fail "本地分支不存在：$BRANCH"
CURRENT="$(git symbolic-ref --quiet --short HEAD)" || fail '当前处于 detached HEAD，请先切回工作分支。'
case "$CURRENT" in develop-pods|develop-tuist) ;; *) fail "当前分支 $CURRENT 不在支持范围内，请先保存工作并切到 develop-pods 或 develop-tuist。" ;; esac
if [ "$CURRENT" != "$BRANCH" ]; then
    if git worktree list --porcelain | /usr/bin/grep -Fxq "branch refs/heads/$BRANCH"; then
        fail "分支 $BRANCH 被其他 worktree 占用，请先释放该分支。"
    fi
    if [ "$CURRENT" = develop-tuist ]; then
        STEP='备份 Tuist 生成工程'
        BACKUP=''
        for artifact in RxStudy.xcodeproj RxStudy.xcworkspace; do
            [ -e "$artifact" ] || continue
            [ ! -L "$artifact" ] && [ -d "$artifact" ] || fail "生成工程不是普通目录：$artifact"
            [ -z "$(git ls-files -- "$artifact")" ] || fail "工程含被跟踪文件，停止处理：$artifact"
            git check-ignore -q "$artifact/" || fail "工程未被忽略，停止处理：$artifact"
            if [ -z "$BACKUP" ]; then
                BACKUP="$(mktemp -d "${TMPDIR:-/private/tmp}/rxstudy-tuist-projects.XXXXXX")"
                echo "生成工程备份：$BACKUP"
            fi
            # 先完整复制，成功后才移除原目录；备份保留用户工程设置。
            cp -pR "$artifact" "$BACKUP/"
            rm -r -- "$artifact"
        done
    fi
    STEP="切换到 $BRANCH"
    # 不允许 Git 隐式覆盖被忽略文件；有其他碰撞时停止并人工检查。
    git switch --no-overwrite-ignore "$BRANCH"
fi
if [ "$MODE" = tuist ]; then
    STEP='安装固定版本 Tuist'; mise install
fi
STEP='生成 SwiftGen 资源'; bash scripts/swiftgen.sh
if [ "$MODE" = pods ]; then
    STEP='安装 CocoaPods 锁定依赖'; pod install --deployment
else
    STEP='安装 Tuist 依赖'; mise exec -- tuist install
    STEP='生成 Tuist 工程'; mise exec -- tuist generate --no-open
fi
STEP='检查安装结果'
[ -z "$(git status --porcelain --untracked-files=all)" ] || fail '安装或生成产生了仓库修改，请检查 git diff 并保存后再切换。'
STEP='打开工程'; open RxStudy.xcworkspace
echo "已准备完成：${BRANCH}。业务提交需另行同步；返回另一方案时请先关闭当前 Xcode 工程。"
