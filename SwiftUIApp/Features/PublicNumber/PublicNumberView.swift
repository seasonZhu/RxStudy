//
//  PublicNumberView.swift
//  RxStudy - SwiftUIApp
//
//  公众号页面视图
//

import SwiftUI

// MARK: - 公众号视图

struct PublicNumberView: View {
    @State private var viewModel = PublicNumberViewModel()

    var body: some View {
        contentView
            .navigationBar("公众号")
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.publicNumbers.isEmpty {
            publicNumberContentView
        } else if viewModel.isLoading {
            loadingView
        } else {
            errorView
        }
    }

    // MARK: - 公众号内容视图

    private var publicNumberContentView: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧公众号列表
                publicNumberSidebar
                    .frame(width: sidebarWidth)

                // 右侧文章列表
                articleList
            }
        }
    }

    // MARK: - 公众号侧边栏

    private var sidebarWidth: CGFloat = 120

    private var publicNumberSidebar: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.publicNumbers) { number in
                    PublicNumberCell(
                        name: number.name?.replaceHtmlElement ?? "",
                        isSelected: viewModel.selectedPublicNumber?.id == number.id
                    ) {
                        viewModel.selectPublicNumber(number)
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
                    NavigationLink(destination: WebUIController(article: article)) {
                        ArticleCellView(article: article)
                    }
                    .buttonStyle(.plain)
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
                    await viewModel.loadPublicNumbers()
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

            Text("暂无文章")
                .font(.system(size: 17))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 公众号单元格

struct PublicNumberCell: View {
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
    PublicNumberView()
}
