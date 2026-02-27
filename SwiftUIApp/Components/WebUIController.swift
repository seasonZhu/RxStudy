//
//  WebUIController.swift
//  RxStudy - SwiftUIApp
//
//  文章详情 WebView
//  基于 WebUI 库
//

import SwiftUI
import WebUI

// MARK: - 分享配置

struct ShareConfiguration: Identifiable {
    let id = UUID()
    let items: [Any]
}

// MARK: - 文章详情 WebView（用于 InfoModel）

struct WebUIController: View {
    let article: InfoModel
    @State private var shareConfig: ShareConfiguration?

    var body: some View {
        if let link = article.link, let url = URL(string: link) {
            WebView(request: URLRequest(url: url))
                .refreshable {
                    // 下拉刷新
                }
                .navigationTitle(article.title?.swiftUIReplaceHtmlElement ?? "文章详情")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            shareConfig = ShareConfiguration(items: [article.title ?? "", link])
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(item: $shareConfig) { config in
                    ShareSheet(items: config.items)
                        .presentationDragIndicator(.visible)
                }
                .hideTabBar()
        } else {
            Text("无效的链接")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - URL WebView（用于 Banner、工具等只需要 URL 的场景）

struct URLWebViewController: View {
    let url: String
    let title: String?
    @State private var shareConfig: ShareConfiguration?

    init(url: String, title: String? = nil) {
        self.url = url
        self.title = title
    }

    var body: some View {
        if let urlString = URL(string: url) {
            WebView(request: URLRequest(url: urlString))
                .refreshable {
                    // 下拉刷新
                }
                .navigationTitle(title?.swiftUIReplaceHtmlElement ?? "网页")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if let shareTitle = title {
                                shareConfig = ShareConfiguration(items: [shareTitle, url])
                            } else {
                                shareConfig = ShareConfiguration(items: [url])
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .sheet(item: $shareConfig) { config in
                    ShareSheet(items: config.items)
                        .presentationDragIndicator(.visible)
                }
                .hideTabBar()
        } else {
            Text("无效的链接")
                .foregroundColor(.secondary)
        }
    }
}
