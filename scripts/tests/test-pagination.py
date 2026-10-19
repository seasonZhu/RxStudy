#!/usr/bin/env python3
"""编译真实分页状态和七个 ViewModel，通过可控请求验证并发与页面差异。"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCES = [
    "Shared/Models/Page.swift", "Shared/Models/Banner.swift", "Shared/Models/WebLoadInfo.swift",
    "SwiftUIStudy/Models/CommonModels.swift", "SwiftUIStudy/Models/CoinCollectModels.swift",
    "SwiftUIStudy/Models/PaginationState.swift", "SwiftUIStudy/Network/CategoryAPIProtocol.swift",
    "SwiftUIStudy/Features/Home/HomeViewModel.swift", "SwiftUIStudy/Features/Coin/CoinViewModel.swift",
    "SwiftUIStudy/Features/Collect/CollectViewModel.swift", "SwiftUIStudy/Features/CoinRankList/CoinRankListViewModel.swift",
    "SwiftUIStudy/Features/Tree/TreeArticleListViewModel.swift", "SwiftUIStudy/Features/Search/SearchResultViewModel.swift",
    "SwiftUIStudy/Features/Category/CategoryPageViewModel.swift", "scripts/tests/pagination-tests.swift",
]


def main():
    with tempfile.TemporaryDirectory(prefix="rxstudy-pagination-") as directory:
        temporary = Path(directory)
        executable = temporary / "pagination-tests"
        subprocess.run(["xcrun", "swiftc", "-swift-version", "5", "-parse-as-library",
                        "-module-cache-path", str(temporary / "ModuleCache")] +
                       [str(ROOT / path) for path in SOURCES] + ["-o", str(executable)], check=True)
        subprocess.run([str(executable)], check=True, timeout=45)


if __name__ == "__main__":
    main()
