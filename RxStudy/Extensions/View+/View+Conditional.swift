//
//  View+Conditional.swift
//  RxStudy
//
//  Created by Claude on 2025/02/19.
//  Copyright © 2025 season. All rights reserved.
//

import SwiftUI

// MARK: - 条件修饰符

public extension View {

    /// 条件应用修饰符
    /// - Parameters:
    ///   - condition: 条件
    ///   - modifier: 修饰符
    @ViewBuilder
    func modify<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 条件应用多个修饰符
    /// - Parameters:
    ///   - condition: 条件
    ///   - modifiers: 修饰符数组
    @ViewBuilder
    func modify<T: View>(_ condition: Bool, @ViewBuilder modifiers: (Self) -> T) -> some View {
        if condition {
            modifiers(self)
        } else {
            self
        }
    }

    /// 根据条件选择不同的视图
    /// - Parameters:
    ///   - condition: 条件
    ///   - trueTransform: 条件为true时的转换
    ///   - falseTransform: 条件为false时的转换
    @ViewBuilder
    func either<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - 可选值修饰符

public extension View {

    /// 当值存在时应用修饰符
    /// - Parameters:
    ///   - value: 可选值
    ///   - modifier: 修饰符
    @ViewBuilder
    func modify<T: View, U>(_ value: U?, transform: (Self, U) -> T) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    /// 当可选值存在时应用修饰符
    /// - Parameters:
    ///   - value: 可选值
    ///   - modifier: 修饰符
    @ViewBuilder
    func apply<T: View>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - 数组修饰符

public extension View {

    /// 对数组中的每个元素应用修饰符（如果匹配）
    /// - Parameters:
    ///   - items: 数组
    ///   - transform: 修饰符
    @ViewBuilder
    func modify<T: View, U: Equatable>(
        _ items: [U],
        contains item: U,
        transform: (Self) -> T
    ) -> some View {
        if items.contains(item) {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - 预览

#if DEBUG
struct ViewConditional_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 条件修饰符
            VStack(spacing: 20) {
                Text("条件修饰符").font(.headline)

                Text("有背景")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .modify(true) { view in
                        view.cornerRadius(10)
                    }

                Text("无圆角")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .modify(false) { view in
                        view.cornerRadius(10)
                    }
            }
            .padding()
            .previewDisplayName("条件修饰符")

            // 可选值修饰符
            VStack(spacing: 20) {
                Text("可选值修饰符").font(.headline)

                Text("有值")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .modify(Optional("Hello")) { view, value in
                        view.overlay(Text(value).foregroundColor(.white))
                    }

                Text("无值")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .modify(Optional<String>.none) { view, value in
                        view.overlay(Text(value).foregroundColor(.white))
                    }
            }
            .padding()
            .previewDisplayName("可选值")

            // either修饰符
            VStack(spacing: 20) {
                Text("Either修饰符").font(.headline)

                Text("条件为真")
                    .padding()
                    .either(true) { view in
                        view.background(Color.green).foregroundColor(.white)
                    } else: { view in
                        view.background(Color.red).foregroundColor(.white)
                    }

                Text("条件为假")
                    .padding()
                    .either(false) { view in
                        view.background(Color.green).foregroundColor(.white)
                    } else: { view in
                        view.background(Color.red).foregroundColor(.white)
                    }
            }
            .padding()
            .previewDisplayName("Either")
        }
    }
}
#endif
