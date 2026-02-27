//
//  TreeView.swift
//  RxStudy - SwiftUIApp
//
//  体系页面视图
//

import SwiftUI

// MARK: - 视图模式

enum TreeViewMode: String {
    case list = "列表"
    case flow = "网格"

    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .flow: return "square.grid.2x2"
        }
    }
}

// MARK: - 体系视图

struct TreeView: View {
    @State private var viewModel = TreeViewModel()
    @State private var viewMode: TreeViewMode = .list

    var body: some View {
        contentView
        .navigationBar("体系") {} trailing: {
            NavigationLink(destination: HotKeyView()) {
                Button {
                    withAnimation {
                        viewMode = viewMode == .list ? .flow : .list
                    }
                  } label: {
                      Image(systemName: viewMode.icon)
                  }
            }
        }
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
                                .background(Color.systemGroupedBackground)
                        ) {
                            // 子分类 - 根据视图模式切换
                            switch viewMode {
                            case .list:
                                listView(children: children)
                            case .flow:
                                flowView(children: children)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.systemGroupedBackground)
    }

    // MARK: - 列表视图

    private func listView(children: [TreeChildTagModel]) -> some View {
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

    // MARK: - FlowLayout 视图

    private func flowView(children: [TreeChildTagModel]) -> some View {
        FlowLayout(spacing: 10) {
            ForEach(children) { child in
                NavigationLink(destination: TreeArticleListView(
                    tagId: child.id ?? 0,
                    tagName: child.name ?? ""
                )) {
                    TreeCategoryChip(name: child.name ?? "")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
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

// MARK: - 体系分类行（列表样式）

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
        .background(Color.systemBackground)
    }
}

// MARK: - 体系分类标签（FlowLayout 样式）

struct TreeCategoryChip: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.system(size: 14))
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.systemBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(uiColor: UIColor.systemGray4), lineWidth: 1)
            )
    }
}

// MARK: - 预览

#Preview {
    TreeView()
}
