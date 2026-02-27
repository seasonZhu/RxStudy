//
//  BannerCarouselView.swift
//  RxStudy - SwiftUIApp
//
//  轮播图组件
//  基于 ACarousel
//

import SwiftUI
import Kingfisher

// MARK: - 轮播图视图

/// Banner 轮播图组件
/// 基于 ACarousel 实现，支持自动滚动、手动滑动和页码指示器
struct BannerCarouselView: View {
    let banners: [HomeBannerModel]
    @State private var currentIndex = 0

    /// 默认高度（16:9 比例）
    var height: CGFloat {
        UIScreen.main.bounds.width * (9.0 / 16.0)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 轮播图
            ACarousel(
                banners,
                id: \.id,
                index: $currentIndex,
                spacing: 0,
                headspace: 0,
                sidesScaling: 1,
                isWrap: true,
                autoScroll: .active(3.0),
                canMove: true
            ) { banner in
                BannerItemView(banner: banner)
            }
            .frame(height: height)

            // 页码指示器
            if banners.count > 1 {
                pageIndicators
                    .padding(.bottom, 8)
            }
        }
    }

    /// 页码指示器
    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<banners.count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.5))
                    .frame(width: index == currentIndex ? 7 : 6, height: index == currentIndex ? 7 : 6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        )
    }
}

// MARK: - Banner Item View

/// 单个 Banner 条目视图
private struct BannerItemView: View {
    let banner: HomeBannerModel

    var body: some View {
        Group {
            if let url = banner.url, !url.isEmpty {
                // 有 URL 的可点击 Banner
                NavigationLink(destination: URLWebViewController(url: url, title: banner.title)) {
                    bannerImage
                }
                .buttonStyle(.plain)
            } else {
                // 无 URL 的纯展示 Banner
                bannerImage
            }
        }
    }

    private var bannerImage: some View {
        KFImage(URL(string: banner.imagePath ?? ""))
            .placeholder {
                ProgressView()
            }
            .retry(maxCount: 2, interval: .seconds(1))
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

// MARK: - Array 安全下标

private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
