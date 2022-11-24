//
//  MessageReadyStatus.swift
//  RxStudy
//
//  Created by dy on 2022/6/27.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

import HttpRequest



enum MessageReadyStatus {
    case unread
    case read
}

extension MessageReadyStatus {
    var requestService: ((_ page: Int) -> MyService) {
        return { page in
            switch self {
            case .unread:
                return .unreadList(page)
            case .read:
                return .readList(page)
            }
        }
    }
}

extension MessageReadyStatus {
    var title: String {
        switch self {
        case .unread:
            return "我的未读站内消息"
        case .read:
            return "我的全部站内消息"
        }
    }
}
