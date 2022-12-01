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
