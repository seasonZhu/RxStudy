//
//  HomeView.swift
//  RxStudy - SwiftUIApp
//
//  首页视图
//  使用 @Observable + @State
//

import SwiftUI
import Kingfisher

// MARK: - 首页视图

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            contentView

            // 加载指示器
            if viewModel.isLoading && viewModel.articles.isEmpty {
                VStack {
                    Spacer()
                    ProgressView()
                    Text("加载中...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .navigationBar("首页") {} trailing: {
            NavigationLink(destination: HotKeyView()) {
                Image(systemName: "magnifyingglass")
            }
        }
        .task {
            // 首次加载数据
            if viewModel.articles.isEmpty {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        if !viewModel.articles.isEmpty {
            articleListView
        } else if !viewModel.isLoading {
            emptyView
        } else {
            EmptyView()
        }
    }

    // MARK: - 文章列表

    private var articleListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Banner 轮播
                if !viewModel.banners.isEmpty {
                    BannerCarouselView(banners: viewModel.banners)
                }

                // 文章列表
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

                // 加载更多指示器
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

    // MARK: - 空状态视图

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("暂无内容")
                .font(.system(size: 17, weight: .medium))

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button("重新加载") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - 文章单元格

struct ArticleCellView: View {
    let article: InfoModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                // 标签
                if article.top == true {
                    Text("置顶")
                        .font(.system(size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }

                // 作者
                if let author = article.author, !author.isEmpty {
                    Text(author)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else if let shareUser = article.shareUser, !shareUser.isEmpty {
                    Text(shareUser)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                // 标题
                Text((article.title ?? "无标题").replaceHtmlElement)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                // 描述
                if let desc = article.desc, !desc.isEmpty {
                    Text(desc.replaceHtmlElement)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // 底部信息
                HStack(spacing: 8) {
                    if let chapterName = article.chapterName {
                        Text(chapterName.replaceHtmlElement)
                            .font(.system(size: 11))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }

                    Text(article.niceDate ?? "")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 缩略图
            if let envelopePic = article.envelopePic, !envelopePic.isEmpty {
                KFImage(URL(string: envelopePic))
                    .placeholder {
                        ProgressView()
                            .frame(width: 80, height: 60)
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 60)
                    .cornerRadius(6)
            }
        }
        .padding(16)
        .background(Color.systemBackground)
    }
}

// MARK: - 预览

#Preview {
    HomeView()
}
