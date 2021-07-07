//
//  ViewState.swift
//  RxStudy
//
//  Created by season on 2021/7/7.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

enum ViewState {
    case loading
    case success(ViewStateSuccess)
    case error
    
    enum ViewStateSuccess {
        case hasContent(BuilderWidget?)
        case empty
    }
}

//extension ViewState {
//    var view: Widget {
//        switch self {
//        case .loading:
//            break
//        case .error:
//            break
//        case .success(let success):
//            switch success {
//            case .empty:
//                break
//            case .hasContent(let widget):
//                guard let w = widget else {
//                    break
//                }
//                return w()
//            default:
//                break
//            }
//        default:
//            return UIView()
//        }
//    }
//}

protocol Widget {}

extension UIView: Widget {}

typealias BuilderWidget = () -> Widget
