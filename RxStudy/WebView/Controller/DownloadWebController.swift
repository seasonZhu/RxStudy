//
//  DownloadWebController.swift
//  RxStudy
//
//  Created by dy on 2025/11/5.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit
import WebKit

import SVProgressHUD

class DownloadWebController: UIViewController {
    
    // 创建文档交互控制器属性
    var documentInteractionController: UIDocumentInteractionController?
    
    var webView: WKWebView!
    
    // 在viewDidLoad中添加用户脚本以捕获下载事件
    let scriptSource = """
        // 监听所有按钮点击
        document.addEventListener('click', function(event) {
            // 检查点击的元素是否是下载按钮（根据实际情况调整选择器）
            if (event.target.matches('.download-button, .download-btn, [data-download]')) {
                // 获取下载链接（根据实际情况调整）
                let downloadUrl = event.target.getAttribute('href') || event.target.getAttribute('data-download');
                if (downloadUrl) {
                    // 向原生App发送消息
                    window.webkit.messageHandlers.downloadHandler.postMessage({url: downloadUrl});
                }
            }
        }, true);
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置WebView
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        
        // 加载网页
//        if let url = URL(string: "https://pc.qq.com/detail/2/detail_2.html") {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
        
        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)

        // 添加消息处理器
        webView.configuration.userContentController.add(self, name: "downloadHandler")
        
        loadLocalHTMLFile()
    }
    
    // 调整WebView大小
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    /// 加载本地的html
    ///
    /// - Parameter fileName: 文件名称
    private func loadLocalHTMLFile() {
        // 获取本地HTML文件的URL
        if let htmlPath = Bundle.main.path(forResource: "Download", ofType: "html") {
            let htmlURL = URL(fileURLWithPath: htmlPath)
            // 加载HTML文件
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        } else {
            // 文件不存在时显示错误信息
            let errorMessage = "无法找到Download.html文件"
            let errorHTML = "<html><body><h1>错误</h1><p>\(errorMessage)</p></body></html>"
            webView.loadHTMLString(errorHTML, baseURL: nil)
            print("错误：\(errorMessage)")
        }
    }
}

extension DownloadWebController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "downloadHandler", let body = message.body as? [String: Any], let urlString = body["url"] as? String, let url = URL(string: urlString) {
            // 触发App下载任务
            // downloadFile(from: url)
        }
    }
}

extension DownloadWebController: WKNavigationDelegate, WKUIDelegate {
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 获取请求的URL
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        // 检查是否是下载链接（根据实际情况调整判断条件）
        if isDownloadableURL(url) {
            // 取消WebView的默认处理
            decisionHandler(.cancel)
            
            // 触发App下载任务
            // downloadFile(from: url)
            downloadFile(for: url)
        } else {
            // 允许WebView继续加载
            decisionHandler(.allow)
        }
    }
}

extension DownloadWebController {
    // 判断是否为可下载的URL
    private func isDownloadableURL(_ url: URL) -> Bool {
        // 根据URL的路径扩展名判断
        let downloadableExtensions = ["pdf", "doc", "docx", "xls", "xlsx", "zip", "rar", "jpg", "png", "mp4", "exe"]
        let pathExtension = url.pathExtension.lowercased()
        return downloadableExtensions.contains(pathExtension)
        
        // 也可以根据URL的特定关键词或模式判断
        // return url.absoluteString.contains("download") || url.absoluteString.contains(".pdf")
    }
}

// MARK: - 下载并保存到沙盒
extension DownloadWebController {
    // 处理文件下载
    private func downloadFile(from url: URL) {
        // 显示下载提示
        let alert = UIAlertController(title: "开始下载", message: "正在下载文件，请稍候...", preferredStyle: .alert)
        present(alert, animated: true)
        
        // 创建下载任务
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (location, response, error) in
            DispatchQueue.main.async {
                // 关闭提示
                alert.dismiss(animated: true)
                
                guard let self = self else { return }
                
                if let error = error {
                    // 下载失败
                    self.showAlert(title: "下载失败", message: error.localizedDescription)
                    return
                }
                
                guard let location = location, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    self.showAlert(title: "下载失败", message: "无法完成下载")
                    return
                }
                
                // 获取文件名称
                let suggestedFilename = response.suggestedFilename ?? url.lastPathComponent
                
                // 保存文件到本地
                self.saveDownloadedFile(at: location, filename: suggestedFilename)
            }
        }
        
        // 开始下载
        downloadTask.resume()
    }

    // 保存下载的文件
    private func saveDownloadedFile(at location: URL, filename: String) {
        do {
            // 获取Documents目录
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsDirectory.appendingPathComponent(filename)
            
            // 如果文件已存在，先删除
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // 移动文件到目标位置
            try FileManager.default.moveItem(at: location, to: destinationURL)
            
            // 显示下载成功提示
            showAlert(title: "下载成功", message: "文件已保存到: \(filename)", showOpenButton: true, filePath: destinationURL)
            
        } catch {
            showAlert(title: "保存失败", message: error.localizedDescription)
        }
    }

    // 显示提示对话框
    private func showAlert(title: String, message: String, showOpenButton: Bool = false, filePath: URL? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        
        // 如果是下载成功且显示打开按钮
        if showOpenButton, let path = filePath {
            alert.addAction(UIAlertAction(title: "打开文件", style: .default) { _ in
                // 使用系统应用打开文件
                UIApplication.shared.open(path, options: [:], completionHandler: nil)
            })
        }
        
        present(alert, animated: true)
    }
}

// MARK: - 下载并保存到文件App
extension DownloadWebController {
    // 处理文件下载
    private func downloadFile(for url: URL) {
        // 显示下载提示
        let alert = UIAlertController(title: "开始下载", message: "正在下载文件，请稍候...", preferredStyle: .alert)
        // present(alert, animated: true)
        
        SVProgressHUD.beginLoading()
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (location, response, error) in
            
            DispatchQueue.main.async {
                // 关闭提示
                // alert.dismiss(animated: true)
                
                SVProgressHUD.stopLoading()
                
                guard let self else { return }
                
                if let error = error {
                    // 下载失败
                    // self.showAlert(title: "下载失败", message: error.localizedDescription)
                    return
                }
                
                guard let location = location, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    // self.showAlert(title: "下载失败", message: "无法完成下载")
                    return
                }
                
                // 获取文件名
                let suggestedFilename = response.suggestedFilename ?? url.lastPathComponent
                
                // 保存文件并提供保存到文件应用的选项
                self.saveFileToTemporaryDirectory(at: location, filename: suggestedFilename)
            }
        }
        
        downloadTask.resume()
    }

    // 保存文件到临时目录
    private func saveFileToTemporaryDirectory(at location: URL, filename: String) {
        do {
            // 创建临时文件URL
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let temporaryFileURL = temporaryDirectory.appendingPathComponent(filename)
            
            // 如果文件已存在，先删除
            if FileManager.default.fileExists(atPath: temporaryFileURL.path) {
                try FileManager.default.removeItem(at: temporaryFileURL)
            }
            
            // 移动文件到临时目录
            try FileManager.default.moveItem(at: location, to: temporaryFileURL)
            
            // 提供保存到文件应用的选项
            self.presentSaveToFilesOption(for: temporaryFileURL, filename: filename)
            // self.saveDirectlyToFilesApp(for: temporaryFileURL, filename: filename)
        } catch {
            // 处理保存失败
            print("保存文件失败: \(error.localizedDescription)")
        }
    }
}

extension DownloadWebController: UIDocumentInteractionControllerDelegate {
    // 提供保存到文件应用的选项
    private func presentSaveToFilesOption(for fileURL: URL, filename: String) {
        // 创建文档交互控制器
        documentInteractionController = UIDocumentInteractionController(url: fileURL)
        documentInteractionController?.delegate = self
        
        // 显示操作菜单（包含保存到文件应用的选项）
        documentInteractionController?.presentOptionsMenu(from: view.bounds, in: view, animated: true)
    }

    // 实现UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }

    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return self.view.bounds
    }
}

extension DownloadWebController: UIDocumentPickerDelegate {
    // 直接保存到文件应用
    private func saveDirectlyToFilesApp(for fileURL: URL, filename: String) {
        // 检查是否可以访问文件应用
        if #available(iOS 11.0, *) {
            // 创建文档选择器，用于保存到文件应用
            let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            present(documentPicker, animated: true, completion: nil)
        } else {
            // iOS 11以下版本使用UIDocumentInteractionController
            presentSaveToFilesOption(for: fileURL, filename: filename)
        }
    }

    // 实现UIDocumentPickerDelegate（iOS 11+）
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 保存成功后的处理
        if let url = urls.first {
            print("文件已保存到: \(url.path)")
            showAlert(title: "保存成功", message: "文件已保存到文件应用")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // 用户取消了保存操作
        print("用户取消了保存操作")
    }
}
