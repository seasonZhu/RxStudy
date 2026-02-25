//
//  TreeView.swift
//  RxStudy - SwiftUIApp
//
//  体系页面视图
//

import SwiftUI

// MARK: - 体系视图

struct TreeView: View {
    @State private var viewModel = TreeViewModel()

    var body: some View {
        contentView
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("体系")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.tags.isEmpty {
            treeListContent
        } else if viewModel.isLoading {
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 体系列表内容

    private var treeListContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.tags) { tag in
                    if let children = tag.children, !children.isEmpty {
                        // 主分类标题
                        Section(header:
                            Text(tag.name ?? "")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .background(Color(.systemGroupedBackground))
                        ) {
                            // 子分类列表
                            ForEach(children) { child in
                                NavigationLink(destination: TreeArticleListView(
                                    tagId: child.id ?? 0,
                                    tagName: child.name ?? ""
                                )) {
                                    TreeCategoryRow(name: child.name ?? "")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - 辅助视图

    private var loadingView: some View {
        ProgressView("加载中...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(viewModel.errorMessage ?? "加载失败")
                .font(.system(size: 14))
                .foregroundColor(.red)

            Button("重新加载") {
                Task {
                    await viewModel.loadTags()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - 体系分类行

struct TreeCategoryRow: View {
    let name: String

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

// MARK: - 体系文章单元格（用于文章列表页面）

struct TreeArticleCellView: View {
    let article: InfoModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题
            Text(article.title ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)

            // 作者
            if let author = article.author {
                Text(author)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // 底部信息
            HStack(spacing: 8) {
                if let chapterName = article.chapterName {
                    Text(chapterName)
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }

                Text(article.niceDate ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

// MARK: - 预览

#Preview {
    TreeView()
}
