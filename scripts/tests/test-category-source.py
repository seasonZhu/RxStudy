#!/usr/bin/env python3
"""在临时目录编译真实分类协议、模型和 ViewModel，无需网络或模拟器。"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCES = [
    ROOT / "Shared/Models/Page.swift",
    ROOT / "SwiftUIStudy/Models/PaginationState.swift",
    ROOT / "SwiftUIStudy/Models/CommonModels.swift",
    ROOT / "SwiftUIStudy/Network/CategoryAPIProtocol.swift",
    ROOT / "SwiftUIStudy/Features/Category/CategoryPageViewModel.swift",
    ROOT / "scripts/tests/category-source-tests.swift",
]


def main():
    with tempfile.TemporaryDirectory(prefix="rxstudy-category-") as directory:
        temporary = Path(directory)
        compiler = ["xcrun", "swiftc", "-swift-version", "5", "-parse-as-library",
                    "-module-cache-path", str(temporary / "ModuleCache")]
        executable = temporary / "category-tests"
        subprocess.run(compiler + list(map(str, SOURCES)) + ["-o", str(executable)], check=True)
        subprocess.run([str(executable)], check=True, timeout=30)
        # 错误模型组合必须被编译器拒绝，不能推迟到运行时。
        invalid = temporary / "InvalidCategory.swift"
        invalid.write_text("""
func invalidCategory(source: ProjectAPIService) async throws {
    let _: [PublicNumberTagModel] = try await source.fetchCategories()
}
""")
        result = subprocess.run(compiler + ["-typecheck"] + list(map(str, SOURCES)) + [str(invalid)],
                                text=True, capture_output=True)
        if result.returncode == 0 or "PublicNumberTagModel" not in result.stderr or "ProjectTagModel" not in result.stderr:
            raise AssertionError("错误分类模型未按预期被编译器拒绝：" + result.stderr)
        print("编译期负向测试通过：项目来源不能返回公众号模型")


if __name__ == "__main__":
    main()
