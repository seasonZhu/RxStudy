#!/usr/bin/env python3
"""升级 Tuist 并保留上一版；只清理 mise 确认可清理的普通安装。"""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
STABLE = re.compile(r"\d+\.\d+\.\d+\Z")
STEP = "检查环境"
OLD = None


def run(*args, capture=False, timeout=None):
    result = subprocess.run(args, cwd=ROOT, check=True, text=True,
                            stdout=subprocess.PIPE if capture else None, timeout=timeout)
    return result.stdout.strip() if capture else None


def version(value):
    if not isinstance(value, str) or not STABLE.fullmatch(value):
        raise ValueError("不是有效的 Tuist 稳定版本：%r" % value)
    return tuple(map(int, value.split(".")))


def pin(text):
    section = re.search(r"(?ms)^\[tools\]\s*\n(.*?)(?=^\[|\Z)", text)
    if not section:
        raise ValueError("mise.toml 缺少 [tools] 配置")
    matches = list(re.finditer(r'(?m)^tuist\s*=\s*[\"\'](\d+\.\d+\.\d+)[\"\']\s*(?:#.*)?$', section.group(1)))
    if len(matches) != 1:
        raise ValueError("项目必须配置唯一的精确 Tuist 稳定版本")
    match = matches[0]
    start = section.start(1) + match.start(1)
    end = section.start(1) + match.end(1)
    return match.group(1), start, end


def installed(prunable=False):
    args = ["mise", "ls", "tuist", "--json"]
    if prunable:
        args.append("--prunable")
    data = json.loads(run(*args, capture=True))
    if not isinstance(data, list):
        raise ValueError("mise 安装列表格式不受支持，停止操作")
    return data


def latest():
    # 旧 asdf 插件的 latest 可能选中 app / xcresult 产品，API 也可能限流。
    # 直接过滤官方仓库的三段数字标签，排除其他产品、RC 和 Canary。
    refs = run("git", "ls-remote", "--tags", "--refs",
               "https://github.com/tuist/tuist.git", capture=True, timeout=60)
    values = re.findall(r"(?m)refs/tags/v?(\d+\.\d+\.\d+)$", refs)
    if not values:
        raise ValueError("官方仓库未返回可用的 Tuist 稳定版本")
    return max(values, key=version)


def clean_tree():
    if run("git", "status", "--porcelain", "--untracked-files=all", capture=True):
        raise ValueError("存在未提交或未跟踪修改，请先自行保存；脚本不自动暂存或重置")


def atomic_write(path, text):
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent,
                                         prefix=".tuist-upgrade-", delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(text)
        if path.exists():
            temporary.chmod(path.stat().st_mode & 0o777)
        temporary.replace(path)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


def prune(new, previous):
    keep = {new, previous}
    floor = min(map(version, keep))
    candidates = []
    # mise 自身负责排除已登记配置所引用的版本；不使用全局 prune。
    prunable = {item["version"] for item in installed(prunable=True)}
    for item in installed():
        value = item.get("version", "")
        path = Path(item.get("install_path", ""))
        reason = None
        if not STABLE.fullmatch(value):
            reason = "非稳定版本"
        elif value in keep:
            reason = "当前版或上一版"
        elif version(value) >= floor:
            reason = "不早于保留版本"
        elif item.get("symlinked_to") or path.is_symlink() or path.parent.is_symlink():
            reason = "外部关联安装"
        elif path.name != value or path.parent.name != "tuist" or not path.is_dir():
            reason = "不是可确认的普通 mise 安装"
        elif value not in prunable or item.get("active") or item.get("source") or item.get("sources"):
            reason = "其他已登记配置引用或 mise 不允许清理"
        if reason:
            print("保留 %s：%s" % (value, reason), flush=True)
        else:
            candidates.append(value)
    print("本次清理候选：%s" % ("、".join(candidates) or "无"), flush=True)
    failed = False
    for value in candidates:
        try:
            # 清理前重新检查，避免使用过期候选。
            if value not in {item["version"] for item in installed(prunable=True)}:
                print("跳过 %s：引用状态已变化" % value, flush=True)
                continue
            run("mise", "uninstall", "tuist@" + value)
        except (subprocess.SubprocessError, ValueError, OSError) as error:
            print("清理 %s 失败，项目升级仍保留：%s" % (value, error), file=sys.stderr)
            failed = True
    return failed


