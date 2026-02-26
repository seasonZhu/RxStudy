//
//  ProjectView.swift
//  RxStudy - SwiftUIApp
//
//  项目页面视图
//

import SwiftUI

// MARK: - 项目视图

struct ProjectView: View {
    @State private var viewModel = ProjectViewModel()

    var body: some View {
        contentView
            .navigationBar("项目")
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.tags.isEmpty {
            projectContentView
        } else if viewModel.isLoading {
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 项目内容视图

    private var projectContentView: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧分类导航
                categorySidebar
                    .frame(width: categoryWidth)

                // 右侧文章列表
                articleList
            }
        }
    }

    // MARK: - 分类侧边栏

    private var categoryWidth: CGFloat = 100

    private var categorySidebar: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.tags) { tag in
                    CategoryCell(
                        name: tag.name?.swiftUIReplaceHtmlElement ?? "",
                        isSelected: viewModel.selectedTag?.id == tag.id
                    ) {
                        viewModel.selectTag(tag)
                    }
                }
            }
        }
        .background(Color.systemGroupedBackground)
    }

    // MARK: - 文章列表

    private var articleList: some View {
        ZStack {
            if !viewModel.articles.isEmpty {
                articleListView
            } else if viewModel.isLoading {
                ProgressView("加载中...")
            } else {
                emptyView
            }
        }
    }

    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.articles) { article in
                    ArticleCellView(article: article)
                        .onAppear {
                            // 预加载：接近底部时加载更多
                            Task {
                                await viewModel.loadMoreIfNeeded(article)
                            }
                        }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
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

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("暂无项目")
                .font(.system(size: 17))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 分类单元格

struct CategoryCell: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(name)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)

                if isSelected {
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 3)
                }
            }
            .background(isSelected ? Color.blue : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览

#Preview {
    ProjectView()
}
