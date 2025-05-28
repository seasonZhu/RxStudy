//
//  LoadingView.swift
//  RxStudy
//
//  Created by dy on 2025/5/28.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let loadingView = UIActivityIndicatorView(style: .large)
        loadingView.center = center
        loadingView.startAnimating()
        addSubview(loadingView)
    }
}
