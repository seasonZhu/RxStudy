//
//  ArticleCellView.swift
//  RxStudy - SwiftUIApp
//
//  文章单元格组件
//  用于展示文章标题、作者、描述、分类等信息
//

import SwiftUI
import Kingfisher

// MARK: - 文章单元格

struct ArticleCellView: View {
    let article: InfoModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 左侧内容区域
            VStack(alignment: .leading, spacing: 6) {
                // 标签行
                tagRow

                // 作者
                authorRow

                // 标题
                titleRow

                // 描述
                if let desc = article.desc, !desc.isEmpty {
                    descRow(desc: desc)
                }

                // 底部信息
                bottomInfoRow
            }

            Spacer()

            // 右侧缩略图
            if let envelopePic = article.envelopePic, !envelopePic.isEmpty {
                thumbnailView(envelopePic: envelopePic)
            }
        }
        .padding(16)
        .background(Color.systemBackground)
    }

    // MARK: - 标签行

    @ViewBuilder
    private var tagRow: some View {
        if article.top == true {
            TagView(text: "置顶", style: .top)
        }
    }

    // MARK: - 作者行

    @ViewBuilder
    private var authorRow: some View {
        if let author = article.author, !author.isEmpty {
            Text(author)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        } else if let shareUser = article.shareUser, !shareUser.isEmpty {
            Text(shareUser)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 标题行

    private var titleRow: some View {
        Text((article.title ?? "无标题").replaceHtmlElement)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.primary)
            .lineLimit(2)
    }

    // MARK: - 描述行

    private func descRow(desc: String) -> some View {
        Text(desc.replaceHtmlElement)
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .lineLimit(2)
    }

    // MARK: - 底部信息行

    private var bottomInfoRow: some View {
        HStack(spacing: 8) {
            if let chapterName = article.chapterName {
                TagView(text: chapterName.replaceHtmlElement, style: .category)
            }

            Text(article.niceDate ?? "")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 缩略图

    private func thumbnailView(envelopePic: String) -> some View {
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

// MARK: - 标签样式

enum TagStyle {
    case top        // 置顶标签（红色）
    case category   // 分类标签（蓝色）
    case custom(Color, Color) // 自定义颜色

    var backgroundColor: Color {
        switch self {
        case .top:
            return Color.red.opacity(0.1)
        case .category:
            return Color.blue.opacity(0.1)
        case .custom(let bg, _):
            return bg
        }
    }

    var foregroundColor: Color {
        switch self {
        case .top:
            return .red
        case .category:
            return .blue
        case .custom(_, let fg):
            return fg
        }
    }
}

// MARK: - 标签组件

struct TagView: View {
    let text: String
    var style: TagStyle = .category

    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(4)
    }
}
