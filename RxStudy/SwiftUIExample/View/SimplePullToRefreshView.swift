//
//  DemoPullToRefreshView.swift
//  Demo
//
//  Created by Gesen on 2020/3/21.
//

import SwiftUI

struct SimplePullToRefreshView: View {
    let progress: CGFloat
    
    var body: some View {
        if progress > 2 {
            Text("Release to refresh")
        } else {
            Text("Pull to refresh")
        }
    }
}