def main():
    global STEP, OLD
    parser = argparse.ArgumentParser(description="检查、升级 Tuist 稳定版，并保留上一版")
    parser.add_argument("--check", action="store_true", help="只查询，不安装、清理或修改项目")
    args = parser.parse_args()
    for tool in (["git", "mise"] if args.check else ["git", "mise", "swiftgen", "open"]):
        if not shutil.which(tool):
            raise ValueError("缺少工具：%s" % tool)
    if run("git", "rev-parse", "--show-toplevel", capture=True) != str(ROOT):
        raise ValueError("脚本必须位于仓库根目录的 scripts 下")
    branch = run("git", "branch", "--show-current", capture=True)
    if not args.check and branch != "develop-tuist":
        raise ValueError("请先执行：bash scripts/switch-dependencies.sh tuist")
    config = ROOT / "mise.toml"
    original = (config.read_text() if branch == "develop-tuist" else
                run("git", "show", "develop-tuist:mise.toml", capture=True))
    OLD, start, end = pin(original)
    if args.check:
        STEP = "查询最新稳定版本"
        new = latest()
        print("项目固定版本：%s\n最新稳定版本：%s" % (OLD, new), flush=True)
        print("本机安装：%s" % "、".join(item["version"] for item in installed()), flush=True)
        return 0
    clean_tree()
    common = Path(run("git", "rev-parse", "--git-common-dir", capture=True))
    common = (ROOT / common).resolve()
    lock = common / "dependency-switch.lock"
    try:
        lock.mkdir()
    except FileExistsError:
        raise ValueError("已有切换或升级任务（或遗留锁）：%s" % lock)
    try:
        for marker in ["MERGE_HEAD", "CHERRY_PICK_HEAD", "REVERT_HEAD", "rebase-merge",
                       "rebase-apply", "sequencer", "BISECT_LOG"]:
            if Path(run("git", "rev-parse", "--git-path", marker, capture=True)).exists():
                raise ValueError("存在进行中的 Git 操作：%s" % marker)
        state_path = common / "tuist-upgrade-state.json"
        state = json.loads(state_path.read_text()) if state_path.exists() else {}
        STEP = "查询最新稳定版本"
        new = latest()
        print("项目固定版本：%s\n最新稳定版本：%s" % (OLD, new), flush=True)
        inventory = installed()
        print("本机安装：%s" % "、".join(item["version"] for item in inventory), flush=True)
        if version(new) < version(OLD):
            raise ValueError("查询版本低于项目固定版本，停止降级")
        previous = OLD
        if new == OLD:
            previous = state.get("previous") if state.get("current") == OLD else None
            if not previous:
                older = [item["version"] for item in inventory
                         if item.get("installed") and STABLE.fullmatch(item["version"])
                         and version(item["version"]) < version(OLD)]
                previous = max(older, key=version) if older else OLD
        version(previous)
        if version(previous) > version(OLD):
            raise ValueError("上一版本记录异常，停止操作")
        STEP = "安装并核验 Tuist " + new
        run("mise", "install", "tuist@" + new)
        actual = run("mise", "exec", "tuist@" + new, "--", "tuist", "version", capture=True)
        if actual != new:
            raise ValueError("CLI 实际版本不一致：%s" % actual)
        lockfile = ROOT / "Tuist/Package.resolved"
        locked = lockfile.read_bytes()
        STEP = "生成 SwiftGen 资源"
        run("bash", "scripts/swiftgen.sh")
        STEP = "用新版安装锁定依赖"
        run("mise", "exec", "tuist@" + new, "--", "tuist", "install",
            "--force-resolved-versions", "--skip-update")
        STEP = "用新版生成工程"
        run("mise", "exec", "tuist@" + new, "--", "tuist", "generate", "--no-open")
        STEP = "检查配置与锁文件"
        if lockfile.read_bytes() != locked or config.read_text() != original:
            raise ValueError("配置或依赖锁文件发生意外变化，请检查；不更新版本或清理旧版")
        clean_tree()
        STEP = "保存项目版本与上一版本记录"
        atomic_write(state_path, json.dumps({"current": new, "previous": previous}, indent=2) + "\n")
        if new != OLD:
            atomic_write(config, original[:start] + new + original[end:])
        print("项目已准备完成：%s；保留上一版：%s。请检查并提交 mise.toml。" % (new, previous), flush=True)
        STEP = "清理更早版本"
        try:
            cleanup_failed = prune(new, previous)
        except (subprocess.SubprocessError, ValueError, OSError) as error:
            print("清理失败，项目升级仍保留：%s" % error, file=sys.stderr)
            cleanup_failed = True
        STEP = "打开工程"
        run("open", "RxStudy.xcworkspace")
        return 2 if cleanup_failed else 0
    finally:
        lock.rmdir()


if __name__ == "__main__":
    os.chdir(ROOT)
    try:
        sys.exit(main())
    except (subprocess.SubprocessError, ValueError, OSError) as error:
        print("失败步骤：%s；原因：%s" % (STEP, error), file=sys.stderr)
        if OLD:
            print("旧版恢复命令（先检查并保存意外修改）：\n"
                  "mise exec tuist@%s -- tuist install --force-resolved-versions --skip-update\n"
                  "mise exec tuist@%s -- tuist generate --no-open" % (OLD, OLD), file=sys.stderr)
        sys.exit(1)
