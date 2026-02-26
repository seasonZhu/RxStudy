//
//  HotKeyView.swift
//  RxStudy - SwiftUIApp
//
//  搜索热词页面
//

import SwiftUI

// MARK: - 搜索热词视图

struct HotKeyView: View {
    @State private var viewModel = HotKeyViewModel()
    @State private var searchText = ""
    @State private var searchKeyword: String?

    var body: some View {
        contentView
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.hotKeys.isEmpty {
                    viewModel.loadHotKeys()
                }
            }
            .background(
                NavigationLink(
                    destination: SearchResultView(keyword: searchKeyword ?? ""),
                    isActive: Binding(
                        get: { searchKeyword != nil },
                        set: { if !$0 { searchKeyword = nil } }
                    ),
                    label: { EmptyView() }
                )
                .hidden()
            )
    }

    // MARK: - 搜索框组件

    struct SearchBar: View {
        @Binding var text: String
        @FocusState private var isFocused: Bool
        var onSearch: () -> Void = {}

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))

                TextField("搜索", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        isFocused = false
                        onSearch()
                    }

                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isFocused = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - 内容视图

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            // 搜索框
            SearchBar(
                text: $searchText,
                onSearch: {
                    if !searchText.isEmpty {
                        searchKeyword = searchText
                    }
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color(.systemGroupedBackground))

            // 内容区域
            Group {
                if !viewModel.hotKeys.isEmpty {
                    hotKeyContentView
                } else if viewModel.isLoading {
                    loadingView
                } else {
                    // 没有数据且不在加载中，显示空状态或错误
                    if let error = viewModel.errorMessage {
                        errorView(error)
                    } else {
                        // 默认显示加载
                        loadingView
                    }
                }
            }
        }
    }

    // MARK: - 热词内容视图

    private var hotKeyContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 热词标签
                Text("热门搜索")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                // 流式标签布局
                FlowLayout(spacing: 10) {
                    ForEach(viewModel.hotKeys, id: \.id) { hotKey in
                        if let name = hotKey.name {
                            NavigationLink(destination: SearchResultView(keyword: name)) {
                                HotKeyTagView(name: name)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // 调试信息
                Text("共 \(viewModel.hotKeys.count) 个热词")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground)
        )
    }

    // MARK: - 辅助视图

    private var loadingView: some View {
        ProgressView("加载中...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.red)

            Button("重新加载") {
                viewModel.loadHotKeys()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - 热词标签视图

struct HotKeyTagView: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.system(size: 15))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.systemBlue)
            .cornerRadius(4)
    }
}

// MARK: - 流式布局

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // 换行
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
            self.positions = positions
        }
    }
}

// MARK: - 预览

#Preview {
    HotKeyView()
}
