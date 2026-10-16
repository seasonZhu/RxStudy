#!/usr/bin/env python3
"""用真实 CocoaPods 依赖运行 macOS 隔离日志测试，不启动模拟器。"""
from pathlib import Path
import os
import platform
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
DEPENDENCIES = ("CocoaLumberjack", "Alamofire", "SSZipArchive")
LEGACY_SOURCES = (
    "RxStudy/Extension/AlamofireNetworkActivityLogger/NetworkActivityLogger.swift",
    "RxStudy/Extension/AppDelegate+Extension/AppDelegate+LogConfig.swift",
    "RxStudy/Log/CustomLogFormatter.swift",
    "scripts/tests/rxstudy-logging-tests.swift",
)



def main():
    for name in DEPENDENCIES:
        if not (ROOT / "Pods" / name).is_dir():
            raise SystemExit("缺少本地依赖，请先准备 CocoaPods 工作区：" + name)
    # 仅在临时副本中把 CocoaPods 的 iOS umbrella/prefix 头改为 Foundation。
    # 应用源码与依赖实现均保持原样，测试目录不会进入 App Target。
    with tempfile.TemporaryDirectory(prefix="rxstudy-log-check-") as workspace:
        temporary = Path(workspace)
        pods = temporary / "Pods"
        shutil.copytree(ROOT / "Pods/Pods.xcodeproj", pods / "Pods.xcodeproj")
        for name in DEPENDENCIES:
            shutil.copytree(ROOT / "Pods" / name, pods / name)
            for support in (ROOT / "Pods/Target Support Files").glob(name + "*"):
                target = pods / "Target Support Files" / support.name
                shutil.copytree(support, target)
                for header in list(target.glob("*umbrella.h")) + list(target.glob("*.pch")):
                    header.write_text(header.read_text().replace("<UIKit/UIKit.h>", "<Foundation/Foundation.h>"))
        build = ["xcodebuild", "-project", str(pods / "Pods.xcodeproj")]
        for name in DEPENDENCIES:
            build += ["-target", name]
        build += [
            "-configuration", "Debug", "-sdk", "macosx", "SUPPORTED_PLATFORMS=macosx",
            "ARCHS=" + platform.machine(), "MACOSX_DEPLOYMENT_TARGET=13.0", "CODE_SIGNING_ALLOWED=NO",
            "SYMROOT=" + str(temporary / "Products"),
            "OBJROOT=" + str(temporary / "Intermediates"),
            "CLANG_MODULE_CACHE_PATH=" + str(temporary / "ModuleCache"), "build",
        ]
        result = subprocess.run(build, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if result.returncode:
            print(result.stdout)
            raise SystemExit(result.returncode)
        compile_args = ["xcrun", "swiftc", "-swift-version", "5", "-module-cache-path", str(temporary / "SwiftCache")]
        for name in DEPENDENCIES:
            directory = str(temporary / "Products/Debug" / name)
            compile_args += ["-F", directory, "-framework", name, "-Xlinker", "-rpath", "-Xlinker", directory]
        # 仅测试副本重定向旧管理器的 Documents，避免写入用户真实目录。
        legacy_manager = temporary / "CustomLogFileManager.swift"
        original = (ROOT / "RxStudy/Log/CustomLogFileManager.swift").read_text()
        legacy_manager.write_text(original.replace("let documentsDirectory = paths[0]",
            'let documentsDirectory = ProcessInfo.processInfo.environment["RXSTUDY_LEGACY_TEST_DIRECTORY"]!'))
        # 使用旧启动函数原文，仅剥离与测试无关的 UIKit 配置。
        app_config = (ROOT / "RxStudy/Extension/AppDelegate+Extension/AppDelegate+AppConfig.swift").read_text()
        method = app_config[app_config.index("    private func setupNetworkActivityLogger() {"):].rsplit("\n}", 1)[0]
        bootstrap = temporary / "LegacyNetworkBootstrap.swift"
        bootstrap.write_text("import Foundation\nextension AppDelegate {\n" + method
            + "\nfunc testSetupLegacyNetwork() { setupNetworkActivityLogger() }\n}\n")
        modern_sources = sorted((ROOT / "RxStudy/Log/Modern").glob("*.swift"))
        config = ROOT / "RxStudy/Log/Modern/LoggingConfiguration.swift"
        assert "static let mode: LoggingMode = .legacy" in config.read_text(), "默认必须保持旧体系"
        for mode, redact in (("legacy", False), ("modern", False), ("modern", True)):
            selected_config = temporary / (mode + "-LoggingConfiguration.swift")
            selected_config.write_text(config.read_text().replace("= .legacy", "= ." + mode)
                .replace("redactionEnabled = false", "redactionEnabled = " + str(redact).lower()))
            sources = [str(path) for path in modern_sources if path != config]
            sources += [str(selected_config), str(legacy_manager), str(bootstrap)]
            sources += [str(ROOT / source) for source in LEGACY_SOURCES]
            for configuration in ("Debug", "Release"):
                executable = temporary / (mode + "-LogTests-" + configuration)
                args = compile_args + (["-D", "DEBUG"] if configuration == "Debug" else [])
                subprocess.run(args + sources + ["-o", str(executable)], check=True)
                environment = dict(os.environ, RXSTUDY_LEGACY_TEST_DIRECTORY=str(temporary / mode / configuration))
                result = subprocess.run([str(executable)], env=environment, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                print(mode, configuration, "脱敏=" + str(redact), flush=True)
                print(result.stdout, flush=True)
                if result.returncode:
                    raise SystemExit(result.returncode)
                if mode == "legacy":
                    assert ("Body:\n" in result.stdout) == (configuration == "Debug"), "旧网络 DEBUG/Release 启动行为改变"
                else:
                    if configuration == "Debug":
                        assert "Body:\n" in result.stdout and "Headers:\n" in result.stdout, "Modern 控制台缺少正文或请求头"
                        assert "request-marker" in result.stdout and "response-marker" in result.stdout, "Modern 控制台缺少请求或响应"
                        assert ("request-secret" in result.stdout) != redact, "控制台脱敏开关未生效"
                        assert "[网络][请求详情]" in result.stdout, "Modern 控制台缺少请求详情"
                    else:
                        assert "Body:\n" not in result.stdout, "Release 不应输出控制台正文"



if __name__ == "__main__":
    main()
