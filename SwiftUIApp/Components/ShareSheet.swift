//
//  ShareSheet.swift
//  RxStudy - SwiftUIApp
//
//  分享功能组件
//  封装 UIActivityViewController
//

import SwiftUI
import UIKit

// MARK: - 自定义分享 Activities

/// 在 Safari 中打开
class SafariActivity: UIActivity {
    private var url: URL?

    override class var activityCategory: UIActivity.Category { .share }
    override var activityType: UIActivity.ActivityType? { ActivityType("com.lostsakura.safari") }

    override var activityTitle: String? { "Safari" }
    override var activityImage: UIImage? { UIImage(systemName: "safari") }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        // activityItems[0] 是 title，activityItems[1] 是 URL
        guard activityItems.count >= 2,
              let urlString = activityItems[1] as? String,
              let url = URL(string: urlString) else {
            return
        }
        self.url = url
    }

    override var activityViewController: UIViewController? { nil }

    override func perform() {
        if let url = self.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    override func activityDidFinish(_ completed: Bool) {}
}

/// 复制 URL
class CopyActivity: UIActivity {
    private var urlString: String?

    override class var activityCategory: UIActivity.Category { .share }
    override var activityType: UIActivity.ActivityType? { ActivityType("com.lostsakura.copy") }

    override var activityTitle: String? { "复制URL" }
    override var activityImage: UIImage? { UIImage(systemName: "doc.on.doc") }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        // activityItems[0] 是 title，activityItems[1] 是 URL
        guard activityItems.count >= 2, let urlString = activityItems[1] as? String else {
            return
        }
        self.urlString = urlString
    }

    override var activityViewController: UIViewController? { nil }

    override func perform() {
        if let urlString = urlString {
            UIPasteboard.general.string = urlString
        }
    }

    override func activityDidFinish(_ completed: Bool) {}
}

// MARK: - ShareSheet 包装器

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let excludedActivityTypes: [UIActivity.ActivityType]

    init(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType] = [.copyToPasteboard]
    ) {
        self.items = items
        self.excludedActivityTypes = excludedActivityTypes
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: [SafariActivity(), CopyActivity()]
        )
        controller.excludedActivityTypes = excludedActivityTypes

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
