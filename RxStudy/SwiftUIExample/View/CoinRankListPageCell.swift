//
//  CoinRankListPageCell.swift
//  RxStudy
//
//  Created by dy on 2022/9/27.
//  Copyright © 2022 season. All rights reserved.
//

import SwiftUI

struct CoinRankListPageCell: View {
    let rank: ClassCoinRank?
    
    @State var isActive = false
    
    var body: some View {
        NavigationLink(isActive: $isActive) {
            ALayoutPage(isActive: $isActive)
        } label: {
            /// 包裹的Link文字就变蓝色了
            cell
        }
    }
    
    var cell: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let username = rank?.username {
                Text(username)
                    .padding(.leading, 15)
            }
            
            if let myInfo = rank?.myInfo {
                Text(myInfo)
                    .padding(.leading, 15)
            }
            
            Divider()
        }
        /// 使用这个将文字又改回黑色
        .foregroundColor(Color.black)
    }
}
