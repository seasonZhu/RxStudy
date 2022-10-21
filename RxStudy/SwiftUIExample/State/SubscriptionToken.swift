//
//  SubscriptionToken.swift
//  RxStudy
//
//  Created by dy on 2022/10/20.
//  Copyright © 2022 season. All rights reserved.
//

import Combine

class SubscriptionToken {
    var cancellable: AnyCancellable?
    
    func unseal() { cancellable = nil }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancellable = self
    }
}

