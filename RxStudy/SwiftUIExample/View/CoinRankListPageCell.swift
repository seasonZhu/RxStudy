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
    
    var body: some View {
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
    }
}
