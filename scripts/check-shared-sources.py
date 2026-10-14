#!/usr/bin/env python3
"""比较两个 worktree 的应用与共享源码，不比较依赖管理配置。"""
import hashlib
import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("用法: scripts/check-shared-sources.py <CocoaPods worktree> <Tuist worktree>")

roots = [Path(arg).resolve() for arg in sys.argv[1:]]
prefixes = ("RxStudy", "SwiftUIStudy", "Shared")
excluded = {".DS_Store", "Pods-RxStudy-acknowledgements.plist"}

def files(root: Path) -> dict[str, str]:
    result = {}
    for prefix in prefixes:
        for path in (root / prefix).rglob("*"):
            if (not path.is_file() or path.name in excluded
                    or set(path.parts) & {"Generated", "Derived", "xcuserdata"}
                    or any(part.endswith((".xcodeproj", ".xcworkspace", ".playground")) for part in path.parts)):
                continue
            relative = path.relative_to(root).as_posix()
            result[relative] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result

left, right = map(files, roots)
different = [path for path in sorted(left.keys() | right.keys()) if left.get(path) != right.get(path)]
for path in different:
    print(path)
print(f"不同文件: {len(different)}")
raise SystemExit(bool(different))
