//
//  SimpleRefreshingView.swift
//  Demo
//
//  Created by Gesen on 2020/3/21.
//

import SwiftUI

struct SimpleRefreshingView: View {
    var body: some View {
        HStack {
            ActivityIndicator(style: .medium)
            Text("Loading...")
        }
    }
}
