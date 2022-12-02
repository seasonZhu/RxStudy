//
//  GrayView.swift
//  RxStudy
//
//  Created by dy on 2022/12/1.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

class GrayView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .gray
        layer.compositingFilter = "saturationBlendMode"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIViewController {
    /// 首页变灰的方案
    func grayMode(isGrayMode: Bool) {
        if isGrayMode {
            let overlay = GrayView(frame: view.bounds)
            view.addSubview(overlay)
            view.bringSubviewToFront(overlay)
        } else {
            let some = view.subviews.first { view in
                if view is GrayView {
                    return true
                } else {
                    return false
                }
            }
            
            if let some {
                some.removeFromSuperview()
            }
        }
    }
    
    /// 一刀切所有页面变灰的方案
    func windowGrayMode(isGrayMode: Bool) {
        if let keyWindow = UIApplication.shared.keyWindow {
            if isGrayMode {
                let overlay = GrayView(frame: keyWindow.bounds)
                keyWindow.addSubview(overlay)
                keyWindow.bringSubviewToFront(overlay)
            } else {
                let some = keyWindow.subviews.first { view in
                    if view is GrayView {
                        return true
                    } else {
                        return false
                    }
                }
                
                if let some {
                    some.removeFromSuperview()
                }
            }
        }
    }
}

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var isGrayMode: Binder<Bool> {
        Binder(base) { base, isGrayMode in
            base.grayMode(isGrayMode: isGrayMode)
        }
    }
    
    var windowGrayMode: Binder<Bool> {
        Binder(base) { base, isGrayMode in
            base.windowGrayMode(isGrayMode: isGrayMode)
        }
    }
}

extension UIViewController {
    func bindGayMode() {
        AccountManager.shared.isGrayModeRelay
            .bind(to: rx.isGrayMode)
            .disposed(by: rx.disposeBag)
    }
    
    func bindWindowGrayMode() {
        AccountManager.shared.isGrayModeRelay
            .bind(to: rx.windowGrayMode)
            .disposed(by: rx.disposeBag)
    }
}
