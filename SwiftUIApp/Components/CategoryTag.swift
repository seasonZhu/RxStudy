//
//  CategoryTag.swift
//  RxStudy - SwiftUIApp
//
//  分类标签组件
//  用于展示可选择的分类标签
//

import SwiftUI

struct CategoryTag: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(name)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 预览

#Preview {
    HStack {
        CategoryTag(name: "全部", isSelected: true) {
            print("tap")
        }
        CategoryTag(name: "Android", isSelected: false) {
            print("tap")
        }
    }
    .padding()
}
