//
//  HorizontalCategoryPicker.swift
//  RxStudy - SwiftUIApp
//
//  横向分类选择器组件
//  支持与 TabView 双向绑定，自动滚动到选中项
//

import SwiftUI

struct HorizontalCategoryPicker<Item: Identifiable & Hashable, ID: Hashable>: View {
    let items: [Item]
    @Binding var selectedIndex: Int
    let idPath: KeyPath<Item, ID?>
    let namePath: KeyPath<Item, String?>
    let onSelect: ((Item, Int) -> Void)?

    init(
        items: [Item],
        selectedIndex: Binding<Int>,
        idPath: KeyPath<Item, ID?>,
        namePath: KeyPath<Item, String?>,
        onSelect: ((Item, Int) -> Void)? = nil
    ) {
        self.items = items
        self._selectedIndex = selectedIndex
        self.idPath = idPath
        self.namePath = namePath
        self.onSelect = onSelect
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        CategoryTag(
                            name: item[keyPath: namePath]?.replaceHtmlElement ?? "",
                            isSelected: selectedIndex == index
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedIndex = index
                            }
                            withAnimation {
                                if let id = item[keyPath: idPath] {
                                    proxy.scrollTo(id, anchor: .center)
                                }
                            }
                            onSelect?(item, index)
                        }
                        .id(item[keyPath: idPath])
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 44)
            .background(Color.systemBackground)
            .onAppear {
                // 初始滚动到选中项
                if let firstItem = items.first, let firstId = firstItem[keyPath: idPath] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(firstId, anchor: .center)
                        }
                    }
                }
            }
            .onChange(of: selectedIndex) { _, newValue in
                if newValue < items.count {
                    let item = items[newValue]
                    if let id = item[keyPath: idPath] {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}
