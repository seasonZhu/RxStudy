#!/bin/bash
# 本机 Flutter 接入开关；卸载只解除 iOS 集成，保留模块源码与缓存。
set -eEuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT"
usage() { echo '用法：bash scripts/switch-flutter.sh [enable|disable|status]'; }
fail() { echo "错误：$*" >&2; exit 1; }
MODE="${1:-}"
[ "$#" -le 1 ] || { usage; exit 2; }
case "$MODE" in
    -h|--help) usage; exit 0 ;;
    '')
        printf '请选择 Flutter 操作：\n1) 接入\n2) 卸载（保留源码与缓存）\n3) 查看状态\n'
        read -r -p '输入 1、2 或 3：' MODE || exit 2
        case "$MODE" in 1) MODE=enable ;; 2) MODE=disable ;; 3) MODE=status ;; esac ;;
esac
case "$MODE" in enable|disable|status) ;; *) usage; exit 2 ;; esac
FLAG="$ROOT/.flutter-enabled"
PROJECT="$ROOT/RxStudy.xcodeproj/project.pbxproj"
[ ! -L "$FLAG" ] && { [ ! -e "$FLAG" ] || [ -f "$FLAG" ]; } || fail '开关必须是普通文件。'
[ -f Podfile ] && [ -f "$PROJECT" ] || fail '缺少 CocoaPods 的 Podfile 或 RxStudy.xcodeproj，请在 CocoaPods 工程中使用。'

if [ "$MODE" = status ]; then
    EXPECTED=0
    if [ -f "$FLAG" ]; then EXPECTED=1; echo '本机开关：已启用'; else echo '本机开关：已关闭（默认）'; fi
    if command -v flutter >/dev/null 2>&1; then
        FLUTTER_BIN="$(command -v flutter)"
        echo "Flutter 命令：$FLUTTER_BIN"
        # 读取 SDK 元数据，不启动 Flutter，避免状态查询更新缓存。
        if command -v ruby >/dev/null 2>&1; then
            ruby -rjson -e 'path = File.join(File.dirname(File.realpath(ARGV[0])), "cache", "flutter.version.json"); if File.file?(path); v = JSON.parse(File.read(path)); puts "Flutter SDK：#{v["frameworkVersion"]} / Dart #{v["dartSdkVersion"]}"; else; puts "Flutter SDK：未找到版本缓存"; end' "$FLUTTER_BIN"
        fi
    else
        echo 'Flutter SDK：未发现命令（关闭状态不需要安装）'
    fi
    CONSISTENT=1
    if [ "$EXPECTED" = 1 ]; then
        for file in podhelper.rb Generated.xcconfig flutter_export_environment.sh; do
            if [ ! -f "flutter_module/.ios/Flutter/$file" ]; then
                echo "Flutter 生成配置缺失：$file"
                CONSISTENT=0
            fi
        done
    fi
    for manifest in Podfile.lock Pods/Manifest.lock; do
        INSTALLED=0
        if [ ! -f "$manifest" ]; then
            echo "${manifest}：不存在，需运行 pod install"
            CONSISTENT=0
            continue
        fi
        if grep -Eq '^  - FlutterPluginRegistrant([ /(:]|$)' "$manifest"; then INSTALLED=1; fi
        echo "${manifest}：Flutter 集成=$INSTALLED"
        [ "$INSTALLED" = "$EXPECTED" ] || CONSISTENT=0
        ENGINE=0
        if grep -Eq '^  - Flutter([ /(:]|$)' "$manifest"; then ENGINE=1; fi
        [ "$ENGINE" = "$EXPECTED" ] || CONSISTENT=0
    done
    PHASES=0
    if grep -q 'Run Flutter Build' "$PROJECT" && grep -q 'Embed Flutter Build' "$PROJECT"; then PHASES=1; fi
    echo "工程 Flutter 构建阶段：$PHASES"
    [ "$PHASES" = "$EXPECTED" ] || CONSISTENT=0
    if [ "$EXPECTED" = 0 ] && grep -q 'Flutter Build' "$PROJECT"; then CONSISTENT=0; fi
    if ! cmp -s Podfile.lock Pods/Manifest.lock; then CONSISTENT=0; fi
    if [ "$CONSISTENT" = 0 ]; then
        REPAIR=disable; [ "$EXPECTED" = 0 ] || REPAIR=enable
        echo "配置与安装结果不一致，请运行：bash scripts/switch-flutter.sh $REPAIR"
        exit 1
    fi
    echo '配置与安装结果一致。'
    exit 0
