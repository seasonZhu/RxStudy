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

extension ViewState {
    var view: Widget {
        switch self {
        case .loading:
            return UIActivityIndicatorView(style: .large)
        case .error:
            return UILabel()
        case .success(let success):
            switch success {
            case .empty:
                return UIView()
            case .hasContent(let widget):
                guard let w = widget else {
                    return UIView()
                }
                return w()
            }
        }
    }
}


protocol Widget {}

extension UIView: Widget {}

typealias BuilderWidget = () -> Widget
