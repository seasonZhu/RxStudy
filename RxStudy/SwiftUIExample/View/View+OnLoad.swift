//
//  View+OnLoad.swift
//  RxStudy
//
//  Created by dy on 2022/10/9.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI

/// https://stackoverflow.com/questions/56496359/swiftui-view-viewdidload

extension View {

    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
}

extension View {
    
    func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewFirstAppearModifier(perform: action))
    }
}

typealias ViewFirstAppearModifier = ViewDidLoadModifier

struct ViewDidLoadModifier: ViewModifier {

    @State private var didLoad = false
    
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}