fi

for tool in git pod ruby xcodebuild; do command -v "$tool" >/dev/null 2>&1 || fail "缺少工具：$tool"; done
[ "$(git rev-parse --show-toplevel)" = "$ROOT" ] || fail '脚本必须位于仓库根目录的 scripts 下。'
COMMON="$(cd "$(git rev-parse --git-common-dir)" && pwd -P)"
LOCK="$COMMON/dependency-switch.lock"
mkdir "$LOCK" 2>/dev/null || fail "已有依赖切换任务或遗留锁：${LOCK}。确认没有任务运行后才可移除该锁目录。"
STEP='检查环境'
SUCCESS=0
FLAG_CHANGED=0
LOG=''
WAS_ENABLED=0
[ ! -f "$FLAG" ] || WAS_ENABLED=1
finish() {
    RESULT=$?
    trap - EXIT
    if [ "$SUCCESS" = 0 ]; then
        if [ "$FLAG_CHANGED" = 1 ]; then
            if [ "$WAS_ENABLED" = 1 ]; then touch "$FLAG"; else rm -f "$FLAG"; fi
        fi
        echo "失败步骤：${STEP}；已保留原开关状态。" >&2
        echo 'Pods 与工程可能已部分改变，请检查日志，修复原因后重新执行原命令；这不是完整回滚。' >&2
        [ -z "$LOG" ] || echo "安装日志：$LOG" >&2
    fi
    rmdir "$LOCK"
    exit "$RESULT"
}
trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply sequencer BISECT_LOG; do
    [ ! -e "$(git rev-parse --git-path "$marker")" ] || fail "存在进行中的 Git 操作：$marker"
done
xcodebuild -version >/dev/null
if [ "$MODE" = enable ]; then
    command -v flutter >/dev/null 2>&1 || fail '缺少工具：flutter'
    [ -f flutter_module/pubspec.yaml ] || fail '缺少 flutter_module/pubspec.yaml。'
fi
LOG="$(mktemp "${TMPDIR:-/private/tmp}/rxstudy-flutter-${MODE}.XXXXXX")"
echo "安装日志：$LOG"
if [ "$MODE" = enable ]; then
    STEP='准备 Flutter iOS 引擎缓存'
    (cd flutter_module && flutter precache --ios) 2>&1 | tee -a "$LOG"
    STEP='解析 Flutter 依赖与生成 iOS 配置'
    (cd flutter_module && flutter pub get) 2>&1 | tee -a "$LOG"
    for file in podhelper.rb Generated.xcconfig flutter_export_environment.sh; do
        [ -f "flutter_module/.ios/Flutter/$file" ] || fail "未生成 Flutter 配置：$file"
    done
    FLAG_CHANGED=1
    touch "$FLAG"
else
    FLAG_CHANGED=1
    rm -f "$FLAG"
fi
STEP='安装 CocoaPods 依赖'
pod install 2>&1 | tee -a "$LOG"
if [ "$MODE" = disable ]; then
    # 旧产物会使 canImport(Flutter) 继续成立，必须通过 Xcode 清理构建产物。
    STEP='清理 Xcode 中残留的 Flutter 构建产物'
    CLEAN_ARGS=(clean -workspace RxStudy.xcworkspace -scheme RxStudy -configuration Debug -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO)
    if [ -n "${RXSTUDY_DERIVED_DATA_PATH:-}" ]; then
        CLEAN_ARGS+=(-derivedDataPath "$RXSTUDY_DERIVED_DATA_PATH")
    fi
    xcodebuild "${CLEAN_ARGS[@]}" 2>&1 | tee -a "$LOG"
fi
STEP='检查安装结果'
bash "$ROOT/scripts/switch-flutter.sh" status 2>&1 | tee -a "$LOG"
SUCCESS=1
echo "Flutter 操作完成：${MODE}。请使用 RxStudy.xcworkspace；模块源码与配置缓存已保留。"
