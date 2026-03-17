//
//  WebUIController.swift
//  RxStudy - SwiftUIApp
//
//  文章详情 WebView
//  使用原生 WKWebView
//

import SwiftUI
import ProgressHUD
import WebKit

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
            NativeWebView(
                url: url,
                title: article.title?.replaceHtmlElement ?? "文章详情",
                showShare: true,
                shareItems: [article.title ?? "", link]
            )
            .navigationTitle(article.title?.replaceHtmlElement ?? "文章详情")
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
        if let url = URL(string: url) {
            NativeWebView(
                url: url,
                title: title?.replaceHtmlElement ?? "网页",
                showShare: true,
                shareItems: title != nil ? [title!, url] : [url]
            )
            .navigationTitle(title?.replaceHtmlElement ?? "网页")
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

// MARK: - 原生 WKWebView 封装

struct NativeWebView: UIViewRepresentable {
    let url: URL
    let title: String?
    let showShare: Bool
    let shareItems: [Any]

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // 允许 JavaScript 打开新窗口
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: NativeWebView

        init(_ parent: NativeWebView) {
            self.parent = parent
        }

        // MARK: - WKNavigationDelegate

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // 判断是否为外部链接（不同域名）
            if let host = url.host, let currentHost = webView.url?.host {
                if host != currentHost && !url.absoluteString.hasPrefix("javascript") {
                    if url.scheme == "http" || url.scheme == "https" {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        decisionHandler(.cancel)
                        return
                    }
                }
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // 处理 target="_blank" 的情况
            if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            ProgressHUD.animate()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            ProgressHUD.dismiss()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            ProgressHUD.dismiss()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            ProgressHUD.dismiss()
        }

        // MARK: - WKUIDelegate

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            completionHandler()
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
        }

        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String?, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            completionHandler(defaultText)
        }
    }
}
