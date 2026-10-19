#!/usr/bin/env python3
"""在临时目录构建真实 Moya/Alamofire，验证 Task 取消到 URLSession 的完整链路。"""
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
DEPENDENCIES = ("Alamofire", "Moya")


def main():
    for name in DEPENDENCIES:
        if not (ROOT / "Pods" / name).is_dir():
            raise SystemExit("缺少本地 CocoaPods 依赖：" + name)
    with tempfile.TemporaryDirectory(prefix="rxstudy-request-integration-") as directory:
        temporary = Path(directory)
        pods = temporary / "Pods"
        shutil.copytree(ROOT / "Pods/Pods.xcodeproj", pods / "Pods.xcodeproj")
        for name in DEPENDENCIES:
            shutil.copytree(ROOT / "Pods" / name, pods / name)
            for support in (ROOT / "Pods/Target Support Files").glob(name + "*"):
                target = pods / "Target Support Files" / support.name
                shutil.copytree(support, target)
                # 仅改临时副本的 iOS 自动生成头，依赖实现和应用源码保持原样。
                for header in list(target.glob("*umbrella.h")) + list(target.glob("*.pch")):
                    header.write_text(header.read_text().replace("<UIKit/UIKit.h>", "<Foundation/Foundation.h>"))
        command = ["xcodebuild", "-project", str(pods / "Pods.xcodeproj"), "-target", "Moya",
                   "-configuration", "Debug", "-sdk", "macosx", "SUPPORTED_PLATFORMS=macosx",
                   "MACOSX_DEPLOYMENT_TARGET=14.0", "ARCHS=" + platform.machine(), "CODE_SIGNING_ALLOWED=NO",
                   "SYMROOT=" + str(temporary / "Products"), "OBJROOT=" + str(temporary / "Intermediates"),
                   "CLANG_MODULE_CACHE_PATH=" + str(temporary / "ModuleCache"), "build"]
        build = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if build.returncode:
            print(build.stdout)
            raise SystemExit(build.returncode)
        compiler = ["xcrun", "swiftc", "-swift-version", "5", "-parse-as-library",
                    "-module-cache-path", str(temporary / "SwiftCache")]
        for name in DEPENDENCIES:
            framework = str(temporary / "Products/Debug" / name)
            compiler += ["-F", framework, "-framework", name, "-Xlinker", "-rpath", "-Xlinker", framework]
        sources = [ROOT / "Shared/Models/BaseModel.swift", ROOT / "SwiftUIStudy/Network/APIService.swift",
                   ROOT / "scripts/tests/async-request-integration-tests.swift"]
        executable = temporary / "integration-tests"
        subprocess.run(compiler + list(map(str, sources)) + ["-o", str(executable)], check=True)
        subprocess.run([str(executable)], check=True, timeout=30)


if __name__ == "__main__":
    main()
