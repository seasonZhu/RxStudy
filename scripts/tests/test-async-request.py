#!/usr/bin/env python3
"""通过可控 Moya 句柄验证真实 async 请求桥接的取消竞态。"""
from pathlib import Path
import runpy
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
TRANSPORT = runpy.run_path(str(ROOT / "scripts/tests/test-account-session.py"))["MOYA_TRANSPORT"]


def main():
    with tempfile.TemporaryDirectory(prefix="rxstudy-async-request-") as directory:
        temporary = Path(directory)
        stub = temporary / "Moya.swift"
        stub.write_text(TRANSPORT)
        compiler = ["xcrun", "swiftc", "-swift-version", "5", "-module-cache-path", str(temporary / "ModuleCache")]
        subprocess.run(compiler + ["-emit-library", "-emit-module", "-module-name", "Moya", str(stub),
                       "-emit-module-path", str(temporary / "Moya.swiftmodule"),
                       "-o", str(temporary / "libMoya.dylib")], check=True)
        sources = [ROOT / "Shared/Models/BaseModel.swift", ROOT / "SwiftUIStudy/Network/APIService.swift",
                   ROOT / "scripts/tests/async-request-tests.swift"]
        executable = temporary / "async-request-tests"
        subprocess.run(compiler + ["-parse-as-library", "-I", str(temporary), "-L", str(temporary), "-lMoya",
                       "-Xlinker", "-rpath", "-Xlinker", str(temporary)] + list(map(str, sources)) +
                       ["-o", str(executable)], check=True)
        subprocess.run([str(executable)], check=True, timeout=45)


if __name__ == "__main__":
    main()
